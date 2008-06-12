From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/37] SUNRPC: Use GFP_NOFS when allocating credentials
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192200.24528.65570.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754819AbYFLTeA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:00 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJY0dU001528
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:34:00 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the credentials may be allocated during the call to rpc_new_task(),
which again may be called by a memory allocator...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c        |   10 +++++-----
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    4 ++--
 net/sunrpc/auth_gss/gss_spkm3_mech.c  |    4 ++--
 net/sunrpc/auth_gss/gss_spkm3_token.c |    2 +-
 net/sunrpc/auth_unix.c                |    2 +-
 5 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index cc12d5f..bf7585b 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -146,7 +146,7 @@ simple_get_netobj(const void *p, const void *end, struct xdr_netobj *dest)
 	q = (const void *)((const char *)p + len);
 	if (unlikely(q > end || q < p))
 		return ERR_PTR(-EFAULT);
-	dest->data = kmemdup(p, len, GFP_KERNEL);
+	dest->data = kmemdup(p, len, GFP_NOFS);
 	if (unlikely(dest->data == NULL))
 		return ERR_PTR(-ENOMEM);
 	dest->len = len;
@@ -171,7 +171,7 @@ gss_alloc_context(void)
 {
 	struct gss_cl_ctx *ctx;
 
-	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+	ctx = kzalloc(sizeof(*ctx), GFP_NOFS);
 	if (ctx != NULL) {
 		ctx->gc_proc = RPC_GSS_PROC_DATA;
 		ctx->gc_seq = 1;	/* NetApp 6.4R1 doesn't accept seq. no. 0 */
@@ -341,7 +341,7 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
 {
 	struct gss_upcall_msg *gss_msg;
 
-	gss_msg = kzalloc(sizeof(*gss_msg), GFP_KERNEL);
+	gss_msg = kzalloc(sizeof(*gss_msg), GFP_NOFS);
 	if (gss_msg != NULL) {
 		INIT_LIST_HEAD(&gss_msg->list);
 		rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
@@ -503,7 +503,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	if (mlen > MSG_BUF_MAXSIZE)
 		goto out;
 	err = -ENOMEM;
-	buf = kmalloc(mlen, GFP_KERNEL);
+	buf = kmalloc(mlen, GFP_NOFS);
 	if (!buf)
 		goto out;
 
@@ -806,7 +806,7 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	dprintk("RPC:       gss_create_cred for uid %d, flavor %d\n",
 		acred->uid, auth->au_flavor);
 
-	if (!(cred = kzalloc(sizeof(*cred), GFP_KERNEL)))
+	if (!(cred = kzalloc(sizeof(*cred), GFP_NOFS)))
 		goto out_err;
 
 	rpcauth_init_cred(&cred->gc_base, acred, auth, &gss_credops);
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 60c3dba..ef45eba 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -70,7 +70,7 @@ simple_get_netobj(const void *p, const void *end, struct xdr_netobj *res)
 	q = (const void *)((const char *)p + len);
 	if (unlikely(q > end || q < p))
 		return ERR_PTR(-EFAULT);
-	res->data = kmemdup(p, len, GFP_KERNEL);
+	res->data = kmemdup(p, len, GFP_NOFS);
 	if (unlikely(res->data == NULL))
 		return ERR_PTR(-ENOMEM);
 	res->len = len;
@@ -131,7 +131,7 @@ gss_import_sec_context_kerberos(const void *p,
 	struct	krb5_ctx *ctx;
 	int tmp;
 
-	if (!(ctx = kzalloc(sizeof(*ctx), GFP_KERNEL)))
+	if (!(ctx = kzalloc(sizeof(*ctx), GFP_NOFS)))
 		goto out_err;
 
 	p = simple_get_bytes(p, end, &ctx->initiate, sizeof(ctx->initiate));
diff --git a/net/sunrpc/auth_gss/gss_spkm3_mech.c b/net/sunrpc/auth_gss/gss_spkm3_mech.c
index 5deb4b6..035e1dd 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_mech.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_mech.c
@@ -76,7 +76,7 @@ simple_get_netobj(const void *p, const void *end, struct xdr_netobj *res)
 	q = (const void *)((const char *)p + len);
 	if (unlikely(q > end || q < p))
 		return ERR_PTR(-EFAULT);
-	res->data = kmemdup(p, len, GFP_KERNEL);
+	res->data = kmemdup(p, len, GFP_NOFS);
 	if (unlikely(res->data == NULL))
 		return ERR_PTR(-ENOMEM);
 	return q;
@@ -90,7 +90,7 @@ gss_import_sec_context_spkm3(const void *p, size_t len,
 	struct	spkm3_ctx *ctx;
 	int	version;
 
-	if (!(ctx = kzalloc(sizeof(*ctx), GFP_KERNEL)))
+	if (!(ctx = kzalloc(sizeof(*ctx), GFP_NOFS)))
 		goto out_err;
 
 	p = simple_get_bytes(p, end, &version, sizeof(version));
diff --git a/net/sunrpc/auth_gss/gss_spkm3_token.c b/net/sunrpc/auth_gss/gss_spkm3_token.c
index 6cdd241..3308157 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_token.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_token.c
@@ -90,7 +90,7 @@ asn1_bitstring_len(struct xdr_netobj *in, int *enclen, int *zerobits)
 int
 decode_asn1_bitstring(struct xdr_netobj *out, char *in, int enclen, int explen)
 {
-	if (!(out->data = kzalloc(explen,GFP_KERNEL)))
+	if (!(out->data = kzalloc(explen,GFP_NOFS)))
 		return 0;
 	out->len = explen;
 	memcpy(out->data, in, enclen);
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 44920b9..46b2647 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -66,7 +66,7 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
 			acred->uid, acred->gid);
 
-	if (!(cred = kmalloc(sizeof(*cred), GFP_KERNEL)))
+	if (!(cred = kmalloc(sizeof(*cred), GFP_NOFS)))
 		return ERR_PTR(-ENOMEM);
 
 	rpcauth_init_cred(&cred->uc_base, acred, auth, &unix_credops);

