Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5640 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079Ab2E2PEj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 11:04:39 -0400
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4TF4dn6020374
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 08:04:39 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 7/8] NFSv4.1: Ensure we use the correct credentials for
 bind_conn_to_session
Date: Tue, 29 May 2012 15:04:37 +0000
Message-ID: <7A549867-5C12-46EF-9564-4EB61CB85736@netapp.com>
References: <1337983402-24677-1-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-2-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-3-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-4-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-5-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-6-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1337983402-24677-7-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_6A82DC80-4967-4944-8C14-3846DE789CDD";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_6A82DC80-4967-4944-8C14-3846DE789CDD
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

This looks good.

-dros

On May 25, 2012, at 6:03 PM, Trond Myklebust wrote:

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Weston Andros Adamson <dros@netapp.com>
> ---
> fs/nfs/nfs4_fs.h   |    2 +-
> fs/nfs/nfs4proc.c  |    3 ++-
> fs/nfs/nfs4state.c |    9 ++++++++-
> 3 files changed, 11 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index a5dbe62..f730730 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -212,7 +212,7 @@ struct vfsmount *nfs4_submount(struct nfs_server =
*, struct dentry *,
> extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned =
short, struct rpc_cred *, struct nfs4_setclientid_res *);
> extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct =
nfs4_setclientid_res *arg, struct rpc_cred *);
> extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, =
struct nfs_fsinfo *);
> -extern int nfs4_proc_bind_conn_to_session(struct nfs_client *);
> +extern int nfs4_proc_bind_conn_to_session(struct nfs_client *, struct =
rpc_cred *cred);
> extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct =
rpc_cred *cred);
> extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
> extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred =
*);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8fa3a36..3fdff0c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5105,7 +5105,7 @@ nfs41_same_server_scope(struct =
nfs41_server_scope *a,
>  * The 4.1 client currently uses the same TCP connection for the
>  * fore and backchannel.
>  */
> -int nfs4_proc_bind_conn_to_session(struct nfs_client *clp)
> +int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct =
rpc_cred *cred)
> {
> 	int status;
> 	struct nfs41_bind_conn_to_session_res res;
> @@ -5114,6 +5114,7 @@ int nfs4_proc_bind_conn_to_session(struct =
nfs_client *clp)
> 			=
&nfs4_procedures[NFSPROC4_CLNT_BIND_CONN_TO_SESSION],
> 		.rpc_argp =3D clp,
> 		.rpc_resp =3D &res,
> +		.rpc_cred =3D cred,
> 	};
>=20
> 	dprintk("--> %s\n", __func__);
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 1587840..7dbca66 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1779,7 +1779,14 @@ static int nfs4_recall_slot(struct nfs_client =
*clp)
>=20
> static int nfs4_bind_conn_to_session(struct nfs_client *clp)
> {
> -	return nfs4_proc_bind_conn_to_session(clp);
> +	struct rpc_cred *cred;
> +	int ret;
> +
> +	cred =3D nfs4_get_exchange_id_cred(clp);
> +	ret =3D nfs4_proc_bind_conn_to_session(clp, cred);
> +	if (cred)
> +		put_rpccred(cred);
> +	return ret;
> }
> #else /* CONFIG_NFS_V4_1 */
> static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
> --=20
> 1.7.7.6
>=20


--Apple-Mail=_6A82DC80-4967-4944-8C14-3846DE789CDD
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MjkxNTAwMjRaMCMGCSqGSIb3DQEJBDEWBBQ2rHkHjm62E8JD
enN6AFe7YEpjZDANBgkqhkiG9w0BAQEFAASCAQA7KnRXYQ+ZaK+7zWHj1cpHYCvDXqAdUTFWJb2g
J+KFy8zzQ83vuGjD/T3aLcgiMByhYjhTzS3uH7/XD7MO3vcgTneieD+p3XIW2HuIgMhfGloN/Eta
5GGnDaudhFwdA2gF6CvZmssZ65ARZlWFDFf/MNh55phludZkPoHP9Bhs8g04L+FfgemrdM/42GkI
Y0rcIbUFOCRs87MQqMZtasw+C9r+ZP4coeOWV01SALFsgWP+0kcUuprsELgvGdqckteIIc4ZwJv3
/mOaFMmZlyXmbijVJR2FNDRcaEx9u9r5wFsh08Oni1z/XuFgWk86Ev2RQibdkc9QxuPrJAl5lADa
AAAAAAAA

--Apple-Mail=_6A82DC80-4967-4944-8C14-3846DE789CDD--
