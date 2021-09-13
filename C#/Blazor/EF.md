## Blazor with Database First

<https://stackoverflow.com/questions/59955735/blazor-with-database-first>

<https://newbedev.com/blazor-with-database-first>

```xml
<PackageReference Include="Microsoft.AspNetCore.Diagnostics.EntityFrameworkCore" Version="3.1.1" />
<PackageReference Include="Microsoft.AspNetCore.Identity.EntityFrameworkCore" Version="3.1.1" />
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="3.1.1" />
<PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="3.1.1">
```

```json
{
  "ConnectionStrings": {
    "MyConnection": "Server=tcp:<yourServer>,1433;Initial Catalog=<yourDatabase>;Persist Security Info=False;User ID=<yourDatabaseUserName>;Password=<yourDatabaseUserPassword>;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
  }
}
```

Scaffold-DbContext -Connection name=MyConnection -Provider Microsoft.EntityFrameworkCore.SqlServer -OutputDir Models -Context MyDbContext -Force
