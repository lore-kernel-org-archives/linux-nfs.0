Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33880 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389547AbeHAQGG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Aug 2018 12:06:06 -0400
Date: Wed, 1 Aug 2018 10:20:07 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: YueHaibing <yuehaibing@huawei.com>, davem@davemloft.net,
        trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>, jlayton@kernel.org,
        ebiggers@google.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: remove redundant variables
 'checksumlen','blocksize' and 'data'
Message-ID: <20180801142007.GE16651@fieldses.org>
References: <20180801062810.19752-1-yuehaibing@huawei.com>
 <9BA49886-5754-480E-BBB3-CC76E5A2C3B7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <9BA49886-5754-480E-BBB3-CC76E5A2C3B7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 01, 2018 at 10:15:29AM -0400, Chuck Lever wrote:
> 
> 
> > On Aug 1, 2018, at 2:28 AM, YueHaibing <yuehaibing@huawei.com> wrote:
> > 
> > Variables 'checksumlen','blocksize' and 'data' are being assigned,
> > but are never used,hence they are redundant and can be removed.
> > 
> > fix fllowing warning:
> 
> ^fllowing^following
> 
> For the svc_rdma.c part:
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

Thanks.--b.

> 
> 
> > net/sunrpc/auth_gss/gss_krb5_wrap.c:443:7: warning: variable ‘blocksize’ set but not used [-Wunused-but-set-variable]
> > net/sunrpc/auth_gss/gss_krb5_crypto.c:376:15: warning: variable ‘checksumlen’ set but not used [-Wunused-but-set-variable]
> > net/sunrpc/xprtrdma/svc_rdma.c:97:9: warning: variable ‘data’ set but not used [-Wunused-but-set-variable]
> > 
> > Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> > ---
> > net/sunrpc/auth_gss/gss_krb5_crypto.c | 2 --
> > net/sunrpc/auth_gss/gss_krb5_wrap.c   | 2 --
> > net/sunrpc/xprtrdma/svc_rdma.c        | 2 --
> > 3 files changed, 6 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> > index 8654494..84a16fd 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> > @@ -373,7 +373,6 @@ make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
> > 	struct scatterlist sg[1];
> > 	int err = -1;
> > 	u8 *checksumdata;
> > -	unsigned int checksumlen;
> > 
> > 	if (kctx->gk5e->keyed_cksum == 0) {
> > 		dprintk("%s: expected keyed hash for %s\n",
> > @@ -393,7 +392,6 @@ make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
> > 	tfm = crypto_alloc_ahash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
> > 	if (IS_ERR(tfm))
> > 		goto out_free_cksum;
> > -	checksumlen = crypto_ahash_digestsize(tfm);
> > 
> > 	req = ahash_request_alloc(tfm, GFP_NOFS);
> > 	if (!req)
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > index a737c2d..9a1347f 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > @@ -440,7 +440,6 @@ static u32
> > gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
> > 		     struct xdr_buf *buf, struct page **pages)
> > {
> > -	int		blocksize;
> > 	u8		*ptr, *plainhdr;
> > 	s32		now;
> > 	u8		flags = 0x00;
> > @@ -473,7 +472,6 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
> > 	*ptr++ = 0xff;
> > 	be16ptr = (__be16 *)ptr;
> > 
> > -	blocksize = crypto_skcipher_blocksize(kctx->acceptor_enc);
> > 	*be16ptr++ = 0;
> > 	/* "inner" token header always uses 0 for RRC */
> > 	*be16ptr++ = 0;
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
> > index 357ba90..134bef6a 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma.c
> > @@ -94,7 +94,6 @@ static int read_reset_stat(struct ctl_table *table, int write,
> > 		atomic_set(stat, 0);
> > 	else {
> > 		char str_buf[32];
> > -		char *data;
> > 		int len = snprintf(str_buf, 32, "%d\n", atomic_read(stat));
> > 		if (len >= 32)
> > 			return -EFAULT;
> > @@ -103,7 +102,6 @@ static int read_reset_stat(struct ctl_table *table, int write,
> > 			*lenp = 0;
> > 			return 0;
> > 		}
> > -		data = &str_buf[*ppos];
> > 		len -= *ppos;
> > 		if (len > *lenp)
> > 			len = *lenp;
> > -- 
> > 2.7.0
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
