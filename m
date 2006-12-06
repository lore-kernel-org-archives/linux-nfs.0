From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Wed, 6 Dec 2006 15:08:43 -0500
Message-ID: <20061206200843.GI1714@fieldses.org>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu> <70549752c06e54117024429649fd7aa813f21bec.1165380893.git.bfields@citi.umich.edu> <20061206154951.GB16378@redhat.com> <20061206195722.GH1714@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: David Teigland <teigland@redhat.com>
In-Reply-To: <20061206195722.GH1714@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Dec 06, 2006 at 02:57:22PM -0500, J. Bruce Fields wrote:
> On Wed, Dec 06, 2006 at 09:49:51AM -0600, David Teigland wrote:
> > The gfs side looks fine to me.  Did you forget to call fl_notify from
> > gdlm_plock_callback() or am I missing something?
> 
> Yes, looks like we missed something, thanks.  This code's an rfc (not
> even tested), so don't apply it yet!  What we should have there is
> something like:
> 
> 	rv = op->info.rv;
> 
> 	if (fl_notify(fl, NULL, rv)) {
> 		/* XXX: We need to cancel the lock here: */
> 		printk("gfs2 lock granted after lock request failed; dangling lock!\n");
> 	}

(And note in the patch I sent out I stuck this in the wrong place--in
the synchronous instead of the asynchronous code.  So the patch should
have been something closer to the following.)

--b.

diff --git a/fs/gfs2/lm.c b/fs/gfs2/lm.c
index effe4a3..cf7fd52 100644
--- a/fs/gfs2/lm.c
+++ b/fs/gfs2/lm.c
@@ -197,6 +197,16 @@ int gfs2_lm_plock(struct gfs2_sbd *sdp, struct lm_lockname *name,
 	return error;
 }
 
