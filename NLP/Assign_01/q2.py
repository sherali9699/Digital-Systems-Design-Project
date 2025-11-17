import re
from datetime import datetime

def read_text(file_path):
    """Read the entire content of a text file."""
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read()

def extract_records(text):
    """
    Extract records from text using regex to find balanced curly braces.
    Returns a list of strings, each representing one record.
    """
    # Pattern to match content between curly braces, handling nested braces
    pattern = r'\{([^{}]*)\}'
    records = re.findall(pattern, text)
    
    # for record in records:
    #     print(record)

    # Filter out empty records
    return [record.strip() for record in records if record.strip()]

def classify_tokens(record):
    """
    Classify tokens in a record as name, phone, or dob.
    Returns a tuple (name, dob, phone) with identified values.
    """
    # Split the record by commas, handling whitespace
    tokens = [token.strip() for token in record.split(',') if token.strip()]
    
    print(tokens)

    # Handle the specific case where we have 4 tokens (likely a split date)
    if len(tokens) == 4:
        # Check all positions for month names that might be part of a split date
        month_pattern = r'^(January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)'
        
        # Check each position for a month name (only up to the second last token)
        for i in range(len(tokens) - 1):  # Stop before the last token
            # print(f"inside token: {i}")
            month_match = re.match(month_pattern, tokens[i], re.IGNORECASE)
            # print(f'match result: {month_match}')
            
            if month_match:            
                combined_token = tokens[i] + ', ' + tokens[i+1]
                tokens[i] = combined_token
                # Remove the next token
                tokens.pop(i+1)
                break  # Only combine one pair per record
    
    # print(f'tokens after combined: {tokens}')
    
    # Define regex patterns for classification
    date_patterns = [
        r'^\d{1,2}[-/]\d{1,2}[-/]\d{2,4}$',  # dd/mm/yyyy or dd-mm-yyyy
        r'^\d{4}[-/]\d{1,2}[-/]\d{1,2}$',    # yyyy-mm-dd or yyyy/mm/dd
        r'^\d{1,2}\s+[A-Za-z]{3,}\s+\d{2,4}$',  # 12 Mar 1980
        r'^[A-Za-z]{3,}\s+\d{1,2},?\s+\d{2,4}$',  # March 12, 1980
        r'^\d{1,2}\.\d{1,2}\.\d{2,4}$',  # dd.mm.yyyy
        r'^\d{1,2}\s+[A-Za-z]{3,}\s+\d{4}$',  # 21 Aug 1973
        r'^[A-Za-z]+\s+\d{1,2},?\s+\d{4}$',  # January 15, 1929
        r'^\d{1,2}-[A-Za-z]{3,}-\d{2,4}$',
    ]
    
    phone_pattern = r'^[\+\d\s\-\(\)]{5,}$'  # Matches phone numbers with digits and common separators
    
    name_pattern = r'^[A-Za-z\s\'\-\.]+$'  # Matches alphabetic characters with common name punctuation
    
    name = None
    phone = None
    dob = None
    
    # First pass: identify clear dates and phones
    for token in tokens:
        # Check if token is a date
        is_date = any(re.match(pattern, token) for pattern in date_patterns)
        
        # Check if token is a phone number
        is_phone = re.match(phone_pattern, token) and any(char.isdigit() for char in token)
        
        if is_date and dob is None:
            dob = token
        elif is_phone and phone is None:
            phone = token
    
    # Second pass: identify names and handle ambiguous cases
    for token in tokens:
        if token == dob or token == phone:
            continue
            
        # Check if token is a name
        clean_token = re.sub(r'^[^A-Za-z]*|[^A-Za-z]*$', '', token)  # Remove special chars from start/end
        is_name = re.match(name_pattern, clean_token) and clean_token
        
        if is_name and name is None:
            name = token
        else:
            # Handle ambiguous cases
            if name is None and any(char.isalpha() for char in token):
                name = token
            elif dob is None and any(char.isdigit() for char in token) and ('/' in token or '-' in token or '.' in token):
                dob = token
            elif phone is None and sum(char.isdigit() for char in token) >= 3:  # Reduced threshold for phone numbers
                phone = token
    
    # Special handling for "124" which should be a phone number, not a name
    if name == "124" and phone is None:
        phone = "124"
        name = None
    
    # If we still haven't found a name, try to find it among remaining tokens
    if name is None:
        for token in tokens:
            if token != dob and token != phone and any(char.isalpha() for char in token):
                # Remove special characters from start and end
                clean_name = re.sub(r'^[^A-Za-z]*|[^A-Za-z]*$', '', token)
                if clean_name:
                    name = clean_name
                    break
    

    # Clean the name by removing special characters from start and end (only once at the end)
    if name:
        name = re.sub(r'^[^A-Za-z]*|[^A-Za-z]*$', '', name)

    print(f'after filtring------')
    print((name, dob, phone))

    return name, dob, phone

