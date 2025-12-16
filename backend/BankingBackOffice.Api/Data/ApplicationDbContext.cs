using BankingBackOffice.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace BankingBackOffice.Api.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Customer> Customers { get; set; }
    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Customer entity
        modelBuilder.Entity<Customer>(entity =>
        {
            entity.HasKey(e => e.CustomerNumber);

            entity.Property(e => e.CustomerNumber)
                .ValueGeneratedNever(); // Customer number is manually assigned

            entity.HasIndex(e => e.CustomerNumber).IsUnique();

            entity.Property(e => e.CustomerName)
                .IsRequired()
                .HasMaxLength(255);

            entity.Property(e => e.Gender)
                .IsRequired()
                .HasMaxLength(1);

            entity.Property(e => e.DateOfBirth)
                .IsRequired();
        });

        // Configure User entity
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.HasIndex(e => e.Username).IsUnique();

            entity.Property(e => e.Username)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(e => e.PasswordHash)
                .IsRequired();

            entity.Property(e => e.FullName)
                .HasMaxLength(255);
        });
    }
}
