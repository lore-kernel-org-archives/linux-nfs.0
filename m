Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16239 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799Ab2EUPG4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 May 2012 11:06:56 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 03/14] NFS: Use proper naming conventions for
 nfs_client.impl_id field
Date: Mon, 21 May 2012 15:06:54 +0000
Message-ID: <4FCE9C2E-6E0C-4794-A922-36F69EB78CD1@netapp.com>
References: <20120518220145.774.53741.stgit@degas.1015granger.net>
 <20120518220541.774.82062.stgit@degas.1015granger.net>
In-Reply-To: <20120518220541.774.82062.stgit@degas.1015granger.net>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_4652ECF1-5359-407C-9F94-EB872C825919";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_4652ECF1-5359-407C-9F94-EB872C825919
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

This looks good to me.

-dros

On May 18, 2012, at 6:05 PM, Chuck Lever wrote:

> Clean up:  When naming fields and data types, follow established
> conventions to facilitate accurate grep/cscope searches.
>=20
> Additionally, for consistency, move the impl_id field into the NFSv4-
> specific part of the nfs_client, and free that memory in the logic
> that shuts down NFSv4 nfs_clients.
>=20
> Introduced by commit 7d2ed9ac "NFSv4: parse and display server
> implementation ids," Fri Feb 17, 2012.
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>=20
> fs/nfs/client.c           |    2 +-
> fs/nfs/nfs4proc.c         |   12 ++++++------
> fs/nfs/super.c            |    4 ++--
> include/linux/nfs_fs_sb.h |    2 +-
> 4 files changed, 10 insertions(+), 10 deletions(-)
>=20
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 1285f70..ec5a276 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -236,6 +236,7 @@ static void nfs4_shutdown_client(struct nfs_client =
*clp)
>=20
> 	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
> 	kfree(clp->cl_serverscope);
> +	kfree(clp->cl_implid);
> }
>=20
> /* idr_remove_all is not needed as all id's are removed by =
nfs_put_client */
> @@ -304,7 +305,6 @@ static void nfs_free_client(struct nfs_client =
*clp)
>=20
> 	put_net(clp->net);
> 	kfree(clp->cl_hostname);
> -	kfree(clp->impl_id);
> 	kfree(clp);
>=20
> 	dprintk("<-- nfs_free_client()\n");
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 35585ef..386a756 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5147,8 +5147,8 @@ int nfs4_proc_exchange_id(struct nfs_client =
*clp, struct rpc_cred *cred)
>=20
> 	if (!status) {
> 		/* use the most recent implementation id */
> -		kfree(clp->impl_id);
> -		clp->impl_id =3D res.impl_id;
> +		kfree(clp->cl_implid);
> +		clp->cl_implid =3D res.impl_id;
> 	} else
> 		kfree(res.impl_id);
>=20
> @@ -5172,12 +5172,12 @@ int nfs4_proc_exchange_id(struct nfs_client =
*clp, struct rpc_cred *cred)
> out_server_scope:
> 	kfree(res.server_scope);
> out:
> -	if (clp->impl_id)
> +	if (clp->cl_implid)
> 		dprintk("%s: Server Implementation ID: "
> 			"domain: %s, name: %s, date: %llu,%u\n",
> -			__func__, clp->impl_id->domain, =
clp->impl_id->name,
> -			clp->impl_id->date.seconds,
> -			clp->impl_id->date.nseconds);
> +			__func__, clp->cl_implid->domain, =
clp->cl_implid->name,
> +			clp->cl_implid->date.seconds,
> +			clp->cl_implid->date.nseconds);
> 	dprintk("<-- %s status=3D %d\n", __func__, status);
> 	return status;
> }
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 4ac7fca..2c5390e 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -786,8 +786,8 @@ static void show_pnfs(struct seq_file *m, struct =
nfs_server *server)
>=20
> static void show_implementation_id(struct seq_file *m, struct =
nfs_server *nfss)
> {
> -	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
> -		struct nfs41_impl_id *impl_id =3D =
nfss->nfs_client->impl_id;
> +	if (nfss->nfs_client && nfss->nfs_client->cl_implid) {
> +		struct nfs41_impl_id *impl_id =3D =
nfss->nfs_client->cl_implid;
> 		seq_printf(m, "\n\timpl_id:\tname=3D'%s',domain=3D'%s',"
> 			   "date=3D'%llu,%u'",
> 			   impl_id->name, impl_id->domain,
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 900d733..773e021 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -81,13 +81,13 @@ struct nfs_client {
> 	u32			cl_exchange_flags;
> 	struct nfs4_session	*cl_session;	/* shared session */
> 	struct nfs41_server_scope *cl_serverscope;
> +	struct nfs41_impl_id	*cl_implid;
> #endif /* CONFIG_NFS_V4 */
>=20
> #ifdef CONFIG_NFS_FSCACHE
> 	struct fscache_cookie	*fscache;	/* client index cache =
cookie */
> #endif
>=20
> -	struct nfs41_impl_id	*impl_id;	/* from exchange_id */
> 	struct net		*net;
> };
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_4652ECF1-5359-407C-9F94-EB872C825919
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MjExNTA2NTRaMCMGCSqGSIb3DQEJBDEWBBQO5HTypIqAQ2/a
kxSciqlO8IorCjANBgkqhkiG9w0BAQEFAASCAQCGBjDbga3FQbXvYpbJaWtBnxUZV3WqwEHt2hGg
8NgNS7OzS8Be3iVFysAiKwKgB1ZKpLlpQD7og0VMY4Za8k1SgQm3fhhpQFQa1JidI1c+xoFFlWX4
tRW9EvKmp8f9KfZAjrJWZwANyMumeJ5ninH/gz2jVd4oECoHA5fyuAwYHApTq31wjqizzt0muwrH
kcXHRLMB9o1LJcOgXu7BsTsvVx/sRIujTBEabjGrmRnIR7wUlr5fKMvbH50ABCmiRn9bl1i6ZlET
s4swZKulyNy/4S71R5YXb1T6yLphkBdCDkDlWKNCaKbrlSGsEzYT+Hq4VynIFHPur8qDVHTo1yda
AAAAAAAA

--Apple-Mail=_4652ECF1-5359-407C-9F94-EB872C825919--
