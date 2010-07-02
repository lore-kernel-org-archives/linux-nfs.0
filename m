From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/22] lockd: Move nlmdbg_cookie2a() to svclock.c
Date: Fri, 02 Jul 2010 13:21:41 -0400
Message-ID: <20100702172141.8761.1849.stgit@ellison.1015granger.net>
References: <20100702165935.8761.88528.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:53738 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759365Ab0GBRVp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 13:21:45 -0400
Received: by pwi5 with SMTP id 5so708830pwi.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 10:21:45 -0700 (PDT)
In-Reply-To: <20100702165935.8761.88528.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.  nlmdbg_cookie2a() is used only in svclock.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svclock.c          |   30 ++++++++++++++++++++++++++++++
 fs/lockd/xdr.c              |   29 -----------------------------
 include/linux/lockd/debug.h |   10 ----------
 3 files changed, 30 insertions(+), 39 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 84055d3..48d7447 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -47,6 +47,7 @@ static void	nlmsvc_remove_block(struct nlm_block *block);
 static int nlmsvc_setgrantargs(struct nlm_rqst *call, struct nlm_lock *lock);
 static void nlmsvc_freegrantargs(struct nlm_rqst *call);
 static const struct rpc_call_ops nlmsvc_grant_ops;
+static const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie);
 
 /*
  * The list of blocked locks to retry
@@ -922,3 +923,32 @@ nlmsvc_retry_blocked(void)
 
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

