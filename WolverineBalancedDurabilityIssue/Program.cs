using Marten;
using Wolverine;
using Wolverine.Marten;
using Wolverine.RabbitMQ;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseWolverine(options =>
{
    options.UseRabbitMq(connectionFactory =>
    {
        connectionFactory.HostName = "localhost";
        connectionFactory.Port = 5672;
    });

    options.Publish(rules =>
    {
        rules.Message<TestMessage>();
        rules.ToRabbitTopics("test.exchange");
    });

    options.Durability.Mode = DurabilityMode.Balanced;
});

var dbConnectionString =
    "Server=localhost;Port=5433;User Id=postgres;Password=postgres;Database=postgres";

builder.Services
    .AddMarten(options => options.Connection(dbConnectionString))
    .IntegrateWithWolverine();

// Suppress disturbing Info logs showing executed SQL commands
// To reenable just comment below line
builder.Logging.AddFilter("Npgsql.Command", LogLevel.Warning);

var app = builder.Build();

app.Run();

public record TestMessage;
