Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58223 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469Ab2EXQfy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 12:35:54 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs4.1: add BIND_CONN_TO_SESSION operation
Date: Thu, 24 May 2012 16:35:49 +0000
Message-ID: <82E74CF6-E6E3-4C6E-AE25-489B6D474D95@netapp.com>
References: <1337876797-17706-1-git-send-email-dros@netapp.com>
 <F379601B-45BA-411A-B8F9-4EEA918D3693@oracle.com>
In-Reply-To: <F379601B-45BA-411A-B8F9-4EEA918D3693@oracle.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_3088575F-722C-45A6-86CD-224B787EFB7D";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_3088575F-722C-45A6-86CD-224B787EFB7D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On May 24, 2012, at 12:30 PM, Chuck Lever wrote:

>=20
> On May 24, 2012, at 12:26 PM, Weston Andros Adamson wrote:
>=20
>> This patch adds the BIND_CONN_TO_SESSION operation which is needed =
for
>> upcoming SP4_MACH_CRED work and useful for recovering from broken =
connections
>> without destroying the session.
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfs/nfs4_fs.h        |    1 +
>> fs/nfs/nfs4proc.c       |   54 ++++++++++++++++++++++++++++
>> fs/nfs/nfs4xdr.c        |   90 =
+++++++++++++++++++++++++++++++++++++++++++++++
>> include/linux/nfs4.h    |    5 +++
>> include/linux/nfs_xdr.h |    6 +++
>> 5 files changed, 156 insertions(+), 0 deletions(-)
>>=20
>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>> index edeef71..ad90bc7 100644
>> --- a/fs/nfs/nfs4_fs.h
>> +++ b/fs/nfs/nfs4_fs.h
>> @@ -215,6 +215,7 @@ struct vfsmount *nfs4_submount(struct nfs_server =
*, struct dentry *,
>> extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned =
short, struct rpc_cred *, struct nfs4_setclientid_res *);
>> extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct =
nfs4_setclientid_res *arg, struct rpc_cred *);
>> extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, =
struct nfs_fsinfo *);
>> +extern int nfs4_proc_bind_conn_to_session(struct nfs_client *);
>> extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct =
rpc_cred *cred);
>> extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred =
*);
>> extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred =
*);
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 78784e5..7a4b320 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5062,6 +5062,60 @@ nfs41_same_server_scope(struct server_scope =
*a, struct server_scope *b)
>> }
>>=20
>> /*
>> + * nfs4_proc_bind_conn_to_session()
>> + *
>> + * The 4.1 client currently uses the same TCP connection for the
>> + * fore and backchannel.
>> + */
>> +int nfs4_proc_bind_conn_to_session(struct nfs_client *clp)
>> +{
>> +	int status;
>> +	struct nfs41_bind_conn_to_session_res res;
>> +	struct rpc_message msg =3D {
>> +		.rpc_proc =3D
>> +			=
&nfs4_procedures[NFSPROC4_CLNT_BIND_CONN_TO_SESSION],
>> +		.rpc_argp =3D clp,
>> +		.rpc_resp =3D &res,
>> +	};
>> +
>> +	dprintk("--> %s\n", __func__);
>> +	BUG_ON(clp =3D=3D NULL);
>> +
>> +	res.session =3D kzalloc(sizeof(struct nfs4_session), =
GFP_KERNEL);
>> +	if (unlikely(res.session =3D=3D NULL)) {
>> +		status =3D -ENOMEM;
>> +		goto out;
>> +	}
>> +
>> +	status =3D rpc_call_sync(clp->cl_rpcclient, &msg, =
RPC_TASK_TIMEOUT);
>> +	if (status =3D=3D 0) {
>> +		if (memcmp(res.session->sess_id.data,
>> +		    clp->cl_session->sess_id.data, =
NFS4_MAX_SESSIONID_LEN)) {
>> +			dprintk("NFS: %s: Session ID mismatch\n", =
__func__);
>> +			status =3D -EIO;
>> +			goto out_session;
>> +		}
>> +		if (res.dir !=3D CDFS4_BOTH) {
>> +			dprintk("NFS: %s: Unexpected direction from =
server\n",
>> +				__func__);
>> +			status =3D -EIO;
>> +			goto out_session;
>> +		}
>> +		if (res.use_conn_in_rdma_mode !=3D 0) {
>> +			dprintk("NFS: %s: Server returned RDMA mode =3D =
true\n",
>> +				__func__);
>> +			status =3D -EIO;
>> +			goto out_session;
>> +		}
>> +	}
>> +out_session:
>> +	kfree(res.session);
>> +out:
>> +	dprintk("<-- %s status=3D %d\n", __func__, status);
>> +	return status;
>> +}
>> +
>> +/*
>> * nfs4_proc_exchange_id()
>> *
>> * Since the clientid has expired, all compounds using sessions
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index db040e9..37e09c8 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -321,6 +321,16 @@ static int nfs4_stat_to_errno(int);
>> 				     1 /* csr_flags */ + \
>> 				     decode_channel_attrs_maxsz + \
>> 				     decode_channel_attrs_maxsz)
>> +#define encode_bind_conn_to_session_maxsz  (op_encode_hdr_maxsz + \
>> +				     /* bctsa_sessid */ \
>> +				     XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) =
+ \
>> +				     1 /* bctsa_dir */ + \
>> +				     1 /* bctsa_use_conn_in_rdma_mode =
*/)
>> +#define decode_bind_conn_to_session_maxsz  (op_decode_hdr_maxsz +	=
\
>> +				     /* bctsr_sessid */ \
>> +				     XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) =
+ \
>> +				     1 /* bctsr_dir */ + \
>> +				     1 /* bctsr_use_conn_in_rdma_mode =
*/)
>> #define encode_destroy_session_maxsz    (op_encode_hdr_maxsz + 4)
>> #define decode_destroy_session_maxsz    (op_decode_hdr_maxsz)
>> #define encode_sequence_maxsz	(op_encode_hdr_maxsz + \
>> @@ -714,6 +724,12 @@ static int nfs4_stat_to_errno(int);
>> 				decode_putfh_maxsz + \
>> 				decode_secinfo_maxsz)
>> #if defined(CONFIG_NFS_V4_1)
>> +#define NFS4_enc_bind_conn_to_session_sz \
>> +				(compound_encode_hdr_maxsz + \
>> +				 encode_bind_conn_to_session_maxsz)
>> +#define NFS4_dec_bind_conn_to_session_sz \
>> +				(compound_decode_hdr_maxsz + \
>> +				 decode_bind_conn_to_session_maxsz)
>> #define NFS4_enc_exchange_id_sz \
>> 				(compound_encode_hdr_maxsz + \
>> 				 encode_exchange_id_maxsz)
>> @@ -1654,6 +1670,20 @@ static void encode_secinfo(struct xdr_stream =
*xdr, const struct qstr *name, stru
>>=20
>> #if defined(CONFIG_NFS_V4_1)
>> /* NFSv4.1 operations */
>> +static void encode_bind_conn_to_session(struct xdr_stream *xdr,
>> +				   struct nfs4_session *session,
>> +				   struct compound_hdr *hdr)
>> +{
>> +	__be32 *p;
>> +
>> +	encode_op_hdr(xdr, OP_BIND_CONN_TO_SESSION,
>> +		decode_bind_conn_to_session_maxsz, hdr);
>> +	encode_opaque_fixed(xdr, session->sess_id.data, =
NFS4_MAX_SESSIONID_LEN);
>> +	p =3D xdr_reserve_space(xdr, 8);
>> +	*p++ =3D cpu_to_be32(NFS4_CDFC4_BACK_OR_BOTH);
>> +	*p =3D 0;	/* use_conn_in_rdma_mode =3D False */
>> +}
>> +
>> static void encode_exchange_id(struct xdr_stream *xdr,
>> 			       struct nfs41_exchange_id_args *args,
>> 			       struct compound_hdr *hdr)
>> @@ -2614,6 +2644,22 @@ static void nfs4_xdr_enc_secinfo(struct =
rpc_rqst *req,
>>=20
>> #if defined(CONFIG_NFS_V4_1)
>> /*
>> + * BIND_CONN_TO_SESSION request
>> + */
>> +static void nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
>> +				struct xdr_stream *xdr,
>> +				struct nfs_client *clp)
>> +{
>> +	struct compound_hdr hdr =3D {
>> +		.minorversion =3D clp->cl_mvops->minor_version,
>> +	};
>> +
>> +	encode_compound_hdr(xdr, req, &hdr);
>> +	encode_bind_conn_to_session(xdr, clp->cl_session, &hdr);
>> +	encode_nops(&hdr);
>> +}
>> +
>> +/*
>> * EXCHANGE_ID request
>> */
>> static void nfs4_xdr_enc_exchange_id(struct rpc_rqst *req,
>> @@ -5239,6 +5285,32 @@ static int decode_sessionid(struct xdr_stream =
*xdr, struct nfs4_sessionid *sid)
>> 	return decode_opaque_fixed(xdr, sid->data, =
NFS4_MAX_SESSIONID_LEN);
>> }
>>=20
>> +static int decode_bind_conn_to_session(struct xdr_stream *xdr,
>> +				struct nfs41_bind_conn_to_session_res =
*res)
>> +{
>> +	__be32 *p;
>> +	int status;
>> +
>> +	status =3D decode_op_hdr(xdr, OP_BIND_CONN_TO_SESSION);
>> +	if (!status)
>> +		status =3D decode_sessionid(xdr, =
&res->session->sess_id);
>> +	if (unlikely(status))
>> +		return status;
>> +
>> +	/* dir flags, rdma mode bool */
>> +	p =3D xdr_inline_decode(xdr, 8);
>> +	if (unlikely(!p))
>> +		goto out_overflow;
>> +
>> +	res->dir =3D be32_to_cpup(p++);
>> +	res->use_conn_in_rdma_mode =3D be32_to_cpup(p);
>> +
>> +	return 0;
>> +out_overflow:
>> +	print_overflow_msg(__func__, xdr);
>> +	return -EIO;
>> +}
>> +
>> static int decode_create_session(struct xdr_stream *xdr,
>> 				 struct nfs41_create_session_res *res)
>> {
>> @@ -6521,6 +6593,22 @@ out:
>>=20
>> #if defined(CONFIG_NFS_V4_1)
>> /*
>> + * Decode BIND_CONN_TO_SESSION response
>> + */
>> +static int nfs4_xdr_dec_bind_conn_to_session(struct rpc_rqst *rqstp,
>> +					struct xdr_stream *xdr,
>> +					void *res)
>> +{
>> +	struct compound_hdr hdr;
>> +	int status;
>> +
>> +	status =3D decode_compound_hdr(xdr, &hdr);
>> +	if (!status)
>> +		status =3D decode_bind_conn_to_session(xdr, res);
>> +	return status;
>> +}
>> +
>> +/*
>> * Decode EXCHANGE_ID response
>> */
>> static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp,
>> @@ -7001,6 +7089,8 @@ struct rpc_procinfo	nfs4_procedures[] =3D {
>> 	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	=
dec_release_lockowner),
>> 	PROC(SECINFO,		enc_secinfo,		dec_secinfo),
>> #if defined(CONFIG_NFS_V4_1)
>> +	PROC(BIND_CONN_TO_SESSION,
>> +			enc_bind_conn_to_session, =
dec_bind_conn_to_session),
>> 	PROC(EXCHANGE_ID,	enc_exchange_id,	=
dec_exchange_id),
>> 	PROC(CREATE_SESSION,	enc_create_session,	=
dec_create_session),
>> 	PROC(DESTROY_SESSION,	enc_destroy_session,	=
dec_destroy_session),
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index 0987146..80fbbfc6 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -69,6 +69,10 @@
>> #define NFS4_CDFC4_FORE_OR_BOTH 0x3
>> #define NFS4_CDFC4_BACK_OR_BOTH 0x7
>>=20
>> +#define CDFS4_FORE 0x1
>> +#define CDFS4_BACK 0x2
>> +#define CDFS4_BOTH 0x3
>> +
>> #define NFS4_SET_TO_SERVER_TIME	0
>> #define NFS4_SET_TO_CLIENT_TIME	1
>>=20
>> @@ -582,6 +586,7 @@ enum {
>> 	NFSPROC4_CLNT_SECINFO,
>>=20
>> 	/* nfs41 */
>> +	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
>> 	NFSPROC4_CLNT_EXCHANGE_ID,
>> 	NFSPROC4_CLNT_CREATE_SESSION,
>> 	NFSPROC4_CLNT_DESTROY_SESSION,
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index 2e53a3f..dd3bc2f 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -1115,6 +1115,12 @@ struct nfs41_impl_id {
>> 	struct nfstime4			date;
>> };
>>=20
>> +struct nfs41_bind_conn_to_session_res {
>> +	struct nfs4_session		*session;
>> +	u32				dir;
>> +	u32				use_conn_in_rdma_mode;
>=20
> Would it make sense to use a "bool" here instead?

I'm not against it.  It's part of the result struct to ensure that it's =
always 0 returned from the server.

-dros

>=20
>> +};
>> +
>> struct nfs41_exchange_id_res {
>> 	struct nfs_client		*client;
>> 	u32				flags;
>> --=20
>> 1.7.4.4
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> --=20
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>=20
>=20
>=20
>=20


--Apple-Mail=_3088575F-722C-45A6-86CD-224B787EFB7D
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MjQxNjM1MzlaMCMGCSqGSIb3DQEJBDEWBBQ+23UNo7WCawEl
IiETII97HrPCMzANBgkqhkiG9w0BAQEFAASCAQBuGmWcYGE8arojvY4+2YGwWIk1urL/EiC5CVd3
u5j1fsk6b+V4AMOKFz2RefTtT8xZ3XIqKUjnaIBIr3ZPcHsFQOr+EaujGBasRJMtAqHpvkZ6fc9K
HkzT3oSBvMXKUnKNUvYkAd9Rzxxju1657pMBV3A2GpusEfMVDV6t6fMAd/KQ+6nVSrj8a448caH4
8kp9J4OSlifPxfoH+WWELg4EegG0f1Tj14RCqvtoDS80jK/rKJHji2sE2mIJlocwESQzRDcujIJ3
Ays6BhCIJ61D61YN1USc0ydVjMc5vZ2hHxRULTIpUqHI5K2+v5nY5QoS0cchMWfAvupFmyJSybTl
AAAAAAAA

--Apple-Mail=_3088575F-722C-45A6-86CD-224B787EFB7D--
