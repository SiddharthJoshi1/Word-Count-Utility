## **README.md**

### **Word Count Command-Line Tool**

**Purpose:**
This Dart project implements a command-line tool that functions similarly to the Unix `wc` utility. It counts the number of bytes, words, lines, and characters in a specified file or standard input stream.

**Usage:**
```bash
word_count [options] [file]
```

**Options:**
- **-m:** Count the number of bytes.
- **-w:** Count the number of words.
- **-l:** Count the number of lines.
- **-c:** Count the number of characters.

**Examples:**
- To count the number of words in a file named `myfile.txt`:
  ```bash
  dart word_count -w myfile.txt
  ```
- To count the number of lines of a file and pipe the output to another command:
  ```bash
  dart word_count -l myfile.txt | head -n 5
  ```
- To count the number of characters in the standard input:
  ```bash
  echo "Hello, world!" | dart word_count -c
  ```

**Default Behavior:**
If no options are provided, the tool will print the number of bytes, words, and lines for the given input.

**Note:**
- The tool assumes that words are separated by whitespace characters.
- The behavior for counting characters might vary slightly depending on the specific definition of a character in the Dart environment.

**Additional Considerations & Possibilities:**
- Might want to implement more advanced features like excluding certain characters or counting specific types of words.
- For larger files, you might want to optimize the counting algorithms to improve performance.

**Contributing:**
Feel free to contribute to this project by submitting pull requests or raising issues.
