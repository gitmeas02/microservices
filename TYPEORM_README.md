# TypeORM Setup Guide for NestJS

This guide explains how to use TypeORM with your NestJS application in Docker environment.

## 🗃️ Database Setup

### Dependencies Added

```json
{
  "dependencies": {
    "@nestjs/typeorm": "^10.0.1",
    "@nestjs/config": "^3.2.0",
    "typeorm": "^0.3.20",
    "pg": "^8.11.3",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.1",
    "dotenv": "^16.4.5"
  },
  "devDependencies": {
    "@types/pg": "^8.11.2"
  }
}
```

### Configuration

TypeORM is configured in `src/app.module.ts` with:
- Automatic entity discovery
- Development/Production configurations
- Database connection from environment variables

## 📁 Project Structure

```
src/
├── database/
│   ├── data-source.ts          # TypeORM configuration
│   ├── seeder.service.ts       # Database seeding
│   └── migrations/             # Database migrations
├── entities/
│   └── user.entity.ts          # Example entity
├── users/
│   ├── dto/
│   │   └── user.dto.ts         # Data Transfer Objects
│   ├── users.controller.ts     # API endpoints
│   ├── users.service.ts        # Business logic
│   └── users.module.ts         # Module definition
└── app.module.ts               # Main application module
```

## 🚀 Getting Started

### 1. Start Development Environment

```bash
# Install dependencies first (the packages will be installed when container starts)
docker-compose -f docker-compose.dev.yml up -d

# Or using Makefile
make dev
```

### 2. Install Dependencies

Once the container is running, install the new dependencies:

```bash
# Access the container
docker-compose -f docker-compose.dev.yml exec nestjs-app sh

# Install dependencies
npm install

# Exit container
exit
```

### 3. Restart the Application

```bash
# Restart to apply new dependencies
docker-compose -f docker-compose.dev.yml restart nestjs-app
```

## 🗄️ Database Operations

### Available Scripts

```bash
# Inside the container or local development
npm run typeorm -- --help                    # TypeORM CLI help
npm run migration:generate MyMigration        # Generate migration
npm run migration:run                         # Run migrations
npm run migration:revert                      # Revert last migration
npm run schema:sync                           # Sync schema (dev only)
npm run schema:drop                           # Drop schema (danger!)
```

### Using Docker

```bash
# Run migrations in container
docker-compose -f docker-compose.dev.yml exec nestjs-app npm run migration:run

# Generate new migration
docker-compose -f docker-compose.dev.yml exec nestjs-app npm run migration:generate UserUpdate

# Access database directly
docker-compose -f docker-compose.dev.yml exec postgres psql -U postgres -d nestjs_db
```

## 🏗️ Entity Example

```typescript
// src/entities/user.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  name: string;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

## 📝 DTO Example

```typescript
// src/users/dto/user.dto.ts
import { IsEmail, IsNotEmpty, IsString, IsBoolean, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  name: string;
}

export class UpdateUserDto {
  @IsEmail()
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  name?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
```

## 🎯 API Endpoints

The User module provides these endpoints:

```
GET    /users          # Get all users
GET    /users/count    # Get user count
GET    /users/:id      # Get user by ID
POST   /users          # Create new user
PATCH  /users/:id      # Update user
DELETE /users/:id      # Delete user
```

### Example Requests

```bash
# Create user
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"email": "newuser@example.com", "name": "New User"}'

# Get all users
curl http://localhost:3000/users

# Get user by ID
curl http://localhost:3000/users/123e4567-e89b-12d3-a456-426614174000

# Update user
curl -X PATCH http://localhost:3000/users/123e4567-e89b-12d3-a456-426614174000 \
  -H "Content-Type: application/json" \
  -d '{"name": "Updated Name"}'

# Delete user
curl -X DELETE http://localhost:3000/users/123e4567-e89b-12d3-a456-426614174000
```

## 🔧 Configuration

### Environment Variables

```env
# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=password
DB_NAME=nestjs_db

