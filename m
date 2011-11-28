Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:46890 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834Ab1K1UBm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Nov 2011 15:01:42 -0500
From: Jeff Layton <jlayton@redhat.com>
To: rjw@sisk.pl
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, tj@kernel.org, john@calva.com,
        trond.myklebust@netapp.com, marek.belisko@gmail.com,
        awilliam@redhat.com
Subject: [PATCH v3 2/2] nfs: make TASK_KILLABLE sleeps attempt to freeze
Date: Mon, 28 Nov 2011 15:01:28 -0500
Message-Id: <1322510488-21189-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1322510488-21189-1-git-send-email-jlayton@redhat.com>
References: <1322510488-21189-1-git-send-email-jlayton@redhat.com>
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
 include/linux/freezer.h |   19 +++++++++++++++++++
 5 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 50a15fa..bf3a57b 100644
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
index d4bc9ed9..9194395 100644
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
index be2bbac..b28bb19 100644
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
@@ -3950,7 +3951,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 static unsigned long
 nfs4_set_lock_task_retry(unsigned long timeout)
 {
-	schedule_timeout_killable(timeout);
+	freezable_schedule_timeout_killable(timeout);
 	timeout <<= 1;
 	if (timeout > NFS4_LOCK_MAXTIMEOUT)
 		return NFS4_LOCK_MAXTIMEOUT;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index f48125d..0c672588 100644
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
index fda3ac6..fc68c53 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -154,6 +154,22 @@ static inline void set_freezable_with_signal(void)
 })
 
 /*
+ * Like schedule_timeout_killable(), but should not block the freezer. It may
+ * end up returning immediately if it ends up racing with the freezer. Callers
+ * must be able to deal with the loose wakeup timing that can occur when the
+ * freezer races in. When that occurs, this function will return the timeout
+ * value instead of 0.
+ */
+#define freezable_schedule_timeout_killable(timeout)			\
+({									\
+	freezer_do_not_count();						\
+	if (!try_to_freeze())						\
+		return timeout;						\
+	schedule_timeout_killable(timeout);				\
+	freezer_count();						\
+})
+
+/*
  * Freezer-friendly wrappers around wait_event_interruptible(),
  * wait_event_killable() and wait_event_interruptible_timeout(), originally
  * defined in <linux/wait.h>
@@ -215,6 +231,9 @@ static inline void set_freezable_with_signal(void) {}
 
 #define freezable_schedule()  schedule()
 
+#define freezable_schedule_timeout_killable(timeout)			\
+	schedule_timeout_killable(timeout)
+
 #define wait_event_freezable(wq, condition)				\
 		wait_event_interruptible(wq, condition)
 
-- 
1.7.6.4

