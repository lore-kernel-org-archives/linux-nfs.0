Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47438 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752881AbcJYSpj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Oct 2016 14:45:39 -0400
Date: Tue, 25 Oct 2016 14:45:38 -0400
To: linux-nfs@vger.kernel.org
Cc: Rusty Russell <rusty@rustcorp.com.au>,
        Christoph Hellwig <hch@infradead.org>, linux-crypto@vger.kernel.org
Subject: [PATCH] sunrpc: don't pass on-stack memory to sg_set_buf
Message-ID: <20161025184538.GA4612@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As of ac4e97abce9b "scatterlist: sg_set_buf() argument must be in linear
mapping", sg_set_buf hits a BUG when make_checksum_v2->xdr_process_buf,
among other callers, passes it memory on the stack.

We only need a scatterlist to pass this to the crypto code, and it seems
like overkill to require kmalloc'd memory just to encrypt a few bytes,
but for now this seems the best fix.

Note many of these callers are in the NFS write paths, so we shouldn't
really be allocating GFP_KERNEL.  But we already have other allocations
in these code paths.  A larger redesign may be necessary to allow
allocations to be done earlier.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c        | 13 ++++--
 net/sunrpc/auth_gss/gss_krb5_crypto.c | 82 ++++++++++++++++++++---------------
 net/sunrpc/auth_gss/svcauth_gss.c     | 21 ++++++---
 3 files changed, 71 insertions(+), 45 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index d8bd97a5a7c9..6ecc30058f95 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1616,7 +1616,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
-	__be32		seq;
+	__be32		*seq = NULL;
 	struct kvec	iov;
 	struct xdr_buf	verf_buf;
 	struct xdr_netobj mic;
@@ -1631,9 +1631,12 @@ gss_validate(struct rpc_task *task, __be32 *p)
 		goto out_bad;
 	if (flav != RPC_AUTH_GSS)
 		goto out_bad;
-	seq = htonl(task->tk_rqstp->rq_seqno);
-	iov.iov_base = &seq;
-	iov.iov_len = sizeof(seq);
+	seq = kmalloc(4, GFP_KERNEL);
+	if (!seq)
+		goto out_bad;
+	*seq = htonl(task->tk_rqstp->rq_seqno);
+	iov.iov_base = seq;
+	iov.iov_len = 4;
 	xdr_buf_from_iov(&iov, &verf_buf);
 	mic.data = (u8 *)p;
 	mic.len = len;
@@ -1653,11 +1656,13 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	gss_put_ctx(ctx);
 	dprintk("RPC: %5u %s: gss_verify_mic succeeded.\n",
 			task->tk_pid, __func__);
+	kfree(seq);
 	return p + XDR_QUADLEN(len);
 out_bad:
 	gss_put_ctx(ctx);
 	dprintk("RPC: %5u %s failed ret %ld.\n", task->tk_pid, __func__,
 		PTR_ERR(ret));
+	kfree(seq);
 	return ret;
 }
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 244245bcbbd2..8a280a810439 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -166,8 +166,8 @@ make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
 		       unsigned int usage, struct xdr_netobj *cksumout)
 {
 	struct scatterlist              sg[1];
-	int err;
-	u8 checksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	int err = -1;
+	u8 *checksumdata;
 	u8 rc4salt[4];
 	struct crypto_ahash *md5;
 	struct crypto_ahash *hmac_md5;
@@ -187,23 +187,22 @@ make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
 		return GSS_S_FAILURE;
 	}
 
+	checksumdata = kmalloc(GSS_KRB5_MAX_CKSUM_LEN, GFP_KERNEL);
+	if (!checksumdata)
+		return GSS_S_FAILURE;
+
 	md5 = crypto_alloc_ahash("md5", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(md5))
-		return GSS_S_FAILURE;
+		goto out_free_cksum;
 
 	hmac_md5 = crypto_alloc_ahash(kctx->gk5e->cksum_name, 0,
 				      CRYPTO_ALG_ASYNC);
-	if (IS_ERR(hmac_md5)) {
-		crypto_free_ahash(md5);
-		return GSS_S_FAILURE;
-	}
+	if (IS_ERR(hmac_md5))
+		goto out_free_md5;
 
 	req = ahash_request_alloc(md5, GFP_KERNEL);
-	if (!req) {
-		crypto_free_ahash(hmac_md5);
-		crypto_free_ahash(md5);
-		return GSS_S_FAILURE;
-	}
+	if (!req)
+		goto out_free_hmac_md5;
 
 	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
 
@@ -232,11 +231,8 @@ make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
 
 	ahash_request_free(req);
 	req = ahash_request_alloc(hmac_md5, GFP_KERNEL);
-	if (!req) {
-		crypto_free_ahash(hmac_md5);
-		crypto_free_ahash(md5);
-		return GSS_S_FAILURE;
-	}
+	if (!req)
+		goto out_free_hmac_md5;
 
 	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
 
@@ -258,8 +254,12 @@ make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
 	cksumout->len = kctx->gk5e->cksumlength;
 out:
 	ahash_request_free(req);
-	crypto_free_ahash(md5);
+out_free_hmac_md5:
 	crypto_free_ahash(hmac_md5);
+out_free_md5:
+	crypto_free_ahash(md5);
+out_free_cksum:
+	kfree(checksumdata);
 	return err ? GSS_S_FAILURE : 0;
 }
 
@@ -276,8 +276,8 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 	struct crypto_ahash *tfm;
 	struct ahash_request *req;
 	struct scatterlist              sg[1];