+int gfs2_lm_plock_async(struct gfs2_sbd *sdp, struct lm_lockname *name,
+		  struct file *file, int cmd, struct file_lock *fl)
+{
+	int error = -EIO;
+	if (likely(!test_bit(SDF_SHUTDOWN, &sdp->sd_flags)))
+		error = sdp->sd_lockstruct.ls_ops->lm_plock_async(
+				sdp->sd_lockstruct.ls_lockspace, name, file, cmd, fl);
+	return error;
+}
+
 int gfs2_lm_punlock(struct gfs2_sbd *sdp, struct lm_lockname *name,
 		    struct file *file, struct file_lock *fl)
 {
diff --git a/fs/gfs2/lm.h b/fs/gfs2/lm.h
index 21cdc30..1ddd1fd 100644
--- a/fs/gfs2/lm.h
+++ b/fs/gfs2/lm.h
@@ -34,6 +34,8 @@ int gfs2_lm_plock_get(struct gfs2_sbd *sdp, struct lm_lockname *name,
 		      struct file *file, struct file_lock *fl);
 int gfs2_lm_plock(struct gfs2_sbd *sdp, struct lm_lockname *name,
 		  struct file *file, int cmd, struct file_lock *fl);
+int gfs2_lm_plock_async(struct gfs2_sbd *sdp, struct lm_lockname *name,
+		  struct file *file, int cmd, struct file_lock *fl);
 int gfs2_lm_punlock(struct gfs2_sbd *sdp, struct lm_lockname *name,
 		    struct file *file, struct file_lock *fl);
 void gfs2_lm_recovery_done(struct gfs2_sbd *sdp, unsigned int jid,
diff --git a/fs/gfs2/locking/dlm/lock_dlm.h b/fs/gfs2/locking/dlm/lock_dlm.h
index 33af707..82af860 100644
--- a/fs/gfs2/locking/dlm/lock_dlm.h
+++ b/fs/gfs2/locking/dlm/lock_dlm.h
@@ -179,6 +179,8 @@ int gdlm_plock_init(void);
 void gdlm_plock_exit(void);
 int gdlm_plock(void *, struct lm_lockname *, struct file *, int,
 		struct file_lock *);
+int gdlm_plock_async(void *, struct lm_lockname *, struct file *, int,
+		struct file_lock *);
 int gdlm_plock_get(void *, struct lm_lockname *, struct file *,
 		struct file_lock *);
 int gdlm_punlock(void *, struct lm_lockname *, struct file *,
diff --git a/fs/gfs2/locking/dlm/mount.c b/fs/gfs2/locking/dlm/mount.c
index cdd1694..4339e3f 100644
--- a/fs/gfs2/locking/dlm/mount.c
+++ b/fs/gfs2/locking/dlm/mount.c
@@ -244,6 +244,7 @@ const struct lm_lockops gdlm_ops = {
 	.lm_lock = gdlm_lock,
 	.lm_unlock = gdlm_unlock,
 	.lm_plock = gdlm_plock,
+	.lm_plock_async = gdlm_plock_async,
 	.lm_punlock = gdlm_punlock,
 	.lm_plock_get = gdlm_plock_get,
 	.lm_cancel = gdlm_cancel,
diff --git a/fs/gfs2/locking/dlm/plock.c b/fs/gfs2/locking/dlm/plock.c
index 7365aec..f91a18a 100644
--- a/fs/gfs2/locking/dlm/plock.c
+++ b/fs/gfs2/locking/dlm/plock.c
@@ -102,6 +102,94 @@ int gdlm_plock(void *lockspace, struct lm_lockname *name,
 	return rv;
 }
 
+int gdlm_plock_async(void *lockspace, struct lm_lockname *name,
+	       struct file *file, int cmd, struct file_lock *fl)
+{
+	struct gdlm_ls *ls = lockspace;
+	struct plock_op *op;
+	int rv;
+
+	op = kzalloc(sizeof(*op), GFP_KERNEL);
+	if (!op)
+		return -ENOMEM;
+
+	op->info.optype		= GDLM_PLOCK_OP_LOCK;
+	op->info.pid		= fl->fl_pid;
+	op->info.ex		= (fl->fl_type == F_WRLCK);
+	op->info.wait		= IS_SETLKW(cmd);
+	op->info.fsid		= ls->id;
+	op->info.number		= name->ln_number;
+	op->info.start		= fl->fl_start;
+	op->info.end		= fl->fl_end;
+	op->info.owner		= (__u64)(long) fl->fl_owner;
+	if (fl->fl_lmops) {
+		op->info.callback	= fl->fl_lmops->fl_notify;
+		/* might need to make a copy */
+		op->info.fl		= fl;
+		op->info.file		= file;
+	} else
+		op->info.callback	= NULL;
+
+	send_op(op);
+
+	if (op->info.callback == NULL)
+		wait_event(recv_wq, (op->done != 0));
+	else
+		return -EINPROGRESS;
+		
+	spin_lock(&ops_lock);
+	if (!list_empty(&op->list)) {
+		printk(KERN_INFO "plock op on list\n");
+		list_del(&op->list);
+	}
+	spin_unlock(&ops_lock);
+
+	rv = op->info.rv;
+
+	if (!rv) {
+		if (posix_lock_file_wait(file, fl) < 0)
+			log_error("gdlm_plock: vfs lock error %x,%llx",
+				  name->ln_type,
+				  (unsigned long long)name->ln_number);
+	}
+
+	kfree(op);
+	return rv;
+}
+
+static void gdlm_plock_callback(struct plock_op *op)
+{
+	struct file *file;
+	struct file_lock *fl;
+	int rv;
+
+	spin_lock(&ops_lock);
+	if (!list_empty(&op->list)) {
+		printk(KERN_INFO "plock op on list\n");
+		list_del(&op->list);
+	}
+	spin_unlock(&ops_lock);
+
+	rv = op->info.rv;
+
+	if (fl_notify(fl, NULL, rv)) {
+		/* XXX: We need to cancel the lock here: */
+		printk("gfs2 lock granted after lock request failed; dangling lock!\n");
+	}
+
+	if (!rv) {
+		/* check if the following are still valid or make a copy */
+		file = op->info.file;
+		fl = op->info.fl;
+		
+		if (posix_lock_file_wait(file, fl) < 0)
+			log_error("gdlm_plock: vfs lock error file %p fl %p",
+				  file, fl);
+	}
+
+	kfree(op);
+}
+
 int gdlm_punlock(void *lockspace, struct lm_lockname *name,
 		 struct file *file, struct file_lock *fl)
 {
@@ -242,8 +330,12 @@ static ssize_t dev_write(struct file *file, const char __user *u, size_t count,
 	}
 	spin_unlock(&ops_lock);
 
-	if (found)
-		wake_up(&recv_wq);
+	if (found) {
+		if (op->info.callback)
+			gdlm_plock_callback(op);
+		else
+			wake_up(&recv_wq);
+	}
 	else
 		printk(KERN_INFO "gdlm dev_write no op %x %llx\n", info.fsid,
 			(unsigned long long)info.number);
diff --git a/fs/gfs2/ops_export.c b/fs/gfs2/ops_export.c
index 86127d9..80ca84f 100644
--- a/fs/gfs2/ops_export.c
+++ b/fs/gfs2/ops_export.c
@@ -22,6 +22,7 @@
 #include "glock.h"
 #include "glops.h"
 #include "inode.h"
+#include "lm.h"
 #include "ops_export.h"
 #include "rgrp.h"
 #include "util.h"
@@ -287,6 +288,56 @@ fail:
 	gfs2_glock_dq_uninit(&i_gh);
 	return ERR_PTR(error);
 }
+/**
+ * gfs2_exp_lock - acquire/release a posix lock on a file
+ * @file: the file pointer
+ * @cmd: either modify or retrieve lock state, possibly wait
+ * @fl: type and range of lock
+ *
+ * Returns: errno
+ */
+
+static int gfs2_exp_lock(struct file *file, int cmd, struct file_lock *fl)
+{
+	struct gfs2_inode *ip = GFS2_I(file->f_mapping->host);
+	struct gfs2_sbd *sdp = GFS2_SB(file->f_mapping->host);
+	struct lm_lockname name =
+		{ .ln_number = ip->i_num.no_addr,
+		  .ln_type = LM_TYPE_PLOCK };
+
+	if (!(fl->fl_flags & FL_POSIX))
+		return -ENOLCK;
+	if ((ip->i_di.di_mode & (S_ISGID | S_IXGRP)) == S_ISGID)
+		return -ENOLCK;
+
+	if (sdp->sd_args.ar_localflocks) {
+		if (IS_GETLK(cmd)) {
+			struct file_lock tmp;
+			int ret;
+			ret = posix_test_lock(file, fl, &tmp);
+			fl->fl_type = F_UNLCK;
+			if (ret)
+				memcpy(fl, &tmp, sizeof(struct file_lock));
+			return 0;
+		} else {
+			return posix_lock_file_wait(file, fl);
+		}
+	}
+
+	if (IS_GETLK(cmd))
+		return gfs2_lm_plock_get(sdp, &name, file, fl);
+	else if (fl->fl_type == F_UNLCK)
+		return gfs2_lm_punlock(sdp, &name, file, fl);
+	else {
+		/* If fl_notify is set make an async lock request
+		   and reply withh -EINPROGRESS. When lock is granted
+		   the gfs2_lm_plock_async should callback to fl_notify */
+		if (fl->fl_lmops->fl_notify)
+			return gfs2_lm_plock_async(sdp, &name, file, cmd, fl);
+		else
+			return gfs2_lm_plock(sdp, &name, file, cmd, fl);
+	}
+}
 
 struct export_operations gfs2_export_ops = {
 	.decode_fh = gfs2_decode_fh,
@@ -294,5 +345,6 @@ struct export_operations gfs2_export_ops = {
 	.get_name = gfs2_get_name,
 	.get_parent = gfs2_get_parent,
 	.get_dentry = gfs2_get_dentry,
+	.lock = gfs2_exp_lock,
 };
 
diff --git a/include/linux/lm_interface.h b/include/linux/lm_interface.h
index 1418fdc..28d5445 100644
--- a/include/linux/lm_interface.h
+++ b/include/linux/lm_interface.h
@@ -213,6 +213,9 @@ struct lm_lockops {
 	int (*lm_plock) (void *lockspace, struct lm_lockname *name,
 			 struct file *file, int cmd, struct file_lock *fl);
 
+	int (*lm_plock_async) (void *lockspace, struct lm_lockname *name,
+			 struct file *file, int cmd, struct file_lock *fl);
+
 	int (*lm_punlock) (void *lockspace, struct lm_lockname *name,
 			   struct file *file, struct file_lock *fl);
 
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
