Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19242 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab2EUPKo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 May 2012 11:10:44 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 05/14] NFS: Clean up return code checking in
 nfs4_proc_exchange_id()
Date: Mon, 21 May 2012 15:10:40 +0000
Message-ID: <540BBC20-D78C-4E60-8AEB-BF4125705363@netapp.com>
References: <20120518220145.774.53741.stgit@degas.1015granger.net>
 <20120518220558.774.61431.stgit@degas.1015granger.net>
In-Reply-To: <20120518220558.774.61431.stgit@degas.1015granger.net>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_692637EB-4605-408D-AC1C-8F0C793E5EDA";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_692637EB-4605-408D-AC1C-8F0C793E5EDA
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On May 18, 2012, at 6:05 PM, Chuck Lever wrote:

> Clean up: prefer using the proper types in "if" expressions.

Is that the preferred style?  I certainly prefer it (being raised on =
openbsd style(9)) , but when I wrote the code below I was trying to =
follow the style of most of fs/nfs.

-dros

>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>=20
> fs/nfs/nfs4proc.c |   16 ++++++++--------
> 1 files changed, 8 insertions(+), 8 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 386a756..db7b76a 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5130,30 +5130,30 @@ int nfs4_proc_exchange_id(struct nfs_client =
*clp, struct rpc_cred *cred)
>=20
> 	res.server_scope =3D kzalloc(sizeof(struct nfs41_server_scope),
> 					GFP_KERNEL);
> -	if (unlikely(!res.server_scope)) {
> +	if (unlikely(res.server_scope =3D=3D NULL)) {
> 		status =3D -ENOMEM;
> 		goto out;
> 	}
>=20
> 	res.impl_id =3D kzalloc(sizeof(struct nfs41_impl_id), =
GFP_KERNEL);
> -	if (unlikely(!res.impl_id)) {
> +	if (unlikely(res.impl_id =3D=3D NULL)) {
> 		status =3D -ENOMEM;
> 		goto out_server_scope;
> 	}
>=20
> 	status =3D rpc_call_sync(clp->cl_rpcclient, &msg, =
RPC_TASK_TIMEOUT);
> -	if (!status)
> +	if (status =3D=3D 0)
> 		status =3D =
nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
>=20
> -	if (!status) {
> +	if (status =3D=3D 0) {
> 		/* use the most recent implementation id */
> 		kfree(clp->cl_implid);
> 		clp->cl_implid =3D res.impl_id;
> 	} else
> 		kfree(res.impl_id);
>=20
> -	if (!status) {
> -		if (clp->cl_serverscope &&
> +	if (status =3D=3D 0) {
> +		if (clp->cl_serverscope !=3D NULL &&
> 		    !nfs41_same_server_scope(clp->cl_serverscope,
> 					     res.server_scope)) {
> 			dprintk("%s: server_scope mismatch detected\n",
> @@ -5163,7 +5163,7 @@ int nfs4_proc_exchange_id(struct nfs_client =
*clp, struct rpc_cred *cred)
> 			clp->cl_serverscope =3D NULL;
> 		}
>=20
> -		if (!clp->cl_serverscope) {
> +		if (clp->cl_serverscope =3D=3D NULL) {
> 			clp->cl_serverscope =3D res.server_scope;
> 			goto out;
> 		}
> @@ -5172,7 +5172,7 @@ int nfs4_proc_exchange_id(struct nfs_client =
*clp, struct rpc_cred *cred)
> out_server_scope:
> 	kfree(res.server_scope);
> out:
> -	if (clp->cl_implid)
> +	if (clp->cl_implid !=3D NULL)
> 		dprintk("%s: Server Implementation ID: "
> 			"domain: %s, name: %s, date: %llu,%u\n",
> 			__func__, clp->cl_implid->domain, =
clp->cl_implid->name,
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_692637EB-4605-408D-AC1C-8F0C793E5EDA
Content-Disposition: attachment; filename="smime.p7s"
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIDTzCCA0sw
ggIzoAMCAQICAQEwCwYJKoZIhvcNAQEFMEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYD
VQQGEwJVUzEeMBwGCSqGSIb3DQEJARYPZHJvc0BuZXRhcHAuY29tMB4XDTExMDYwODIyMDc0NloX
DTEyMDYwNzIyMDc0NlowRjEXMBUGA1UEAwwOV2VzdG9uIEFkYW1zb24xCzAJBgNVBAYTAlVTMR4w
HAYJKoZIhvcNAQkBFg9kcm9zQG5ldGFwcC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC8/tJxtovJEXYRfSsrFOWKHxIZGY7/2mBee1DpWuoGDbVNapefCC7WXe+Nqxz609w2J/Mk
/k3trZ3Ge2NXK0tGnP9NzjkzpGA7rSpM3wUFsvbLMUEGfQpvV24/nYvcLHTvOOEUaDPpHduN94bD
dwvyowzDIRIpF2MeRnOzBNeHkrGHlZdzPmGjm8tkhrDRRkDYHhlxaiG4z30KCfAazxomuINiy1kj
vbndXooYMDoh9H63hgW4NkOedtLdflLa322DXQ3nFU7YbyOIjHVl1tgWJLDWf7WT3lsAB8KvuJZ5
zhsUB+fqxCKPJVRPDO1gjChvvtGiG1tGUUZz0H9Wx00zAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIH
gDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDBDAaBgNVHREEEzARgQ9kcm9zQG5ldGFwcC5jb20wDQYJ
KoZIhvcNAQEFBQADggEBACv0niZSmW+psB1sJXULh3mecDbN2mj0bFpN1YNdjcV7BiOLJ1Rs1ibV
f13h73z8C7SBsPXTM5si8gmJtOnXM5jsgtlql44h/RrjUr8+mtK5DPCZls9J7iz3cGthzwOPvxUj
nMSv3BpRX5oJom5ESgCM9Nn4u/ECTlLMhEIOYnBFiN0eDxcxz+r1cpbHg3r0otIKyxLpeaCjP6AH
F93EHp4T8Rb63y3CcDgxrQGHlTdVi3QvxaMUexUXD81fiA+UqsB/MKmRxB1Hs4Vf3Q/+ejcm78K1
ROF8TNPmNWRlKg3Y7cSFjZGzLuzXsvSsCbw4HLn0oZe/OfgSbarTAxttL5IxggHRMIIBzQIBATBL
MEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYDVQQGEwJVUzEeMBwGCSqGSIb3DQEJARYP
ZHJvc0BuZXRhcHAuY29tAgEBMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MjExNTEwNDBaMCMGCSqGSIb3DQEJBDEWBBROkkmkpJ1z1qyx
93BP0/buoRHQkjANBgkqhkiG9w0BAQEFAASCAQANt9pq1J+yQpaOE5+FUlbqWuhptAdoH+jcxFIl
P5ahXk7vKGVEkM/T4KIg/+pgkPRUu9KqzhteO0OEyiqcOE8hs29AlY/1A/s0v9ZD+F/OyiClCH/B
zUUR4jYqN0/ipgVANVf2xc4a8bAVoCjniEyQAFcs9QEOWm+bzeOmNbTCAHGcnod5abmpNXsnzEq9
P3nVcl0j4plzb0pGHC8VHXByoMdrK5zREMCPFL9/pNNKZOKyuCBK50QC405jgBwPOM0IKAsZHwN9
rP/VPifzBw1BBvHOV6m/+f7adtTcj3XNJE5RSqjQx6GJegHK8AL3X6AnXSqWczjchm2EmioPJUoG
AAAAAAAA

--Apple-Mail=_692637EB-4605-408D-AC1C-8F0C793E5EDA--
