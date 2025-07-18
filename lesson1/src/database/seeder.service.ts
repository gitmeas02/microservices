import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';

@Injectable()
export class SeederService {
  private readonly logger = new Logger(SeederService.name);

  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async seed() {
    this.logger.log('Starting database seeding...');

    await this.seedUsers();

    this.logger.log('Database seeding completed!');
  }

  private async seedUsers() {
    const userCount = await this.usersRepository.count();
    
    if (userCount === 0) {
      this.logger.log('Seeding users...');
      
      const users = [
        {
          email: 'admin@example.com',
          name: 'Admin User',
        },
        {
          email: 'user@example.com',
          name: 'Regular User',
        },
        {
          email: 'test@example.com',
          name: 'Test User',
        },
      ];

      for (const userData of users) {
        const user = this.usersRepository.create(userData);
        await this.usersRepository.save(user);
        this.logger.log(`Created user: ${userData.email}`);
      }
    } else {
      this.logger.log('Users already exist, skipping user seeding');
    }
  }
}