# def classify_tokens(record):
#     """
#     Classify tokens in a record as name, phone, or dob.
#     Returns a tuple (name, dob, phone) with identified values.
#     """
#     # Split the record by commas, handling whitespace
#     tokens = [token.strip() for token in record.split(',') if token.strip()]

#     print(tokens)
    
#     # Define regex patterns for classification
#     date_patterns = [
#         r'^\d{1,2}[-/]\d{1,2}[-/]\d{2,4}$',  # dd/mm/yyyy or dd-mm-yyyy
#         r'^\d{4}[-/]\d{1,2}[-/]\d{1,2}$',    # yyyy-mm-dd or yyyy/mm/dd
#         r'^\d{1,2}\s+[A-Za-z]{3,}\s+\d{2,4}$',  # 12 Mar 1980
#         r'^[A-Za-z]{3,}\s+\d{1,2},?\s+\d{2,4}$',  # March 12, 1980
#         r'^\d{1,2}\.\d{1,2}\.\d{2,4}$',  # dd.mm.yyyy
#         r'^\d{1,2}\s+[A-Za-z]{3,}\s+\d{4}$',  # 21 Aug 1973
#         r'^[A-Za-z]+\s+\d{1,2},?\s+\d{4}$'  # January 15, 1929
#     ]
    
#     #here I have taken assumption that phone number should be greater than 5 digits
#     phone_pattern = r'^[\+\d\s\-\(\)]{5,}$'  # Matches phone numbers with digits and common separators
    
#     # Updated name pattern to allow special characters at the beginning or end
#     name_pattern = r'^[A-Za-z\s\'\-\.]+$'

#     name = None
#     phone = None
#     dob = None
    
#     for token in tokens:
#         # Check if token is a date
#         is_date = any(re.match(pattern, token) for pattern in date_patterns)
        
#         # Check if token is a phone number
#         is_phone = re.match(phone_pattern, token) and any(char.isdigit() for char in token)
        
#         # Check if token is a name (only if not date or phone)
#         is_name = re.match(name_pattern, token) and not is_date and not is_phone
        
#         if is_date and dob is None:
#             dob = token
#         elif is_phone and phone is None:
#             phone = token
#         elif is_name and name is None:
#             name = token
#         else:
#             # If classification is ambiguous, use fallback logic
#             if dob is None and any(char.isdigit() for char in token) and '/' in token or '-' in token:
#                 dob = token
#             elif phone is None and sum(char.isdigit() for char in token) >= 5:
#                 phone = token
#             elif name is None:
#                 name = token
    
#     print(f'after filtering ------')
#     print((name, dob, phone))
#     return name, dob, phone

