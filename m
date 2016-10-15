Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0052.hostedemail.com ([216.40.44.52]:37515 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751332AbcJOVJH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Oct 2016 17:09:07 -0400
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
        by smtpgrave03.hostedemail.com (Postfix) with ESMTP id 9A3BF28EF0D
        for <linux-nfs@vger.kernel.org>; Sat, 15 Oct 2016 20:59:08 +0000 (UTC)
From: Joe Perches <joe@perches.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] sunrpc & nfs: Add and use dprintk_cont macros
Date: Sat, 15 Oct 2016 13:59:03 -0700
Message-Id: <bcb690c3e552f9f0fb9e89ef0261a38cc0dd85bb.1476564858.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow line continuations to work properly with KERN_CONT.

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/nfs/write.c               |  6 ++---
 include/linux/sunrpc/debug.h | 57 ++++++++++++++++++++++++++++++--------------
 2 files changed, 42 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 53211838f72a..508efa813475 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1788,7 +1788,7 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 		if (status < 0) {
 			nfs_context_set_write_error(req->wb_context, status);
 			nfs_inode_remove_request(req);
-			dprintk(", error = %d\n", status);
+			dprintk_cont(", error = %d\n", status);
 			goto next;
 		}
 
@@ -1797,11 +1797,11 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 		if (!nfs_write_verifier_cmp(&req->wb_verf, &data->verf.verifier)) {
 			/* We have a match */
 			nfs_inode_remove_request(req);
-			dprintk(" OK\n");
+			dprintk_cont(" OK\n");
 			goto next;
 		}
 		/* We have a mismatch. Write the page again */
-		dprintk(" mismatch\n");
+		dprintk_cont(" mismatch\n");
 		nfs_mark_request_dirty(req);
 		set_bit(NFS_CONTEXT_RESEND_WRITES, &req->wb_context->flags);
 	next:
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 59a7889e15db..a44c479b09e0 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -20,33 +20,54 @@ extern unsigned int		nfsd_debug;
 extern unsigned int		nlm_debug;
 #endif
 
-#define dprintk(args...)	dfprintk(FACILITY, ## args)
-#define dprintk_rcu(args...)	dfprintk_rcu(FACILITY, ## args)
+#define dprintk(fmt, ...)						\
+	dfprintk(FACILITY, fmt, ##__VA_ARGS__)
+#define dprintk_cont(fmt, ...)						\
+	dfprintk_cont(FACILITY, fmt, ##__VA_ARGS__)
+#define dprintk_rcu(fmt, ...)						\
+	dfprintk_rcu(FACILITY, fmt, ##__VA_ARGS__)
+#define dprintk_rcu_cont(fmt, ...)					\
+	dfprintk_rcu_cont(FACILITY, fmt, ##__VA_ARGS__)
 
 #undef ifdebug
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
 
-# define dfprintk(fac, args...)	\
-	do { \
-		ifdebug(fac) \
-			printk(KERN_DEFAULT args); \
-	} while (0)
-
-# define dfprintk_rcu(fac, args...)	\
-	do { \
-		ifdebug(fac) { \
-			rcu_read_lock(); \
-			printk(KERN_DEFAULT args); \
-			rcu_read_unlock(); \
-		} \
-	} while (0)
+# define dfprintk(fac, fmt, ...)					\
+do {									\
+	ifdebug(fac)							\
+		printk(KERN_DEFAULT fmt, ##__VA_ARGS__);		\
+} while (0)
+
+# define dfprintk_cont(fac, fmt, ...)					\
+do {									\
+	ifdebug(fac)							\
+		printk(KERN_CONT fmt, ##__VA_ARGS__);			\
+} while (0)
+
+# define dfprintk_rcu(fac, fmt, ...)					\
+do {									\
+	ifdebug(fac) {							\
+		rcu_read_lock();					\
+		printk(KERN_DEFAULT fmt, ##__VA_ARGS__);		\
+		rcu_read_unlock();					\
+	}								\
+} while (0)
+
+# define dfprintk_rcu_cont(fac, fmt, ...)				\
+do {									\
+	ifdebug(fac) {							\
+		rcu_read_lock();					\
+		printk(KERN_CONT fmt, ##__VA_ARGS__);			\
+		rcu_read_unlock();					\
+	}								\
+} while (0)
 
 # define RPC_IFDEBUG(x)		x
 #else
 # define ifdebug(fac)		if (0)
-# define dfprintk(fac, args...)	do {} while (0)
-# define dfprintk_rcu(fac, args...)	do {} while (0)
+# define dfprintk(fac, fmt, ...)	do {} while (0)
+# define dfprintk_rcu(fac, fmt, ...)	do {} while (0)
 # define RPC_IFDEBUG(x)
 #endif
 
-- 
2.10.0.rc2.1.g053435c

