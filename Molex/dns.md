1. dns

   10.221.164.10 => home.cdu.molex.com;
   10.221.164.11 => nexus.cdu.molex.com;
   10.221.164.12 => api.cdu.molex.com;
   10.221.164.13 => jenkins.cdu.molex.com;
   10.221.164.14 => app.cdu.molex.com;
   10.221.164.15 => dashboard.cdu.molex.com;
   10.221.164.20 => nginx.cdu.molex.com;

#### Update

> If there's already had DNS records on below machines, please remove the old one.
> 10.221.165.49 => elk.cdu.molex.com
> 10.221.165.49 => es.cdu.molex.com
> 10.221.165.49 => logstash.cdu.molex.com
> 10.221.165.49 => kibana.cdu.molex.com
>
> 10.221.165.47 => jenkins.cdu.molex.com
> 10.221.165.47 => nexus.cdu.molex.com
> 10.221.165.47 => prometheus.cdu.molex.com
> 10.221.165.47 => pushgateway.prometheus.cdu.molex.com
> 10.221.165.47 => grafana.cdu.molex.com
> 10.221.165.47 => zipkin.cdu.molex.com
> 10.221.165.47 => sql.cdu.molex.com
> 10.221.165.47 => docker.cdu.molex.com
> 10.221.165.47 => kafka.cdu.molex.com
> 10.221.165.47 => auth.cdu.molex.com
>
> 10.221.164.61 => apisix.cdu.molex.com

---

Add:

> 10.221.164.24 => app.cduqa.molex.com;

> 10.221.165.47 => auth.cduqa.molex.com

> Update:
> 10.221.165.49 => zipkin.cdu.molex.com

> Add:
> 10.221.165.47 => test.cduappqa.molex.com
> 10.221.165.47 => test.cduapp.molex.com
> 10.221.164.61 => test.cduapi.molx.com
> 10.221.164.61 => test.cduapiqa.molx.com
>
> 10.221.165.49 => openobserve.cdu.molex.com
> 10.221.165.49 => openobserve-api.cdu.molex.com
> 10.221.165.49 => opentelemetry-collector.cdu.molex.com

<br/>

2024-12-12

> Add new:
> 10.221.165.47 => nacos.cdu.molex.com
> Update:
> 10.221.165.47 => test.cduapi.molx.com
> 10.221.165.47 => test.cduapiqa.molx.com

2024-12-17:

> Update:
> auth.cdu.molex.com => 10.175.2.77
> auth.cduqa.molex.com => 10.221.165.35

2025-1-16

> gitlabrunner.cdu.molex.com => 10.221.164.16

2025-1-20:

> employee.cduqaapi.molex.com
> wechat.cduqaapi.molex.com
> sap.cduqaapi.molex.com
> dcc.cduqaapi.molex.com
> approvalcenter.cduqaapi.molex.com
>
> employee.cduapi.molex.com
> wechat.cduapi.molex.com
> sap.cduapi.molex.com
> dcc.cduapi.molex.com
> approvalcenter.cduapi.molex.com
>
> all point to:
> => 10.221.165.47

> 2025-07-22
> https://kochprod.service-now.com/compass?id=ticket&table=sc_req_item&sys_id=846829c79372e6509a2c78fdfaba1053&view=sp
> intool.cdu.molex.com,
> intool.cduqa.molex.com
> => 10.221.165.47

> 2025-7-24
> https://kochprod.service-now.com/compass?id=ticket&table=sc_req_item&sys_id=ed3c0fa7c3be6a902239257dc0013107&view=sp
> auth.cdu.molex.com from ip: 10.175.2.77(old) to new ip 10.221.165.43(host mlxcduvwpapp03.molex.com)

> 2025-8-6
> https://kochprod.service-now.com/compass?id=ticket&table=sc_req_item&sys_id=962dc7fb93cfea90ac9db9847aba103a&view=sp
> h5m.cdu.molex.com,
> h5m.cduqa.molex.com,
> h5mw.cdu.molex.com,
> h5mw.cduqa.molex.com
> => 10.221.165.47