-	int err;
-	u8 checksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	int err = -1;
+	u8 *checksumdata;
 	unsigned int checksumlen;
 
 	if (kctx->gk5e->ctype == CKSUMTYPE_HMAC_MD5_ARCFOUR)
@@ -291,15 +291,17 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 		return GSS_S_FAILURE;
 	}
 
+	checksumdata = kmalloc(GSS_KRB5_MAX_CKSUM_LEN, GFP_KERNEL);
+	if (checksumdata == NULL)
+		return GSS_S_FAILURE;
+
 	tfm = crypto_alloc_ahash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm))
-		return GSS_S_FAILURE;
+		goto out_free_cksum;
 
 	req = ahash_request_alloc(tfm, GFP_KERNEL);
-	if (!req) {
-		crypto_free_ahash(tfm);
-		return GSS_S_FAILURE;
-	}
+	if (!req)
+		goto out_free_ahash;
 
 	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
 
@@ -349,7 +351,10 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 	cksumout->len = kctx->gk5e->cksumlength;
 out:
 	ahash_request_free(req);
+out_free_ahash:
 	crypto_free_ahash(tfm);
+out_free_cksum:
+	kfree(checksumdata);
 	return err ? GSS_S_FAILURE : 0;
 }
 
@@ -368,8 +373,8 @@ make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
 	struct crypto_ahash *tfm;
 	struct ahash_request *req;
 	struct scatterlist sg[1];
-	int err;
-	u8 checksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	int err = -1;
+	u8 *checksumdata;
 	unsigned int checksumlen;
 
 	if (kctx->gk5e->keyed_cksum == 0) {
@@ -383,16 +388,18 @@ make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
 		return GSS_S_FAILURE;
 	}
 
+	checksumdata = kmalloc(GSS_KRB5_MAX_CKSUM_LEN, GFP_KERNEL);
+	if (!checksumdata)
+		return GSS_S_FAILURE;
+
 	tfm = crypto_alloc_ahash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm))
-		return GSS_S_FAILURE;
+		goto out_free_cksum;
 	checksumlen = crypto_ahash_digestsize(tfm);
 
 	req = ahash_request_alloc(tfm, GFP_KERNEL);
-	if (!req) {
-		crypto_free_ahash(tfm);
-		return GSS_S_FAILURE;
-	}
+	if (!req)
+		goto out_free_ahash;
 
 	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
 
@@ -433,7 +440,10 @@ make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
 	}
 out:
 	ahash_request_free(req);
+out_free_ahash:
 	crypto_free_ahash(tfm);
+out_free_cksum:
+	kfree(checksumdata);
 	return err ? GSS_S_FAILURE : 0;
 }
 
@@ -666,14 +676,17 @@ gss_krb5_cts_crypt(struct crypto_skcipher *cipher, struct xdr_buf *buf,
 	u32 ret;
 	struct scatterlist sg[1];
 	SKCIPHER_REQUEST_ON_STACK(req, cipher);
-	u8 data[GSS_KRB5_MAX_BLOCKSIZE * 2];
+	u8 *data;
 	struct page **save_pages;
 	u32 len = buf->len - offset;
 
-	if (len > ARRAY_SIZE(data)) {
+	if (len > GSS_KRB5_MAX_BLOCKSIZE * 2) {
 		WARN_ON(0);
 		return -ENOMEM;
 	}
+	data = kmalloc(GSS_KRB5_MAX_BLOCKSIZE * 2, GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
 
 	/*
 	 * For encryption, we want to read from the cleartext
@@ -708,6 +721,7 @@ gss_krb5_cts_crypt(struct crypto_skcipher *cipher, struct xdr_buf *buf,
 	ret = write_bytes_to_xdr_buf(buf, offset, data, len);
 
 out:
+	kfree(data);
 	return ret;
 }
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index d67f7e1bc82d..45662d7f0943 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -718,30 +718,37 @@ gss_write_null_verf(struct svc_rqst *rqstp)
 static int
 gss_write_verf(struct svc_rqst *rqstp, struct gss_ctx *ctx_id, u32 seq)
 {
-	__be32			xdr_seq;
+	__be32			*xdr_seq;
 	u32			maj_stat;
 	struct xdr_buf		verf_data;
 	struct xdr_netobj	mic;
 	__be32			*p;
 	struct kvec		iov;
+	int err = -1;
 
 	svc_putnl(rqstp->rq_res.head, RPC_AUTH_GSS);
-	xdr_seq = htonl(seq);
+	xdr_seq = kmalloc(4, GFP_KERNEL);
+	if (!xdr_seq)
+		return -1;
+	*xdr_seq = htonl(seq);
 
-	iov.iov_base = &xdr_seq;
-	iov.iov_len = sizeof(xdr_seq);
+	iov.iov_base = xdr_seq;
+	iov.iov_len = 4;
 	xdr_buf_from_iov(&iov, &verf_data);
 	p = rqstp->rq_res.head->iov_base + rqstp->rq_res.head->iov_len;
 	mic.data = (u8 *)(p + 1);
 	maj_stat = gss_get_mic(ctx_id, &verf_data, &mic);
 	if (maj_stat != GSS_S_COMPLETE)
-		return -1;
+		goto out;
 	*p++ = htonl(mic.len);
 	memset((u8 *)p + mic.len, 0, round_up_to_quad(mic.len) - mic.len);
 	p += XDR_QUADLEN(mic.len);
 	if (!xdr_ressize_check(rqstp, p))
-		return -1;
-	return 0;
+		goto out;
+	err = 0;
+out:
+	kfree(xdr_seq);
+	return err;
 }
 
 struct gss_domain {
-- 
2.7.4

