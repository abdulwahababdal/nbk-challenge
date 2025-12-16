# Banking Back Office Application - Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          FLUTTER FRONTEND (SPA)                          │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        Presentation Layer                        │   │
│  │                                                                   │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐     │   │
│  │  │ Login Screen │  │ Home Screen  │  │ Customer Form     │     │   │
│  │  │              │  │              │  │ Screen            │     │   │
│  │  └──────────────┘  └──────────────┘  └───────────────────┘     │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│                                    │                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    State Management (Provider)                   │   │
│  │                                                                   │   │
│  │  ┌──────────────────┐              ┌──────────────────────┐     │   │
│  │  │  Auth Provider   │              │  Customer Provider   │     │   │
│  │  │  - Login state   │              │  - Customer list     │     │   │
│  │  │  - User info     │              │  - CRUD operations   │     │   │
│  │  │  - Token mgmt    │              │  - Loading states    │     │   │
│  │  └──────────────────┘              └──────────────────────┘     │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│                                    │                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                         Services Layer                           │   │
│  │                                                                   │   │
│  │  ┌──────────────────┐              ┌──────────────────────┐     │   │
│  │  │   API Service    │              │  Storage Service     │     │   │
│  │  │  - HTTP client   │              │  - Secure storage    │     │   │
│  │  │  - API calls     │              │  - Token persistence │     │   │
│  │  └──────────────────┘              └──────────────────────┘     │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTPS
                                    │ REST API
                                    │ JSON
                                    │
┌───────────────────────────────────▼─────────────────────────────────────┐
│                        .NET 9 WEB API BACKEND                             │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      API Controllers Layer                       │   │
│  │                                                                   │   │
│  │  ┌──────────────────────┐       ┌────────────────────────┐      │   │
│  │  │   Auth Controller    │       │  Customers Controller  │      │   │
│  │  │   POST /api/auth/    │       │  GET /api/customers    │      │   │
│  │  │        login         │       │  POST /api/customers   │      │   │
│  │  │                      │       │  PUT /api/customers/:id│      │   │
│  │  └──────────────────────┘       │  DELETE /api/customers │      │   │
│  │                                  └────────────────────────┘      │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│                                    │                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                  Middleware & Authentication                     │   │
│  │                                                                   │   │
│  │  ┌───────────────────────────────────────────────────────┐      │   │
│  │  │          JWT Bearer Authentication                    │      │   │
│  │  │          - Token validation                           │      │   │
│  │  │          - Claims-based authorization                 │      │   │
│  │  └───────────────────────────────────────────────────────┘      │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│                                    │                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                       Business Logic Layer                       │   │
│  │                                                                   │   │
│  │  ┌──────────────────────┐       ┌────────────────────────┐      │   │
│  │  │    Auth Service      │       │   Customer Service     │      │   │
│  │  │  - User auth         │       │   - CRUD operations    │      │   │
│  │  │  - Password hashing  │       │   - Validation         │      │   │
│  │  │  - JWT generation    │       │   - Business rules     │      │   │
│  │  └──────────────────────┘       └────────────────────────┘      │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│                                    │                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      Data Access Layer                           │   │
│  │                                                                   │   │
│  │  ┌───────────────────────────────────────────────────────┐      │   │
│  │  │          Entity Framework Core (EF Core)              │      │   │
│  │  │          ApplicationDbContext                         │      │   │
│  │  │          - DbSet<User>                                │      │   │
│  │  │          - DbSet<Customer>                            │      │   │
│  │  └───────────────────────────────────────────────────────┘      │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│                                    │                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                         Models/Entities                          │   │
│  │                                                                   │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐      │   │
│  │  │    User      │  │   Customer   │  │   DTOs           │      │   │
│  │  │  - Id        │  │  - Number    │  │  - LoginRequest  │      │   │
│  │  │  - Username  │  │  - Name      │  │  - LoginResponse │      │   │
│  │  │  - Password  │  │  - DOB       │  │  - CustomerDto   │      │   │
│  │  │  - FullName  │  │  - Gender    │  │  - ApiResponse   │      │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────┘      │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                           │
└───────────────────────────────────▼───────────────────────────────────┘
                                    │
                                    │
                          ┌─────────▼──────────┐
                          │   SQLite Database  │
                          │                    │
                          │  ┌──────────────┐ │
                          │  │ Users Table  │ │
                          │  └──────────────┘ │
                          │  ┌──────────────┐ │
                          │  │ Customers    │ │
                          │  │ Table        │ │
                          │  └──────────────┘ │
                          └────────────────────┘
