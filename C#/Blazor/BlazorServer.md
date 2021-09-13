## Windows Authentication
### Get Username

Project property => Debug => IIS Express => Windows Authentication Allow

```cs
    services.AddHttpContextAccessor();

    [Inject]
    IHttpContextAccessor _httpContextAccessor { get; set; }

    protected override async Task OnInitializedAsync()
    {
        userName = _httpContextAccessor.HttpContext.User.Identity.Name;
    }
```
