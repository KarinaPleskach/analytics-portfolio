# Database Schema Documentation

## Users Tables

#### Users

A table containing information about all users.

| field | description |
|------|------------|
| **id** | unique user identifier |
| **username** | platform login |
| **first_name** | first name |
| **last_name** | last name |
| **is_active** | whether the account is activated |
| **date_joined** | registration date and time |
| **email** | email address |
| **referral_user** | the user who invited them (referrer) |
| **company_id** | company identifier (FK to Company) |
| **tier** | platform rank |
| **score** | amount of experience points on the platform |

#### UserEntry

This table records user logins — when, at what time, and on which page the user first entered the platform during a given day.

| field | description |
|------|------------|
| **id** | unique identifier |
| **entry_at** | login date and time |
| **page_id** | entry page identifier (FK to Page) |
| **user_id** | user identifier (FK to Users) |

## General Tables

#### Page

A table containing information about all website pages.

| field | description |
|------|------------|
| **id** | unique page identifier |
| **path** | relative URL |
| **name** | page name |

#### Company

A table containing information about companies.

| field | description |
|------|------------|
| **id** | unique company identifier |
| **name** | company name |
| **description** | company description |
| **logo** | path to logo file on server |
| **db_cred** | database schema credentials for code execution |
| **site** | company website URL |

## Task-Related Tables

#### Language

Languages available for solving tasks.

| field | description |
|------|------------|
| **id** | unique language identifier |
| **name** | language name |

#### Problem

A table containing all coding problems.

| field | description |
|------|------------|
| **id** | unique problem identifier |
| **name** | problem name |
| **complexity** | difficulty level (1–3) |
| **bonus** | reward for correct solution (CodeCoins) |
| **task** | problem description |
| **solution** | solution description |
| **cost** | cost in CodeCoins |
| **rating** | problem rating |
| **page_id** | page identifier (FK to Page) |
| **solution_cost** | cost to view solution |
| **priority** | display priority |
| **company_id** | company identifier (not used) |
| **is_visible** | visible in general list |
| **is_private** | only for corporate clients |
| **recommendation** | solving recommendations |

#### LanguageToProblem

Mapping table between problems and languages.

| field | description |
|------|------------|
| **ltp_id** | unique record identifier |
| **pr_id** | problem identifier (FK to Problem) |
| **lang_id** | language identifier (FK to Language) |

#### CodeRun

Records when a user runs code.

| field | description |
|------|------------|
| **id** | execution identifier |
| **created_at** | execution timestamp |
| **problem_id** | problem identifier (FK to Problem) |
| **user_id** | user identifier (FK to Users) |
| **language_id** | language identifier (FK to Language) |

#### CodeSubmit

Records when a user submits code for checking.

| field | description |
|------|------------|
| **id** | submission identifier |
| **created_at** | submission timestamp |
| **code** | submitted code |
| **problem_id** | problem identifier (FK to Problem) |
| **user_id** | user identifier (FK to Users) |
| **is_false** | whether attempt was incorrect |
| **time_spent** | execution time |
| **language_id** | language identifier (FK to Language) |

#### Problem_To_Company

Company-specific homework assignments.

| field | description |
|------|------------|
| **id** | record identifier |
| **name** | custom task name for company |
| **task** | custom task description |
| **cost** | custom cost |
| **company_id** | company identifier (FK to Company) |
| **problem_id** | problem identifier (FK to Problem) |
| **bonus** | bonus for correct solution |
| **priority** | display priority |

## Test Tables

#### Test

General information about tests.

| field | description |
|------|------------|
| **id** | test identifier |
| **name** | test name |
| **page_id** | page identifier (FK to Page) |
| **cost** | cost in CodeCoins |
| **cover** | cover image path |
| **intro** | introduction text |
| **result** | result text (3 variants) |
| **complexity** | difficulty level (1–3) |
| **priority** | display priority |
| **company_id** | not used |
| **is_visible** | visible in list |
| **is_private** | private test |
| **repeat_cost** | cost for retake |

#### TestQuestion

Questions for tests.

| field | description |
|------|------------|
| **id** | question identifier |
| **question_num** | order number in test |
| **value** | question text |
| **tag** | topic |
| **test_id** | test identifier (FK to Test) |
| **explanation** | explanation text |
| **explanation_cost** | cost of explanation |
| **type_question** | question type |

#### TestAnswer

Answers for test questions.

| field | description |
|------|------------|
| **id** | answer identifier |
| **option** | option number |
| **value** | answer text |
| **is_correct** | correctness flag |
| **question_id** | question identifier (FK to TestQuestion) |

#### TestStart

When a user starts a test.

| field | description |
|------|------------|
| **id** | start identifier |
| **created_at** | start time |
| **test_id** | test identifier |
| **user_id** | user identifier |

#### TestResult

User test answers.

| field | description |
|------|------------|
| **id** | result identifier |
| **created_at** | answer time |
| **answer_id** | answer identifier (nullable) |
| **question_id** | question identifier |
| **test_id** | test identifier |
| **user_id** | user identifier |
| **value** | manual input answer (if any) |
