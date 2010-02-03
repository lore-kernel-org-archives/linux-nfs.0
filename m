From: NeilBrown <neilb@suse.de>
Subject: [PATCH 6/9] sunrpc: close connection when a request is irretrievably
	lost.
Date: Wed, 03 Feb 2010 17:31:31 +1100
Message-ID: <20100203063131.12945.34978.stgit@notabene.brown>
References: <20100203060657.12945.27293.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49546 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756194Ab0BCGji (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 01:39:38 -0500
In-Reply-To: <20100203060657.12945.27293.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we drop a request in the sunrpc layer, either due kmalloc failure,
or due to a cache miss when we could not queue the request for later
replay, then close the connection to encourage the client to retry sooner.

Note that if the drop happens in the NFS layer, NFSERR_JUKEBOX
(aka NFS4ERR_DELAY) is returned to guide the client concerning
replay.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/svcauth.h    |   10 +++++++---
 net/sunrpc/auth_gss/svcauth_gss.c |   12 ++++++------
 net/sunrpc/svc.c                  |    3 +++
 net/sunrpc/svcauth_unix.c         |   11 ++++++++---
 4 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index d39dbdc..1126693 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -108,9 +108,13 @@ struct auth_ops {
 #define	SVC_NEGATIVE	4
 #define	SVC_OK		5
 #define	SVC_DROP	6
-#define	SVC_DENIED	7
-#define	SVC_PENDING	8
-#define	SVC_COMPLETE	9
+#define	SVC_CLOSE	7	/* Like SVC_DROP, but request is definitely
+				 * lost so if there is a tcp connection, it
+				 * should be closed
+				 */
+#define	SVC_DENIED	8
+#define	SVC_PENDING	9
+#define	SVC_COMPLETE	10
 
 
 extern int	svc_authenticate(struct svc_rqst *rqstp, __be32 *authp);
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index e34bc53..4db9562 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -963,7 +963,7 @@ svcauth_gss_set_client(struct svc_rqst *rqstp)
 	if (rqstp->rq_gssclient == NULL)
 		return SVC_DENIED;
 	stat = svcauth_unix_set_client(rqstp);
-	if (stat == SVC_DROP)
+	if (stat == SVC_DROP || stat == SVC_CLOSE)
 		return stat;
 	return SVC_OK;
 }
@@ -1017,7 +1017,7 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 		return SVC_DENIED;
 	memset(&rsikey, 0, sizeof(rsikey));
 	if (dup_netobj(&rsikey.in_handle, &gc->gc_ctx))
-		return SVC_DROP;
+		return SVC_CLOSE;
 	*authp = rpc_autherr_badverf;
 	if (svc_safe_getnetobj(argv, &tmpobj)) {
 		kfree(rsikey.in_handle.data);
@@ -1025,22 +1025,22 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 	}
 	if (dup_netobj(&rsikey.in_token, &tmpobj)) {
 		kfree(rsikey.in_handle.data);
-		return SVC_DROP;
+		return SVC_CLOSE;
 	}
 
 	/* Perform upcall, or find upcall result: */
 	rsip = rsi_lookup(&rsikey);
 	rsi_free(&rsikey);
 	if (!rsip)
-		return SVC_DROP;
+		return SVC_CLOSE;
 	switch (cache_check(&rsi_cache, &rsip->h, &rqstp->rq_chandle)) {
 	case -EAGAIN:
 	case -ETIMEDOUT:
 	case -ENOENT:
 		/* No upcall result: */
-		return SVC_DROP;
+		return SVC_CLOSE;
 	case 0:
-		ret = SVC_DROP;
+		ret = SVC_CLOSE;
 		/* Got an answer to the upcall; use it: */
 		if (gss_write_init_verf(rqstp, rsip))
 			goto out;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 538ca43..e750988 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1050,6 +1050,9 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		goto err_bad;
 	case SVC_DENIED:
 		goto err_bad_auth;
+	case SVC_CLOSE:
+		if (test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
+			svc_close_xprt(rqstp->rq_xprt);
 	case SVC_DROP:
 		goto dropit;
 	case SVC_COMPLETE:
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index d8c0411..a25f8ba 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -668,6 +668,8 @@ static struct group_info *unix_gid_find(uid_t uid, struct svc_rqst *rqstp)
 	switch (ret) {
 	case -ENOENT:
 		return ERR_PTR(-ENOENT);
+	case -ETIMEDOUT:
+		return ERR_PTR(-ESHUTDOWN);
 	case 0:
 		gi = get_group_info(ug->gi);
 		cache_put(&ug->h, &unix_gid_cache);
@@ -714,8 +716,9 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
 		default:
 			BUG();
-		case -EAGAIN:
 		case -ETIMEDOUT:
+			return SVC_CLOSE;
+		case -EAGAIN:
 			return SVC_DROP;
 		case -ENOENT:
 			return SVC_DENIED;
@@ -730,6 +733,8 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	switch (PTR_ERR(gi)) {
 	case -EAGAIN:
 		return SVC_DROP;
+	case -ESHUTDOWN:
+		return SVC_CLOSE;
 	case -ENOENT:
 		break;
 	default:
@@ -770,7 +775,7 @@ svcauth_null_accept(struct svc_rqst *rqstp, __be32 *authp)
 	cred->cr_gid = (gid_t) -1;
 	cred->cr_group_info = groups_alloc(0);
 	if (cred->cr_group_info == NULL)
-		return SVC_DROP; /* kmalloc failure - client must retry */
+		return SVC_CLOSE; /* kmalloc failure - client must retry */
 
 	/* Put NULL verifier */
 	svc_putnl(resv, RPC_AUTH_NULL);
@@ -834,7 +839,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 		goto badcred;
 	cred->cr_group_info = groups_alloc(slen);
 	if (cred->cr_group_info == NULL)
-		return SVC_DROP;
+		return SVC_CLOSE;
 	for (i = 0; i < slen; i++)
 		GROUP_AT(cred->cr_group_info, i) = svc_getnl(argv);
 	if (svc_getu32(argv) != htonl(RPC_AUTH_NULL) || svc_getu32(argv) != 0) {


