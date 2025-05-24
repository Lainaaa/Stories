# 📹 Demo

- [Watch video usage demo](https://www.loom.com/share/05214ee3bf06400f8b9acca078b3334b)

---

# Technical test – Senior iOS Engineer

## 💡 Guidelines

- **Duration**: 4 hours (extra minutes are acceptable, but stay close to the limit)
- **Submission**: Send your project via email as a zip file or a GitHub repository link.
    - Please include a screen recording of your working solution.
    - Record a Loom (max 3 minutes, in English) explaining the main technical choices of the project, with a focus on the code.
- **Documentation**: Include a short README file explaining:
    - Any architectural decisions you made
    - Assumptions or limitations

---

## 🎯 Objective

This test assesses the usability of your app and your iOS engineering skills, including code quality, architecture, performance, and best practices.  
You will focus on implementing a **Stories-like feature similar to Instagram**, ensuring a usable and interactive experience.

---

## ✅ Task

You will build an **Instagram Stories-like feature** with the following key functionalities:

### Features

- **Story List Screen**
    - Display a list of stories (with pagination: support infinite number of stories, even with repeating data).
    - Each story should be visually marked as **seen or unseen**.
- **Story View Screen**
    - Users can navigate between the story list and individual stories.
    - Support **like/unlike** actions.
    - UX inspired by Instagram (gestures, controls, etc.).
- **States**
    - Stories can be liked.
    - Seen/unseen state must be clear.
- **Persistence**
    - Like and seen states must **persist across app sessions**.

⚠️ At BeReal, we place great emphasis on both **product execution** and **user experience**—please keep these in mind throughout the test.

---

## 🛠 Technical Requirements

- **Language**: Swift & SwiftUI (UIKit allowed if necessary)
- **Data Source**: Open API, local JSON, or hardcoded data (your choice)
    - A reference JSON file for users is provided (see Appendix).
    - You must structure the data so stories for each user remain consistent.
    - JSON can be read locally, but **images should not be bundled** as static assets.
- **External Libraries**: Allowed if they don’t implement core features for you. Justify your choices.

---

## 🧪 Evaluation Criteria

- **Performance & Efficiency**
    - Smooth UX and performant UI
    - Efficient handling of pagination and persistence
- **Code Quality & Best Practices**
    - Readable, testable, maintainable code
    - Proper use of Swift idioms
- **Architecture & Scalability**
    - Clear structure, modular, separation of concerns
- **Attention to Detail**
    - Solid edge-case handling
    - Polished UI/UX
- **Feature Prioritization**
    - If something is missing, explain why in your README

---

## 📤 Submission

Once completed, send your project via email or share a private GitHub link with the Talent Acquisition team member you’re in contact with.

**Good luck!**

---

## 📎 Appendix

- Provided: JSON file for users (you can use, extend, or ignore it)
- Not provided: JSON file for stories (use images from open APIs or any structured random data)