# Application
NODE_ENV=development
```

### TypeORM Configuration

```typescript
// src/database/data-source.ts
export default new DataSource({
  type: 'postgres',
  host: configService.get('DB_HOST', 'localhost'),
  port: configService.get('DB_PORT', 5432),
  username: configService.get('DB_USERNAME', 'postgres'),
  password: configService.get('DB_PASSWORD', 'password'),
  database: configService.get('DB_NAME', 'nestjs_db'),
  entities: ['src/**/*.entity{.ts,.js}'],
  migrations: ['src/database/migrations/*{.ts,.js}'],
  synchronize: configService.get('NODE_ENV') === 'development',
  logging: configService.get('NODE_ENV') === 'development',
});
```

## 🔍 Health Check

The health endpoint now includes database status:

```bash
curl http://localhost:3000/health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2025-07-18T10:30:00.000Z",
  "uptime": 123.456,
  "environment": "development",
  "version": "1.0.0",
  "database": {
    "status": "connected",
    "latency": "5ms"
  }
}
```

## 🧪 Testing

### Unit Tests

```typescript
// Example test for UserService
describe('UsersService', () => {
  let service: UsersService;
  let repository: Repository<User>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: getRepositoryToken(User),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repository = module.get<Repository<User>>(getRepositoryToken(User));
  });

  it('should create a user', async () => {
    const createUserDto = { email: 'test@example.com', name: 'Test User' };
    const result = await service.create(createUserDto);
    expect(result).toBeDefined();
  });
});
```

### Integration Tests

```bash
# Run tests in container
docker-compose -f docker-compose.dev.yml exec nestjs-app npm test

# Run e2e tests
docker-compose -f docker-compose.dev.yml exec nestjs-app npm run test:e2e
```

## 🔄 Migrations

### Creating Migrations

```bash
# Generate migration from entity changes
npm run migration:generate AddUserTable

# Create empty migration
npm run typeorm migration:create src/database/migrations/AddUserIndex
```

### Migration Example

```typescript
import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUserIndex1705680000000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE INDEX "IDX_user_email" ON "users" ("email")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP INDEX "IDX_user_email"
    `);
  }
}
```

## 🚀 Production Deployment

For production:

1. **Disable synchronize**: Set `synchronize: false` in production
2. **Run migrations**: Use `npm run migration:run` in deployment script
3. **Environment variables**: Set proper production database credentials
4. **SSL**: Enable SSL for database connections

```bash
# Production deployment with migrations
docker-compose -f docker-compose.prod.yml up -d postgres
docker-compose -f docker-compose.prod.yml exec postgres pg_isready
docker-compose -f docker-compose.prod.yml run --rm nestjs-app npm run migration:run
docker-compose -f docker-compose.prod.yml up -d
```

## 🛠️ Troubleshooting

### Common Issues

1. **Module not found errors**: Install dependencies in container
   ```bash
   docker-compose exec nestjs-app npm install
   ```

2. **Database connection failed**: Check if PostgreSQL is running
   ```bash
   docker-compose ps postgres
   docker-compose logs postgres
   ```

3. **Migration errors**: Check database permissions and connection
   ```bash
   docker-compose exec nestjs-app npm run typeorm -- query "SELECT version()"
   ```

4. **Entity not found**: Ensure entity path is correct in TypeORM config

### Debug Mode

```bash
# Enable TypeORM logging
LOG_LEVEL=debug docker-compose -f docker-compose.dev.yml up

# Run queries manually
docker-compose exec postgres psql -U postgres -d nestjs_db
```

## 📚 Additional Resources

- [TypeORM Documentation](https://typeorm.io/)
- [NestJS TypeORM Integration](https://docs.nestjs.com/techniques/database)
- [Class Validator Documentation](https://github.com/typestack/class-validator)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 🤝 Best Practices

1. **Always use migrations in production**
2. **Validate input data with DTOs**
3. **Use transactions for complex operations**
4. **Index frequently queried columns**
5. **Use connection pooling for performance**
6. **Backup database regularly**
7. **Monitor query performance**
