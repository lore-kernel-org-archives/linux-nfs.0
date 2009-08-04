From: NeilBrown <neilb@suse.de>
Subject: [PATCH 12/12] sunrpc: close connection when a request is
	irretrievably lost.
Date: Tue, 04 Aug 2009 15:22:40 +1000
Message-ID: <20090804052239.15929.16857.stgit@notabene.brown>
References: <20090804051145.15929.11356.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41305 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754550AbZHDFZd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 01:25:33 -0400
In-Reply-To: <20090804051145.15929.11356.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we drop a request in the sunrpc layer due to a cache miss,
and could not queue the request for later replay, then close
the connection to encourage the client to retry sooner.

Note that if the drop happens in the NFS layer, NFSERR_JUKEBOX
is returned to guide the client concerning replay

Signed-off-by: NeilBrown <neilb@suse.de>
---

 include/linux/sunrpc/svcauth.h |   10 +++++++---
 net/sunrpc/svc.c               |    3 +++
 net/sunrpc/svcauth_unix.c      |   10 +++++++---
 3 files changed, 17 insertions(+), 6 deletions(-)

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
index 0afeb30..e203a0b 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -669,6 +669,7 @@ static int unix_gid_find(uid_t uid, struct group_info **gip,
 			goto retry;
 		if (ug)
 			cache_put(&ug->h, &unix_gid_cache);
+		return -ESHUTDOWN;
 	default:
 		return -EAGAIN;
 	}
@@ -719,7 +720,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 				goto retry;
 			if (ipm)
 				cache_put(&ipm->h, &ip_map_cache);
-
+			return SVC_CLOSE;
 		case -EAGAIN:
 			return SVC_DROP;
 		case -ENOENT:
@@ -826,9 +827,12 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
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


