@echo off
echo 🌱 Database Seeding Options
echo.
echo 1. API Seeding (HTTP Requests)
echo 2. Direct Database Seeding
echo 3. Container Seeding
echo 4. Reset and Reseed
echo.
set /p choice="Choose seeding method (1-4): "

if "%choice%"=="1" goto api_seed
if "%choice%"=="2" goto db_seed
if "%choice%"=="3" goto container_seed
if "%choice%"=="4" goto reset_seed
goto end

:api_seed
echo.
echo 🚀 API Seeding - Creating users via HTTP requests...
curl -X POST http://localhost:3000/users -H "Content-Type: application/json" -d "{\"email\":\"admin@example.com\",\"name\":\"Admin User\"}"
echo.
curl -X POST http://localhost:3000/users -H "Content-Type: application/json" -d "{\"email\":\"manager@example.com\",\"name\":\"Manager User\"}"
echo.
curl -X POST http://localhost:3000/users -H "Content-Type: application/json" -d "{\"email\":\"developer@example.com\",\"name\":\"Developer User\"}"
echo.
echo ✅ API seeding completed!
goto verify

:db_seed
echo.
echo 🗄️ Direct Database Seeding...
docker-compose -f docker-compose.dev.yml exec postgres psql -U postgres -d nestjs_db -c "INSERT INTO users (email, name) VALUES ('seeded1@example.com', 'Seeded User 1'), ('seeded2@example.com', 'Seeded User 2'), ('seeded3@example.com', 'Seeded User 3') ON CONFLICT (email) DO NOTHING;"
echo ✅ Database seeding completed!
goto verify

:container_seed
echo.
echo 🐳 Container Seeding (via NestJS app)...
docker-compose -f docker-compose.dev.yml exec nestjs-app npm run seed:container
echo ✅ Container seeding completed!
goto verify

:reset_seed
echo.
echo ⚠️  WARNING: This will delete all existing data!
set /p confirm="Are you sure? (y/N): "
if not "%confirm%"=="y" if not "%confirm%"=="Y" goto end
echo.
echo 🔄 Resetting database...
docker-compose -f docker-compose.dev.yml down
docker volume rm lesson1_nest_js_postgres_dev_data
docker-compose -f docker-compose.dev.yml up -d
echo ✅ Database reset completed! Initial seed data from init.sql will be loaded.
echo ⏳ Waiting for services to start...
timeout /t 10 /nobreak >nul
goto verify

:verify
echo.
echo 📊 Current users in database:
curl -s http://localhost:3000/users | echo.
echo.
echo 📈 Total user count:
curl -s http://localhost:3000/users/count
echo.

:end
echo.
pause
