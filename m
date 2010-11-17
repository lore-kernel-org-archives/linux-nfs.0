Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52633 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933795Ab0KQSA2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 13:00:28 -0500
Received: by mail-iw0-f174.google.com with SMTP id 35so2387538iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 10:00:28 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/12] lockd: Move nlmdbg_cookie2a() to svclock.c
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 13:00:24 -0500
Message-ID: <20101117180024.29429.94497.stgit@matisse.1015granger.net>
In-Reply-To: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
References: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
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
index c462d34..8e3b5f1 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -47,6 +47,7 @@ static void	nlmsvc_remove_block(struct nlm_block *block);
 static int nlmsvc_setgrantargs(struct nlm_rqst *call, struct nlm_lock *lock);
 static void nlmsvc_freegrantargs(struct nlm_rqst *call);
 static const struct rpc_call_ops nlmsvc_grant_ops;
+static const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie);
 
 /*
  * The list of blocked locks to retry
@@ -935,3 +936,32 @@ nlmsvc_retry_blocked(void)
 
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

