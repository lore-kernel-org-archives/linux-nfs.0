Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33708 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933689AbcIFPMn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 11:12:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/9] nfs: add a freezable_schedule_timeout_unsafe() and use it when waiting to retry LOCK
Date: Tue,  6 Sep 2016 11:12:35 -0400
Message-Id: <1473174760-29859-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
References: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We actually want to use TASK_INTERRUPTIBLE sleeps here. Once the task
wakes up, if there is a signal pending then we'll be returning an error
anyway. So, we might as well wake up immediately for non-fatal signals
as well. That allows us to return to userland more quickly in that case,
but won't change the error that userland sees.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c       |  3 ++-
 include/linux/freezer.h | 13 +++++++++++++
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e3bf95369daf..e9232d71bc64 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5537,7 +5537,8 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 static unsigned long
 nfs4_set_lock_task_retry(unsigned long timeout)
 {
-	freezable_schedule_timeout_killable_unsafe(timeout);
+	set_current_state(TASK_INTERRUPTIBLE);
+	freezable_schedule_timeout_unsafe(timeout);
 	timeout <<= 1;
 	if (timeout > NFS4_LOCK_MAXTIMEOUT)
 		return NFS4_LOCK_MAXTIMEOUT;
diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index dd03e837ebb7..fe31601e7f55 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -197,6 +197,19 @@ static inline long freezable_schedule_timeout(long timeout)
  * Like schedule_timeout_interruptible(), but should not block the freezer.  Do not
  * call this with locks held.
  */
+static inline long freezable_schedule_timeout_unsafe(long timeout)
+{
+	long __retval;
+	freezer_do_not_count();
+	__retval = schedule_timeout(timeout);
+	freezer_count_unsafe();
+	return __retval;
+}
+
+/*
+ * Like schedule_timeout_interruptible(), but should not block the freezer.  Do not
+ * call this with locks held.
+ */
 static inline long freezable_schedule_timeout_interruptible(long timeout)
 {
 	long __retval;
-- 
2.7.4

