Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:41562 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2389370AbeHAQBu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 12:01:50 -0400
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] sunrpc: remove redundant variables
 'checksumlen','blocksize' and 'data'
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180801062810.19752-1-yuehaibing@huawei.com>
Date: Wed, 1 Aug 2018 10:15:29 -0400
Cc: davem@davemloft.net, trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Bruce Fields <bfields@fieldses.org>, jlayton@kernel.org,
        ebiggers@google.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9BA49886-5754-480E-BBB3-CC76E5A2C3B7@oracle.com>
References: <20180801062810.19752-1-yuehaibing@huawei.com>
To: YueHaibing <yuehaibing@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 1, 2018, at 2:28 AM, YueHaibing <yuehaibing@huawei.com> wrote:
>=20
> Variables 'checksumlen','blocksize' and 'data' are being assigned,
> but are never used,hence they are redundant and can be removed.
>=20
> fix fllowing warning:

^fllowing^following

For the svc_rdma.c part:

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> net/sunrpc/auth_gss/gss_krb5_wrap.c:443:7: warning: variable =
=E2=80=98blocksize=E2=80=99 set but not used [-Wunused-but-set-variable]
> net/sunrpc/auth_gss/gss_krb5_crypto.c:376:15: warning: variable =
=E2=80=98checksumlen=E2=80=99 set but not used =
[-Wunused-but-set-variable]
> net/sunrpc/xprtrdma/svc_rdma.c:97:9: warning: variable =E2=80=98data=E2=80=
=99 set but not used [-Wunused-but-set-variable]
>=20
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> ---
> net/sunrpc/auth_gss/gss_krb5_crypto.c | 2 --
> net/sunrpc/auth_gss/gss_krb5_wrap.c   | 2 --
> net/sunrpc/xprtrdma/svc_rdma.c        | 2 --
> 3 files changed, 6 deletions(-)
>=20
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c =
b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index 8654494..84a16fd 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -373,7 +373,6 @@ make_checksum_v2(struct krb5_ctx *kctx, char =
*header, int hdrlen,
> 	struct scatterlist sg[1];
> 	int err =3D -1;
> 	u8 *checksumdata;
> -	unsigned int checksumlen;
>=20
> 	if (kctx->gk5e->keyed_cksum =3D=3D 0) {
> 		dprintk("%s: expected keyed hash for %s\n",
> @@ -393,7 +392,6 @@ make_checksum_v2(struct krb5_ctx *kctx, char =
*header, int hdrlen,
> 	tfm =3D crypto_alloc_ahash(kctx->gk5e->cksum_name, 0, =
CRYPTO_ALG_ASYNC);
> 	if (IS_ERR(tfm))
> 		goto out_free_cksum;
> -	checksumlen =3D crypto_ahash_digestsize(tfm);
>=20
> 	req =3D ahash_request_alloc(tfm, GFP_NOFS);
> 	if (!req)
> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c =
b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> index a737c2d..9a1347f 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> @@ -440,7 +440,6 @@ static u32
> gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
> 		     struct xdr_buf *buf, struct page **pages)
> {
> -	int		blocksize;
> 	u8		*ptr, *plainhdr;
> 	s32		now;
> 	u8		flags =3D 0x00;
> @@ -473,7 +472,6 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 =
offset,
> 	*ptr++ =3D 0xff;
> 	be16ptr =3D (__be16 *)ptr;
>=20
> -	blocksize =3D crypto_skcipher_blocksize(kctx->acceptor_enc);
> 	*be16ptr++ =3D 0;
> 	/* "inner" token header always uses 0 for RRC */
> 	*be16ptr++ =3D 0;
> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c =
b/net/sunrpc/xprtrdma/svc_rdma.c
> index 357ba90..134bef6a 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
> @@ -94,7 +94,6 @@ static int read_reset_stat(struct ctl_table *table, =
int write,
> 		atomic_set(stat, 0);
> 	else {
> 		char str_buf[32];
> -		char *data;
> 		int len =3D snprintf(str_buf, 32, "%d\n", =
atomic_read(stat));
> 		if (len >=3D 32)
> 			return -EFAULT;
> @@ -103,7 +102,6 @@ static int read_reset_stat(struct ctl_table =
*table, int write,
> 			*lenp =3D 0;
> 			return 0;
> 		}
> -		data =3D &str_buf[*ppos];
> 		len -=3D *ppos;
> 		if (len > *lenp)
> 			len =3D *lenp;
> --=20
> 2.7.0
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



