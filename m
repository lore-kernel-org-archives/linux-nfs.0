Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35515 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756184Ab1KURkc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 12:40:32 -0500
From: Jeff Layton <jlayton@redhat.com>
To: rjw@sisk.pl
Cc: linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org, john@calva.com,
        tj@kernel.org, trond.myklebust@netapp.com
Subject: [PATCH 2/2] nfs: make TASK_KILLABLE sleeps attempt to freeze
Date: Mon, 21 Nov 2011 12:40:21 -0500
Message-Id: <1321897221-2278-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1321897221-2278-1-git-send-email-jlayton@redhat.com>
References: <1321897221-2278-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wrap the TASK_KILLABLE sleeps in NFS layer in freezer_do_not_count and
freezer_count calls. This allows the freezer to skip these processes
when they are sleeping while looping on EJUKEBOX or NFS4ERR_DELAY sorts
of errors.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c          |    3 ++-
 fs/nfs/nfs3proc.c       |    3 ++-
 fs/nfs/nfs4proc.c       |    5 +++--
 fs/nfs/proc.c           |    3 ++-
 include/linux/freezer.h |   12 +++++++++++-
 5 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c07a55a..f36543a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -38,6 +38,7 @@
 #include <linux/nfs_xdr.h>
 #include <linux/slab.h>
 #include <linux/compat.h>
+#include <linux/freezer.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -77,7 +78,7 @@ int nfs_wait_bit_killable(void *word)
 {
 	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
-	schedule();
+	freezable_schedule();
 	return 0;
 }
 
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 85f1690..cc1d1e1 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -17,6 +17,7 @@
 #include <linux/nfs_page.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfs_mount.h>
+#include <linux/freezer.h>
 
 #include "iostat.h"
 #include "internal.h"
@@ -32,7 +33,7 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 		res = rpc_call_sync(clnt, msg, flags);
 		if (res != -EJUKEBOX && res != -EKEYEXPIRED)
 			break;
-		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
+		freezable_schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
 		res = -ERESTARTSYS;
 	} while (!fatal_signal_pending(current));
 	return res;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b60fddf..988a0e1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -53,6 +53,7 @@
 #include <linux/sunrpc/bc_xprt.h>
 #include <linux/xattr.h>
 #include <linux/utsname.h>
+#include <linux/freezer.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -241,7 +242,7 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 		*timeout = NFS4_POLL_RETRY_MIN;
 	if (*timeout > NFS4_POLL_RETRY_MAX)
 		*timeout = NFS4_POLL_RETRY_MAX;
-	schedule_timeout_killable(*timeout);
+	freezable_schedule_timeout_killable(*timeout);
 	if (fatal_signal_pending(current))
 		res = -ERESTARTSYS;
 	*timeout <<= 1;
@@ -3951,7 +3952,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 static unsigned long
 nfs4_set_lock_task_retry(unsigned long timeout)
 {
-	schedule_timeout_killable(timeout);
+	freezable_schedule_timeout_killable(timeout);
 	timeout <<= 1;
 	if (timeout > NFS4_LOCK_MAXTIMEOUT)
 		return NFS4_LOCK_MAXTIMEOUT;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index ac40b85..4dda8b5 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -41,6 +41,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/lockd/bind.h>
+#include <linux/freezer.h>
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
@@ -59,7 +60,7 @@ nfs_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 		res = rpc_call_sync(clnt, msg, flags);
 		if (res != -EKEYEXPIRED)
 			break;
-		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
+		freezable_schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
 		res = -ERESTARTSYS;
 	} while (!fatal_signal_pending(current));
 	return res;
diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 8b60dd0..235cb05 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -135,7 +135,7 @@ static inline void set_freezable_with_signal(void)
 }
 
 /*
- * Freezer-friendly macro around schedule() in the kernel.
+ * Freezer-friendly macros around some sleeping functions.
  */
 #define freezable_schedule()						\
 ({									\
@@ -144,6 +144,13 @@ static inline void set_freezable_with_signal(void)
 	freezer_count();						\
 })
 
+#define freezable_schedule_timeout_killable(timeout)			\
+({									\
+	freezer_do_not_count();						\
+	schedule_timeout_killable(timeout);				\
+	freezer_count();						\
+})
+
 /*
  * Freezer-friendly wrappers around wait_event_interruptible(),
  * wait_event_killable() and wait_event_interruptible_timeout(), originally
@@ -206,6 +213,9 @@ static inline void set_freezable_with_signal(void) {}
 
 #define freezable_schedule()  schedule()
 
+#define freezable_schedule_timeout_killable(timeout)			\
+	schedule_timeout_killable(timeout)
+
 #define wait_event_freezable(wq, condition)				\
 		wait_event_interruptible(wq, condition)
 
-- 
1.7.6.4

