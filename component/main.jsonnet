// main template for openshift4-dns
local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();

// The hiera parameters for the component
local params = inv.parameters.openshift4_dns;

// ciliumLocalRedirects
local localRedirectEnabled = std.member(inv.applications, 'cilium') &&
                             std.get(inv.parameters.cilium.cilium_helm_values, 'localRedirectPolicy', false) &&
                             params.ciliumLocalRedirects.enabled;

local localRedirectCR = kube._Object('cilium.io/v2', 'CiliumLocalRedirectPolicy', 'dns-default') {
  metadata+: {
    namespace: params.namespace,
  },
  spec: {
    redirectBackend: {
      localEndpointSelector: {
        matchLabels: {
          'dns.operator.openshift.io/daemonset-dns': 'default',
        },
      },
      toPorts: [
        {
          name: 'dns',
          port: '5353',
          protocol: 'UDP',
        },
        {
          name: 'dns-tcp',
          port: '5353',
          protocol: 'TCP',
        },
      ],
    },
    redirectFrontend: {
      serviceMatcher: {
        namespace: params.namespace,
        serviceName: 'dns-default',
      },
    },
  } + com.makeMergeable(params.ciliumLocalRedirects.spec),
};

// Define outputs below
{
  [if localRedirectEnabled then '10_cilium_localredirect']: localRedirectCR,
}
