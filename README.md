# iPark - Parking Reservation Platform

iPark is a professional parking management system designed to streamline the process of finding and booking parking spaces. Built with a focus on stability and security, the platform utilizes the Java Spring Boot ecosystem to provide a seamless user experience.

---

## Technical Specifications

### Architecture and Core Technologies
The application is built on a **Layered Architecture** and follows a modular **monolithic web application** model.

* **Server-Side Rendering (SSR):** The system serves dynamic content directly from the server, ensuring a clear separation of concerns.
* **Presentation Layer (Client):** Built using **HTML5** and **Thymeleaf** for dynamic data injection and component reusability through Fragments.
    * Visual styling is managed via **CSS3** utilizing **Flexbox and Grid** for a responsive, "Mobile-First" approach.
    * Client-side logic and DOM manipulation are handled by lightweight **JavaScript**.
* **Application Layer (Spring Boot):** **Spring MVC Controllers** manage HTTP requests and data transport.
    * **Dependency Injection (IoC)** ensures a loosely coupled and testable codebase.
    * **Session Management** is handled via **HttpSession** to persist user authentication.
* **Data Access and Storage:** **Spring Data JPA** and **Hibernate (ORM)** abstract database interactions.
    * **H2 Database (In-Memory)** is used for rapid development and data persistence during server runtime.
* **Integrations:**
    * **Stripe API** for secure, event-driven payment processing.
    * **Webhooks** are utilized for asynchronous transaction confirmation and signature verification.

---

### Design Patterns
The project implements several industry-standard design patterns to ensure maintainability and scalability:

1. **Specification Pattern:** Used to decouple business rules from database queries, allowing for dynamic filtering (e.g., finding zones with available spaces).
2. **Repository Pattern:** Creates an abstraction layer between the business logic and the data source, reducing repetitive SQL code.
3. **Singleton Pattern:** Managed by the Spring Container to ensure that services and controllers are instantiated only once, optimizing resource usage.
4. **Builder Pattern:** Employed for complex object configuration, specifically when initiating Stripe payment sessions.
5. **Model-View-Controller (MVC):** The fundamental architecture that separates data (Model), presentation (View), and logic (Controller).

---

## Key Features

### 1. Security and Authentication
* **Session Management:** Handles the user lifecycle from login to logout.
* **Registration Validation:** Includes checks for unique usernames and password matching.
* **Route Protection:** Restricts access to sensitive pages (e.g., /reserve or /account) for unauthenticated users.

<img width="1120" height="1119" alt="image" src="https://github.com/user-attachments/assets/b884fca0-2722-45d9-a817-7f8a7ff0b3f4" />


### 2. Intelligent Parking Management
* **Real-Time Monitoring:** Dynamically calculates available spaces and displays status badges (Available / Full).
* **Window Shopping:** Allows guests to view parking zones and prices without requiring an account, lowering the barrier to entry.
* **Advanced Filtering:** Users can filter zones to show only those with current availability.

<img width="3199" height="1374" alt="image" src="https://github.com/user-attachments/assets/04aa60ed-aa50-4a20-b64f-d45147f62a66" />


### 3. Robust Reservation Engine
* **Dual Pricing Model:** Supports both hourly rates for short stays and fixed/daily rates for long-term parking.
* **Smart Input:** Features an auto-complete system for license plates based on the user's saved vehicles.
* **Dual Validation:** Pricing and durations are calculated on the frontend for user feedback and strictly recalculated on the backend for security.

<img width="1427" height="1479" alt="image" src="https://github.com/user-attachments/assets/8b1ea832-5a9f-4317-a9ea-750765fd9862" />


### 4. Integrated Payment Processing
* **Stripe Checkout:** Delegates sensitive card data processing to Stripe to ensure compliance and security.
* **Asynchronous Webhooks:** Confirmations are triggered only after receiving a secure signal from Stripe, preventing unpaid reservations.

<img width="1594" height="1472" alt="image" src="https://github.com/user-attachments/assets/91b1fb94-c12b-4da0-a2c0-fbdba0f68fe3" />


### 5. User Account Hub
* **Personal Fleet Management:** Users can save and manage multiple license plates for quick booking.
* **Audit Trail:** Provides a detailed history of all reservations and a financial log showing payment statuses (Success, Failed, Canceled).

<img width="2186" height="1584" alt="image" src="https://github.com/user-attachments/assets/1a59a9e4-3eca-47f0-9270-2add1cf2a402" />


### 6. Responsive User Interface
* **Adaptive Layout:** Uses CSS Flexbox and Grid to adjust the UI for mobile, tablet, and desktop screens.
* **Dynamic UI Elements:** Includes a hamburger-style navigation menu and horizontally scrollable tables for mobile compatibility.

<img width="676" height="1450" alt="image" src="https://github.com/user-attachments/assets/47dacf8c-268f-4cb0-b2fc-03543968a531" />

