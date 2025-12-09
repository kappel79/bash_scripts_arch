import random
import os
from words import WORDS
LOGO = r'''

                                ------
                                |    |
                                |    O
                                |   /|\
                                |   / \
                                |
                                --------
           _  _     ___    _  _     ___   __  __    ___    _  _
    o O O | || |   /   \  | \| |   / __| |  \/  |  /   \  | \| |
   o      | __ |   | - |  | .` |  | (_ | | |\/| |  | - |  | .` |
  TS__[O] |_||_|   |_|_|  |_|\_|   \___| |_|__|_|  |_|_|  |_|\_|
 {======|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|
./o--000'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'

                    Copyright (C) 2025 kappel79                 
'''



# ASCII Art for Hangman stages
STAGES = [
    """
       ------
       |    |
       |
       |
       |
       |
    --------
    """,
    """
       ------
       |    |
       |    O
       |
       |
       |
    --------
    """,
    """
       ------
       |    |
       |    O
       |    |
       |
       |
    --------
    """,
    """
       ------
       |    |
       |    O
       |   /|
       |
       |
    --------
    """,
    """
       ------
       |    |
       |    O
       |   /|\\
       |
       |
    --------
    """,
    """
       ------
       |    |
       |    O
       |   /|\\
       |   /
       |
    --------
    """,
    """
       ------
       |    |
       |    O
       |   /|\\
       |   / \\
       |
    --------
    """
]

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def play_game():
    word, question = random.choice(list(WORDS.items()))
    word = word.upper()
    word_completion = "_" * len(word)
    guessed = False
    guessed_letters = []
    guessed_words = []
    tries = 6

    print("Let's play Hangman!")
    print(f"Hint: {question}")
    print(STAGES[0])
    print("\n" + word_completion)
    print("\n")

    while not guessed and tries > 0:
        guess = input("Please guess a letter or word: ").upper()
        
        # Input validation
        if len(guess) == 1 and guess.isalpha():
            if guess in guessed_letters:
                print("You already guessed the letter", guess)
            elif guess not in word:
                print(guess, "is not in the word.")
                tries -= 1
                guessed_letters.append(guess)
            else:
                print("Good job,", guess, "is in the word!")
                guessed_letters.append(guess)
                word_as_list = list(word_completion)
                indices = [i for i, letter in enumerate(word) if letter == guess]
                for index in indices:
                    word_as_list[index] = guess
                word_completion = "".join(word_as_list)
                if "_" not in word_completion:
                    guessed = True
        elif len(guess) == len(word) and guess.isalpha():
            if guess in guessed_words:
                print("You already guessed the word", guess)
            elif guess != word:
                print(guess, "is not the word.")
                tries -= 1
                guessed_words.append(guess)
            else:
                guessed = True
                word_completion = word
        else:
            print("Not a valid guess.")
        
        print(STAGES[6 - tries])
        print(word_completion)
        print("\n")

    if guessed:
        print("Congrats, you guessed the word! You win!")
    else:
        print("Sorry, you ran out of tries. The word was " + word + ". Maybe next time!")

def main():
    clear_screen()
    print(LOGO)
    input("Press Enter to play...")
    while True:
        clear_screen()
        play_game()
        if input("Play again? (Y/N) ").upper() != "Y":
            break

if __name__ == "__main__":
    main()
