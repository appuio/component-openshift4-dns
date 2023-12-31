local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.openshift4_dns;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('openshift4-dns', params.namespace);

{
  'openshift4-dns': app,
}
