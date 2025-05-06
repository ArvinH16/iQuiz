iQuiz Final Version: A Multiple-Choice Q-and-A Application
Part 1: App Scaffolding 
Application Overview
Users can choose from a collection of quizzes.
Quizzes consist of 1 to many multiple-choice questions.
Users progress through each question one at a time.
The app tracks users' answers and can upload their scores.
Quizzes are updated from a server
Repo should be called "iQuiz".
Basic Interaction
Quiz List: Display a TableView with quiz topics.
Topics Include: Mathematics, Marvel Super Heroes, Science.
Data Storage: Use an in-memory array for testing (You will need to access the data later using a HTTP request in Part 2)
TableView Setup
Cells: Each cell represents a quiz topic.
Cell Contents:
Icon on the left (any image).
Title (up to 30 characters).
Short description sentence.
ToolBar
Located across the top.
Includes a settings button.
Settings button triggers a UIAlertController displaying "Settings go here" with an "OK" button.
Grading Criteria
TableView appears with non-empty cells: 1 point.
Correct number of cells: 1 point.
Cells display correct data: 1 point.
Cells include icons and subtext: 1 point.
Settings alert functions correctly: 1 point.