```

## Communication Flow

### 1. Authentication Flow

```
┌─────────┐                  ┌────────────┐                  ┌──────────┐
│  User   │                  │  Flutter   │                  │  .NET    │
│         │                  │   App      │                  │   API    │
└────┬────┘                  └─────┬──────┘                  └────┬─────┘
     │                             │                              │
     │  1. Enter credentials       │                              │
     ├────────────────────────────>│                              │
     │                             │                              │
     │                             │  2. POST /api/auth/login     │
     │                             │  { username, password }      │
     │                             ├─────────────────────────────>│
     │                             │                              │
     │                             │  3. Validate credentials     │
     │                             │     (BCrypt verify)          │
     │                             │                              │
     │                             │  4. Generate JWT token       │
     │                             │                              │
     │                             │  5. Return token & user info │
     │                             │<─────────────────────────────┤
     │                             │                              │
     │  6. Store token in          │                              │
     │     secure storage          │                              │
     │                             │                              │
     │  7. Navigate to home        │                              │
     │<────────────────────────────┤                              │
     │                             │                              │
```

### 2. Customer Management Flow

```
┌─────────┐                  ┌────────────┐                  ┌──────────┐
│  User   │                  │  Flutter   │                  │  .NET    │
│         │                  │   App      │                  │   API    │
└────┬────┘                  └─────┬──────┘                  └────┬─────┘
     │                             │                              │
     │  1. Request customer list   │                              │
     ├────────────────────────────>│                              │
     │                             │                              │
     │                             │  2. GET /api/customers       │
     │                             │     Authorization: Bearer    │
     │                             │     <JWT-TOKEN>              │
     │                             ├─────────────────────────────>│
     │                             │                              │
     │                             │  3. Validate JWT token       │
     │                             │                              │
     │                             │  4. Query database           │
     │                             │                              │
     │                             │  5. Return customer list     │
     │                             │<─────────────────────────────┤
     │                             │                              │
     │  6. Display customer list   │                              │
     │<────────────────────────────┤                              │
     │                             │                              │
     │  7. Add/Edit customer       │                              │
     ├────────────────────────────>│                              │
     │                             │                              │
     │                             │  8. POST/PUT /api/customers  │
     │                             │     Authorization: Bearer    │
     │                             │     { customerData }         │
     │                             ├─────────────────────────────>│
     │                             │                              │
     │                             │  9. Validate data            │
     │                             │  10. Save to database        │
     │                             │                              │
     │                             │  11. Return updated customer │
     │                             │<─────────────────────────────┤
     │                             │                              │
     │  12. Update UI with new data│                              │
     │<────────────────────────────┤                              │
     │                             │                              │
```

## Security Architecture

### Authentication & Authorization

- **JWT Token-based Authentication**
  - Tokens generated with HS256 algorithm
  - 60-minute expiration
  - Stored securely in Flutter Secure Storage
  - Sent in Authorization header: `Bearer <token>`

- **Password Security**
  - BCrypt hashing with salt
  - No plain-text password storage
  - Server-side validation

- **API Security**
  - CORS enabled for Flutter client
  - HTTPS recommended for production
  - All customer endpoints require authentication

## Data Models

### User
```
- Id: int (Primary Key)
- Username: string (Unique, Max 100)
- PasswordHash: string
- FullName: string (Max 255)
- CreatedAt: DateTime
```

### Customer
```
- CustomerNumber: int (Primary Key, 9 digits, Unique)
- CustomerName: string (Max 255, Required)
- DateOfBirth: DateTime (Required)
- Gender: string (1 char, 'M' or 'F', Required)
- CreatedAt: DateTime
- UpdatedAt: DateTime?
```

## Technology Stack

### Frontend
- **Framework**: Flutter 3.35.5
- **Language**: Dart 3.9.2
- **State Management**: Provider
- **HTTP Client**: http package
- **Secure Storage**: flutter_secure_storage
- **UI**: Material Design 3

### Backend
- **Framework**: .NET 9
- **Language**: C#
- **Architecture**: Clean Architecture (Controllers → Services → Data Access)
- **ORM**: Entity Framework Core 9.0
- **Authentication**: JWT Bearer Authentication
- **Password Hashing**: BCrypt.Net
- **API Documentation**: Swagger/OpenAPI

### Database
- **Database**: SQLite
- **File**: banking.db
- **Tables**: Users, Customers

## Deployment Considerations

### Development
- Backend runs on localhost:5000
- Flutter app connects via configured base URL
- SQLite database file created automatically

### Production
- Use HTTPS for all communications
- Update JWT secret key
- Configure proper CORS origins
- Use production-grade database (PostgreSQL/SQL Server)
- Implement rate limiting
- Add logging and monitoring
- Deploy backend to cloud (Azure, AWS, etc.)
- Deploy Flutter web to hosting service
