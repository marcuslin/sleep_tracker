# Good Night: Sleep Tracker API

This project implements a RESTful API for a "Good Night" application, allowing users to track their sleep, follow friends, and view their friends' sleep records. Built with Ruby on Rails, it focuses on clean architecture, scalability, and robust API design.

## Features

*   **Clock In/Out:** Users can record when they go to bed and when they wake up.
*   **Sleep Record Management:** View all personal sleep records, ordered by creation time.
*   **User Following:** Users can follow and unfollow other users.
*   **Friends' Weekly Sleep Records:** See sleep records of all followed users from the previous week, sorted by sleep duration.
*   **Authentication:** Simple JWT-based authentication for secure API access.
*   **API Protection:** Basic rate limiting using `rack-attack` to prevent abuse.

## API Endpoints

### Authentication
*   `POST /api/v1/auth/login` - Authenticate a user and receive a JWT.

### Sleep Records
*   `POST /api/v1/sleep_records/clock_in` - Record the start of a sleep session.
*   `POST /api/v1/sleep_records/clock_out` - Record the end of a sleep session.
*   `GET /api/v1/sleep_records` - Retrieve all personal sleep records.
*   `GET /api/v1/sleep_records/friends_weekly` - Get friends' sleep records from the previous week, sorted by duration (cursor-paginated).

### Follows
*   `POST /api/v1/follows` - Follow another user.
*   `DELETE /api/v1/follows/:followee_id` - Unfollow a user.

## Key Technologies

*   **Ruby on Rails 8:** The core web framework.
*   **PostgreSQL:** Relational database.
*   **JWT (JSON Web Tokens):** For stateless API authentication.
*   **ActiveInteraction:** For encapsulating complex business logic and validations.
*   **Rack::Attack:** For API rate limiting and abuse prevention.
*   **RSpec:** For comprehensive testing.
*   **Makara:** (Planned/Discussed) For read/write splitting.
*   **Sidekiq:** (Planned/Discussed) For background job processing (e.g., auto clock-out).
*   **Redis:** (Planned/Discussed) For caching and Sidekiq.

## Architecture & Design Highlights

*   **RESTful API:** Designed with clear, resource-oriented endpoints.
*   **Stateless API:** Leverages JWT for easy horizontal scaling.
*   **Separation of Concerns:** Controllers are lean, delegating business logic to `ActiveInteraction` objects.
*   **Scalability Focus:** Strategies for handling growing user bases and high data volumes (indexing, N+1 prevention, cursor-based pagination, read/write splitting).
*   **Robustness:** Thorough validation at the application and database levels.

## Setup and Running the Project

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/marcuslin/sleep_tracker.git
    cd sleep_tracker_api
    ```
2.  **Set up Ruby Version:**
    ```bash
    # Ensure you have rbenv or rvm installed
    rbenv install 3.4.4 # or your specified Ruby version
    rbenv local 3.4.4
    ```
3.  **Install Dependencies:**
    ```bash
    bundle install
    ```
4.  **Database Setup:**
    *   Ensure PostgreSQL is running.
    *   Configure `config/database.yml` with your PostgreSQL credentials.
    ```bash
    rails db:create
    rails db:migrate
    rails db:seed # If you have seed data
    ```
5.  **Run the Rails Server:**
    ```bash
    rails s
    ```
    The API will be accessible at `http://localhost:3000`.

## Testing

*   Run all tests: `bundle exec rspec`

---

**Note:** This project is a demonstration of API design and backend development skills. For a full production deployment, additional considerations like comprehensive logging, monitoring, and advanced deployment strategies would be implemented.

---
