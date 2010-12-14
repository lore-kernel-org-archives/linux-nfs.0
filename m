Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:55072 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758585Ab0LNO5z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:57:55 -0500
Received: by gyb11 with SMTP id 11so374133gyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:57:54 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/31] lockd: Move nlmdbg_cookie2a() to svclock.c
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:57:52 -0500
Message-ID: <20101214145752.2293.57312.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.  nlmdbg_cookie2a() is used only in svclock.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/lockd/svclock.c          |   30 ++++++++++++++++++++++++++++++
 fs/lockd/xdr.c              |   29 -----------------------------
 include/linux/lockd/debug.h |   10 ----------
 3 files changed, 30 insertions(+), 39 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index ef5659b..9266c46 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -46,6 +46,7 @@ static void	nlmsvc_remove_block(struct nlm_block *block);
 static int nlmsvc_setgrantargs(struct nlm_rqst *call, struct nlm_lock *lock);
 static void nlmsvc_freegrantargs(struct nlm_rqst *call);
 static const struct rpc_call_ops nlmsvc_grant_ops;
+static const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie);
 
 /*
  * The list of blocked locks to retry
@@ -934,3 +935,32 @@ nlmsvc_retry_blocked(void)
 
 	return timeout;
 }
+
+#ifdef RPC_DEBUG
+static const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
+{
+	/*
+	 * We can get away with a static buffer because we're only
+	 * called with BKL held.
+	 */
+	static char buf[2*NLM_MAXCOOKIELEN+1];
+	unsigned int i, len = sizeof(buf);
+	char *p = buf;
+
+	len--;	/* allow for trailing \0 */
+	if (len < 3)
+		return "???";
+	for (i = 0 ; i < cookie->len ; i++) {
+		if (len < 2) {
+			strcpy(p-3, "...");
+			break;
+		}
+		sprintf(p, "%02x", cookie->data[i]);
+		p += 2;
+		len -= 2;
+	}
+	*p = '\0';
+
+	return buf;
+}
+#endif
diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 0eb694d..964666c 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -341,32 +341,3 @@ nlmsvc_encode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
 {
 	return xdr_ressize_check(rqstp, p);
 }
-
-#ifdef RPC_DEBUG
-const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
-{
-	/*
-	 * We can get away with a static buffer because we're only
-	 * called with BKL held.
-	 */
-	static char buf[2*NLM_MAXCOOKIELEN+1];
-	unsigned int i, len = sizeof(buf);
-	char *p = buf;
-
-	len--;	/* allow for trailing \0 */
-	if (len < 3)
-		return "???";
-	for (i = 0 ; i < cookie->len ; i++) {
-		if (len < 2) {
-			strcpy(p-3, "...");
-			break;
-		}
-		sprintf(p, "%02x", cookie->data[i]);
-		p += 2;
-		len -= 2;
-	}
-	*p = '\0';
-
-	return buf;
-}
-#endif
diff --git a/include/linux/lockd/debug.h b/include/linux/lockd/debug.h
index 34b2b7f..257d377 100644
--- a/include/linux/lockd/debug.h
+++ b/include/linux/lockd/debug.h
@@ -44,14 +44,4 @@
 #define NLMDBG_XDR		0x0100
 #define NLMDBG_ALL		0x7fff
 
-
-/*
- * Support for printing NLM cookies in dprintk()
- */
-#ifdef RPC_DEBUG
-struct nlm_cookie;
-/* Call this function with the BKL held (it uses a static buffer) */
-extern const char *nlmdbg_cookie2a(const struct nlm_cookie *);
-#endif
-
 #endif /* LINUX_LOCKD_DEBUG_H */

