using Marten;
using Wolverine;
using Wolverine.Marten;
using Wolverine.RabbitMQ;

var builder = WebApplication.CreateBuilder(args);

var isRunFromContainer = args.ElementAtOrDefault(0) == "RunFromContainer";
var useSoloMode = args.ElementAtOrDefault(1) == "SoloMode";

builder.Host.UseWolverine(options =>
{
    options.UseRabbitMq(connectionFactory =>
    {
        connectionFactory.HostName = isRunFromContainer ? "rabbit" : "localhost";
        connectionFactory.Port = isRunFromContainer ? 5672 : 25672;
        connectionFactory.UserName = "username";
        connectionFactory.Password = "password";
    });

    options.Publish(rules =>
    {
        rules.Message<TestMessage>();
        rules.ToRabbitTopics("test.exchange");
    });

    // If Solo mode is used instead of Balanced app is able to start
    if (useSoloMode)
        options.Durability.Mode = DurabilityMode.Solo;
});

var dbConnectionString = isRunFromContainer
    ? "Server=postgres;Port=5432;User Id=username;Password=password;Database=test"
    : "Server=localhost;Port=15432;User Id=username;Password=password;Database=test";

builder.Services
    .AddMarten(options => options.Connection(dbConnectionString))
    .IntegrateWithWolverine();

// Suppress disturbing Info logs showing executed SQL commands
// To reenable just comment below line
builder.Logging.AddFilter("Npgsql.Command", LogLevel.Warning);

var app = builder.Build();

app.Run();

public record TestMessage;
