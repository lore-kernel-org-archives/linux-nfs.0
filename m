Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:53008 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766Ab1I1Lwx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Sep 2011 07:52:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com, smfrench@gmail.com, pavel@ucw.cz, rjw@sisk.pl
Cc: linux-pm@lists.linux-foundation.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, john@Calva.COM,
        linux-kernel@vger.kernel.org
Subject: [PATCH 4/4] nfs: make TASK_KILLABLE sleeps attempt to freeze
Date: Wed, 28 Sep 2011 07:52:41 -0400
Message-Id: <1317210761-11518-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1317210761-11518-1-git-send-email-jlayton@redhat.com>
References: <1317210761-11518-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Allow the TASK_KILLABLE sleeps in NFS layer to respect the freezer. This
should allow suspend and hibernate events to occur, even when there are
RPC's pending on the wire.

Tested-by: John Hughes <john@Calva.COM>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c    |    4 +++-
 fs/nfs/nfs3proc.c |    3 ++-
 fs/nfs/nfs4proc.c |   12 ++++++++----
 fs/nfs/proc.c     |    3 ++-
 4 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fe12037..b7c4301 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -38,6 +38,7 @@
 #include <linux/nfs_xdr.h>
 #include <linux/slab.h>
 #include <linux/compat.h>
+#include <linux/freezer.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -77,7 +78,8 @@ int nfs_wait_bit_killable(void *word)
 {
 	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
-	schedule();
+	if (!try_to_freeze())
+		schedule();
 	return 0;
 }
 
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 85f1690..ee64bf3 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -32,7 +32,8 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 		res = rpc_call_sync(clnt, msg, flags);
 		if (res != -EJUKEBOX && res != -EKEYEXPIRED)
 			break;
-		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
+		if (!try_to_freeze())
+			schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
 		res = -ERESTARTSYS;
 	} while (!fatal_signal_pending(current));
 	return res;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4700fae..12f92dd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -244,10 +244,12 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 		*timeout = NFS4_POLL_RETRY_MIN;
 	if (*timeout > NFS4_POLL_RETRY_MAX)
 		*timeout = NFS4_POLL_RETRY_MAX;
-	schedule_timeout_killable(*timeout);
+	if (!try_to_freeze()) {
+		schedule_timeout_killable(*timeout);
+		*timeout <<= 1;
+	}
 	if (fatal_signal_pending(current))
 		res = -ERESTARTSYS;
-	*timeout <<= 1;
 	return res;
 }
 
@@ -3970,8 +3972,10 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 static unsigned long
 nfs4_set_lock_task_retry(unsigned long timeout)
 {
-	schedule_timeout_killable(timeout);
-	timeout <<= 1;
+	if (!try_to_freeze()) {
+		schedule_timeout_killable(timeout);
+		timeout <<= 1;
+	}
 	if (timeout > NFS4_LOCK_MAXTIMEOUT)
 		return NFS4_LOCK_MAXTIMEOUT;
 	return timeout;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index ac40b85..e3f03d1 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -59,7 +59,8 @@ nfs_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 		res = rpc_call_sync(clnt, msg, flags);
 		if (res != -EKEYEXPIRED)
 			break;
-		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
+		if (!try_to_freeze())
+			schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
 		res = -ERESTARTSYS;
 	} while (!fatal_signal_pending(current));
 	return res;
-- 
1.7.6.2

