import re

def minify_dart_code(code):
    # Remove single-line comments
    code = re.sub(r'//.*', '', code)
    # Remove multi-line comments
    code = re.sub(r'/\*.*?\*/', '', code, flags=re.DOTALL)
    # Remove unnecessary whitespace
    code = re.sub(r'\s+', ' ', code)
    # Remove spaces around braces and operators
    code = re.sub(r'\s*([{}();,=+-])\s*', r'\1', code)
    return code.strip()

# Read the Dart file
with open('main.dart', 'r') as file:
    original_code = file.read()

# Minify the code
minified_code = minify_dart_code(original_code)

# Write the minified code to a new file
with open('main_minified.dart', 'w') as file:
    file.write(minified_code)

print("Code minified and saved to 'main_minified.dart'")