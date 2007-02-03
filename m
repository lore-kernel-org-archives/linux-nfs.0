From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 14/14] gfs2: nfs lock support for gfs2
Date: Sat,  3 Feb 2007 00:34:10 -0500
Message-ID: <31147.4227150486$1170480904@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email->
	<11704808502512-git-send-email-> <11704808513862-git-send-email->
	<1170480851972-git-send-email->
	<11704808513070-git-send-email-> <117048085185-git-send-email->
	<11704808513263-git-send-email-> <11704808513185-git-send-email->
	<11704808511238-git-send-email-> <11704808513085-git-send-email->
	<11704808521765-git-send-email-> <11704808523686-git-send-email->
	<11704808522949-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDDXS-0001HY-Bf
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:17 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDDXS-0001C7-TT
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:16 -0800
In-Reply-To: <11704808522949-git-send-email->
Message-Id: <6d1e339108dad3e204a1eb53e736a2a0f73dda22.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

Add NFS lock support to GFS2.  (Untested.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/gfs2/locking/dlm/plock.c    |   76 +++++++++++++++++++++++++++++++++++++--
 fs/gfs2/ops_file.c             |    5 +++
 include/linux/lock_dlm_plock.h |    3 ++
 3 files changed, 80 insertions(+), 4 deletions(-)

diff --git a/fs/gfs2/locking/dlm/plock.c b/fs/gfs2/locking/dlm/plock.c
index 3799f19..da6c01c 100644
--- a/fs/gfs2/locking/dlm/plock.c
+++ b/fs/gfs2/locking/dlm/plock.c
@@ -59,6 +59,8 @@ static void send_op(struct plock_op *op)
 	wake_up(&send_wq);
 }
 
+/* XXX: unlock? cancel? ... */
+
 int gdlm_plock(void *lockspace, struct lm_lockname *name,
 	       struct file *file, int cmd, struct file_lock *fl)
 {
@@ -79,9 +81,20 @@ int gdlm_plock(void *lockspace, struct lm_lockname *name,
 	op->info.start		= fl->fl_start;
 	op->info.end		= fl->fl_end;
 	op->info.owner		= (__u64)(long) fl->fl_owner;
+	if (fl->fl_lmops && fl->fl_lmops->fl_notify) {
+		op->info.callback	= fl->fl_lmops->fl_notify;
+		/* might need to make a copy */
+		op->info.fl		= fl;
+		op->info.file		= file;
+	} else
+		op->info.callback	= NULL;
 
 	send_op(op);
-	wait_event(recv_wq, (op->done != 0));
+
+	if (op->info.callback == NULL)
+		wait_event(recv_wq, (op->done != 0));
+	else
+		return -EINPROGRESS;
 
 	spin_lock(&ops_lock);
 	if (!list_empty(&op->list)) {
@@ -103,6 +116,58 @@ int gdlm_plock(void *lockspace, struct lm_lockname *name,
 	return rv;
 }
 
+/* Returns failure iff a succesful lock operation should be canceled */
+static int gdlm_plock_callback(struct plock_op *op)
+{
+	struct file *file;
+	struct file_lock *fl;
+	int (*notify)(void *, void *, int) = NULL;
+	int rv = 0;
+
+	spin_lock(&ops_lock);
+	if (!list_empty(&op->list)) {
+		printk(KERN_INFO "plock op on list\n");
+		list_del(&op->list);
+	}
+	spin_unlock(&ops_lock);
+
+	/* check if the following 2 are still valid or make a copy */
+	file = op->info.file;
+	fl = op->info.fl;
+	notify = op->info.callback;
+
+	if (op->info.rv) {
+		notify(fl, NULL, op->info.rv);
+		goto out;
+	}
+
+	/* got fs lock; bookkeep locally as well: */
+	if (posix_lock_file(file, fl)) {
+		/*
+		 * This can only happen in the case of kmalloc() failure.
+		 * The filesystem's own lock is the authoritative lock,
+		 * so a failure to get the lock locally is not a disaster.
+		 * As long as GFS cannot reliably cancel locks (especially
+		 * in a low-memory situation), we're better off ignoring
+		 * this failure than trying to recover.
+		 */
+		log_error("gdlm_plock: vfs lock error file %p fl %p",
+				file, fl);
+	}
+
+	rv = notify(fl, NULL, 0);
+	if (rv) {
+		/* XXX: We need to cancel the fs lock here: */
+		printk("gfs2 lock granted after lock request failed;"
+						" dangling lock!\n");
+		goto out;
+	}
+
+out:
+	kfree(op);
+	return rv;
+}
+
 int gdlm_punlock(void *lockspace, struct lm_lockname *name,
 		 struct file *file, struct file_lock *fl)
 {
@@ -243,9 +308,12 @@ static ssize_t dev_write(struct file *file, const char __user *u, size_t count,
 	}
 	spin_unlock(&ops_lock);
 
-	if (found)
-		wake_up(&recv_wq);
-	else
+	if (found) {
+		if (op->info.callback)
+			count = gdlm_plock_callback(op);
+		else
+			wake_up(&recv_wq);
+	} else
 		printk(KERN_INFO "gdlm dev_write no op %x %llx\n", info.fsid,
 			(unsigned long long)info.number);
 	return count;
diff --git a/fs/gfs2/ops_file.c b/fs/gfs2/ops_file.c
index faa07e4..acf23b2 100644
--- a/fs/gfs2/ops_file.c
+++ b/fs/gfs2/ops_file.c
@@ -576,6 +576,11 @@ static int gfs2_lock(struct file *file, int cmd, struct file_lock *fl)
 		}
 	}
 
+	if (cmd == F_CANCELLK) {
+		/* Hack: */
+		cmd = F_SETLK;
+		fl->fl_type = F_UNLCK;
+	}
 	if (IS_GETLK(cmd))
 		return gfs2_lm_plock_get(sdp, &name, file, fl);
 	else if (fl->fl_type == F_UNLCK)
diff --git a/include/linux/lock_dlm_plock.h b/include/linux/lock_dlm_plock.h
index fc34151..809c5b7 100644
--- a/include/linux/lock_dlm_plock.h
+++ b/include/linux/lock_dlm_plock.h
@@ -35,6 +35,9 @@ struct gdlm_plock_info {
 	__u64 start;
 	__u64 end;
 	__u64 owner;
+	void *callback;
+	void *fl;
+	void *file;
 };
 
 #endif
-- 
1.5.0.rc1.g72fe


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