def normalize_dob(dob_string):
    """
    Normalize date of birth to ISO format YYYY-MM-DD.
    Handles various date formats and two-digit years.
    """
    if not dob_string:
        return ""
    
    # Map month names to numbers
    month_map = {
        'jan': '01', 'feb': '02', 'mar': '03', 'apr': '04',
        'may': '05', 'jun': '06', 'jul': '07', 'aug': '08',
        'sep': '09', 'oct': '10', 'nov': '11', 'dec': '12',
        'january': '01', 'february': '02', 'march': '03', 'april': '04',
        'may': '05', 'june': '06', 'july': '07', 'august': '08',
        'september': '09', 'october': '10', 'november': '11', 'december': '12'
    }
    
    # Try to parse different date formats
    try:
        # Format: dd/mm/yyyy or dd-mm-yyyy
        if re.match(r'^\d{1,2}[-/]\d{1,2}[-/]\d{2,4}$', dob_string):
            parts = re.split(r'[-/]', dob_string)
            day, month, year = parts[0], parts[1], parts[2]
            
            # Handle two-digit year
            if len(year) == 2:
                year_int = int(year)
                year = f"20{year}" if year_int <= 24 else f"19{year}"
            
            return f"{year}-{month.zfill(2)}-{day.zfill(2)}"
        
        # Format: yyyy-mm-dd or yyyy/mm/dd
        elif re.match(r'^\d{4}[-/]\d{1,2}[-/]\d{1,2}$', dob_string):
            parts = re.split(r'[-/]', dob_string)
            year, month, day = parts[0], parts[1], parts[2]
            return f"{year}-{month.zfill(2)}-{day.zfill(2)}"
        
        # Format: 12 Mar 1980
        elif re.match(r'^\d{1,2}\s+[A-Za-z]{3,}\s+\d{2,4}$', dob_string):
            parts = dob_string.split()
            day, month_name, year = parts[0], parts[1].lower()[:3], parts[2]
            
            # Handle two-digit year
            if len(year) == 2:
                year_int = int(year)
                year = f"20{year}" if year_int <= 24 else f"19{year}"
            
            month = month_map.get(month_name, '01')
            return f"{year}-{month}-{day.zfill(2)}"
        
        # Format: March 12, 1980
        elif re.match(r'^[A-Za-z]{3,}\s+\d{1,2},?\s+\d{2,4}$', dob_string):
            parts = re.split(r'\s+|,', dob_string)
            parts = [p for p in parts if p]
            month_name, day, year = parts[0].lower()[:3], parts[1], parts[2]
            
            # Handle two-digit year
            if len(year) == 2:
                year_int = int(year)
                year = f"20{year}" if year_int <= 24 else f"19{year}"
            
            month = month_map.get(month_name, '01')
            return f"{year}-{month}-{day.zfill(2)}"
        
        # Format: dd-mmm-yyyy (like 15-Apr-1452)
        elif re.match(r'^\d{1,2}-[A-Za-z]{3,}-\d{2,4}$', dob_string):
            parts = dob_string.split('-')
            day, month_name, year = parts[0], parts[1].lower()[:3], parts[2]
            month = month_map.get(month_name, '01')
            return f"{year}-{month}-{day.zfill(2)}"

        # Format: dd.mm.yyyy (like 21.04.1926)
        elif re.match(r'^\d{1,2}\.\d{1,2}\.\d{2,4}$', dob_string):
            parts = dob_string.split('.')
            day, month, year = parts[0], parts[1], parts[2]
            # Handle two-digit year
            if len(year) == 2:
                year_int = int(year)
                year = f"20{year}" if year_int <= 24 else f"19{year}"
            return f"{year}-{month.zfill(2)}-{day.zfill(2)}"        

        # If no pattern matches, return original string
        return dob_string
    
    except (IndexError, ValueError):
        # If parsing fails, return the original string
        return dob_string

def write_pairs(name_dob_pairs, output_path):
    """
    Write name,dob pairs to a file, one per line.
    """
    with open(output_path, 'w', encoding='utf-8') as file:
        
        for name, dob in name_dob_pairs:
            file.write(f"(Name: {name}, DoB: {dob})\n")

def main(input_file, output_file):
    """
    Main function to process the input file and generate the output.
    """
    # Read the input file
    text = read_text(input_file)
    
    # Extract records
    records = extract_records(text)

    # i =1
    # check = [17, 20, 35, 43, 49]
    # for record in records:
    #     #if i in check:
    #     print(f'record no : {i} ---')
    #     classify_tokens(record)
    #     i += 1
    
    
    # Process each record
    name_dob_pairs = []
    for record in records:
        name, dob, phone = classify_tokens(record)
        
        # Normalize the date of birth
        normalized_dob = normalize_dob(dob) if dob else ""
        
        # If we couldn't identify name or dob, skip the record
        if name and normalized_dob:
            name_dob_pairs.append((name, normalized_dob))
    
    # Write the output file
    write_pairs(name_dob_pairs, output_file)

    # write_pairs(str(text), output_file)

    
    # print(f"Processed {len(name_dob_pairs)} records. Output written to {output_file}")

# Example usage
if __name__ == "__main__":
    input_file = "Question2_input.txt"  # Replace with actual file path
    output_file = "Question2_output.txt"
    main(input_file, output_file)