From: NeilBrown <neilb@suse.de>
Subject: [PATCH 9/9] sunrpc: close connection when a request is irretrievably
	lost.
Date: Wed, 09 Sep 2009 16:32:55 +1000
Message-ID: <20090909063255.20462.19886.stgit@notabene.brown>
References: <20090909062539.20462.67466.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56333 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbZIIGdc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 02:33:32 -0400
In-Reply-To: <20090909062539.20462.67466.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
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
 net/sunrpc/auth_gss/svcauth_gss.c |   11 ++++++-----
 net/sunrpc/svc.c                  |    3 +++
 net/sunrpc/svcauth_unix.c         |   14 +++++++++-----
 4 files changed, 25 insertions(+), 13 deletions(-)

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
index c4e9177..03eae41 100644
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
@@ -1025,7 +1025,7 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 	}
 	if (dup_netobj(&rsikey.in_token, &tmpobj)) {
 		kfree(rsikey.in_handle.data);
-		return SVC_DROP;
+		return SVC_CLOSE;
 	}
 
 	/* Perform upcall, or find upcall result: */
@@ -1033,7 +1033,7 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 	rsip = rsi_lookup(&rsikey);
 	if (!rsip) {
 		rsi_free(&rsikey);
-		return SVC_DROP;
+		return SVC_CLOSE;
 	}
 	switch (cache_check(&rsi_cache, &rsip->h, &rqstp->rq_chandle)) {
 	case -ETIMEDOUT:
@@ -1043,13 +1043,14 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 			goto retry;
 		if (rsip)
 			cache_put(&rsip->h, &rsi_cache);
+		return SVC_CLOSE;
 	case -EAGAIN:
 	case -ENOENT:
 		/* No upcall result: */
 		rsi_free(&rsikey);
 		return SVC_DROP;
 	case 0:
-		ret = SVC_DROP;
+		ret = SVC_CLOSE;
 		/* Got an answer to the upcall; use it: */
 		if (gss_write_init_verf(rqstp, rsip))
 			goto out;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 952f206..b47aa21 100644
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
index f9122df..4e4e10b 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -679,6 +679,7 @@ static int unix_gid_find(uid_t uid, struct group_info **gip,
 			goto retry;
 		if (ug)
 			cache_put(&ug->h, &unix_gid_cache);
+		return -ESHUTDOWN;
 	default:
 		return -EAGAIN;
 	}
@@ -729,7 +730,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 				goto retry;
 			if (ipm)
 				cache_put(&ipm->h, &ip_map_cache);
-
+			return SVC_CLOSE;
 		case -EAGAIN:
 			return SVC_DROP;
 		case -ENOENT:
@@ -774,7 +775,7 @@ svcauth_null_accept(struct svc_rqst *rqstp, __be32 *authp)
 	cred->cr_gid = (gid_t) -1;
 	cred->cr_group_info = groups_alloc(0);
 	if (cred->cr_group_info == NULL)
-		return SVC_DROP; /* kmalloc failure - client must retry */
+		return SVC_CLOSE; /* kmalloc failure - client must retry */
 
 	/* Put NULL verifier */
 	svc_putnl(resv, RPC_AUTH_NULL);
@@ -836,13 +837,16 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 	slen = svc_getnl(argv);			/* gids length */
 	if (slen > 16 || (len -= (slen + 2)*4) < 0)
 		goto badcred;
-	if (unix_gid_find(cred->cr_uid, &cred->cr_group_info, rqstp)
-	    == -EAGAIN)
+	switch (unix_gid_find(cred->cr_uid, &cred->cr_group_info, rqstp)) {
+	case -EAGAIN:
 		return SVC_DROP;
+	case -ESHUTDOWN:
+		return SVC_CLOSE;
+	}
 	if (cred->cr_group_info == NULL) {
 		cred->cr_group_info = groups_alloc(slen);
 		if (cred->cr_group_info == NULL)
-			return SVC_DROP;
+			return SVC_CLOSE;
 		for (i = 0; i < slen; i++)
 			GROUP_AT(cred->cr_group_info, i) = svc_getnl(argv);
 	} else {


