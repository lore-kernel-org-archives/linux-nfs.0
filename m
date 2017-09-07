Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33256 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752689AbdIGWBt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Sep 2017 18:01:49 -0400
Date: Thu, 7 Sep 2017 18:01:49 -0400
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 3/3] nfsd: clients don't need to break their own
 delegations
Message-ID: <20170907220149.GC4731@fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
 <1503697958-6122-4-git-send-email-bfields@redhat.com>
 <87bmn0ia6i.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87bmn0ia6i.fsf@notabene.neil.brown.name>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 28, 2017 at 02:32:53PM +1000, NeilBrown wrote:
> /* legacy typedef, should eventually be removed */
> typedef void *fl_owner_t;
> 
> 
> Maybe you could do the world a favor and remove fl_owner_t in a
> preliminary patch :-)

Partly scripted, still a bit tedious, but I think it's right.  Honestly
I don't know what the motivation for the comment was, though.  Are there
no documentation or type-checking benefits to having the typdef?

The main annoyance was having this defined as a files_struct pointer,
which Christoph fixed some time ago.

--b.

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 73e7d91f03dc..758ca1591b0c 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -864,7 +864,7 @@ struct file_operations {
 	int (*mmap) (struct file *, struct vm_area_struct *);
 	int (*mremap)(struct file *, struct vm_area_struct *);
 	int (*open) (struct inode *, struct file *);
-	int (*flush) (struct file *, fl_owner_t id);
+	int (*flush) (struct file *, void *id);
 	int (*release) (struct inode *, struct file *);
 	int (*fsync) (struct file *, loff_t, loff_t, int datasync);
 	int (*fasync) (int, struct file *, int);
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 09f86ebfcc7b..35a185ac0de3 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -1809,7 +1809,7 @@ pfm_syswide_cleanup_other_cpu(pfm_context_t *ctx)
  * When caller is self-monitoring, the context is unloaded.
  */
 static int
-pfm_flush(struct file *filp, fl_owner_t id)
+pfm_flush(struct file *filp, void *id)
 {
 	pfm_context_t *ctx;
 	struct task_struct *task;
diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
index ae2f740a82f1..8783335b3b85 100644
--- a/arch/powerpc/platforms/cell/spufs/file.c
+++ b/arch/powerpc/platforms/cell/spufs/file.c
@@ -1720,7 +1720,7 @@ static unsigned int spufs_mfc_poll(struct file *file,poll_table *wait)
 	return mask;
 }
 
-static int spufs_mfc_flush(struct file *file, fl_owner_t id)
+static int spufs_mfc_flush(struct file *file, void *id)
 {
 	struct spu_context *ctx = file->private_data;
 	int ret;
diff --git a/arch/tile/kernel/hardwall.c b/arch/tile/kernel/hardwall.c
index 2fd1694ac1d0..b2cf21d1edb0 100644
--- a/arch/tile/kernel/hardwall.c
+++ b/arch/tile/kernel/hardwall.c
@@ -1030,7 +1030,7 @@ static long hardwall_compat_ioctl(struct file *file,
 #endif
 
 /* The user process closed the file; revoke access to user networks. */
-static int hardwall_flush(struct file *file, fl_owner_t owner)
+static int hardwall_flush(struct file *file, void *owner)
 {
 	struct hardwall_info *info = file->private_data;
 	struct task_struct *task, *tmp;
diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index f7665c31feca..02bfce18c912 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -3503,7 +3503,7 @@ static int binder_open(struct inode *nodp, struct file *filp)
 	return 0;
 }
 
-static int binder_flush(struct file *filp, fl_owner_t id)
+static int binder_flush(struct file *filp, void *id)
 {
 	struct binder_proc *proc = filp->private_data;
 
diff --git a/drivers/char/ps3flash.c b/drivers/char/ps3flash.c
index b526dc15c271..5a03dd0eb2f1 100644
--- a/drivers/char/ps3flash.c
+++ b/drivers/char/ps3flash.c
@@ -281,7 +281,7 @@ static ssize_t ps3flash_kernel_write(const void *buf, size_t count,
 	return res;
 }
 
-static int ps3flash_flush(struct file *file, fl_owner_t id)
+static int ps3flash_flush(struct file *file, void *id)
 {
 	return ps3flash_writeback(ps3flash_dev);
 }
diff --git a/drivers/char/xillybus/xillybus_core.c b/drivers/char/xillybus/xillybus_core.c
index b6c9cdead7f3..7e04a9df51e3 100644
--- a/drivers/char/xillybus/xillybus_core.c
+++ b/drivers/char/xillybus/xillybus_core.c
@@ -1156,7 +1156,7 @@ static int xillybus_myflush(struct xilly_channel *channel, long timeout)
 	return rc;
 }
 
-static int xillybus_flush(struct file *filp, fl_owner_t id)
+static int xillybus_flush(struct file *filp, void *id)
 {
 	if (!(filp->f_mode & FMODE_WRITE))
 		return 0;
diff --git a/drivers/firmware/efi/capsule-loader.c b/drivers/firmware/efi/capsule-loader.c
index ec8ac5c4dd84..f4d0c4805ec7 100644
--- a/drivers/firmware/efi/capsule-loader.c
+++ b/drivers/firmware/efi/capsule-loader.c
@@ -225,7 +225,7 @@ static ssize_t efi_capsule_write(struct file *file, const char __user *buff,
  *	will be treated as upload termination and will free those completed
  *	buffer pages and -ECANCELED will be returned.
  **/
-static int efi_capsule_flush(struct file *file, fl_owner_t id)
+static int efi_capsule_flush(struct file *file, void *id)
 {
 	int ret = 0;
 	struct capsule_info *cap_info = file->private_data;
diff --git a/drivers/input/evdev.c b/drivers/input/evdev.c
index 925571475005..85117fecc292 100644
--- a/drivers/input/evdev.c
+++ b/drivers/input/evdev.c
@@ -342,7 +342,7 @@ static int evdev_fasync(int fd, struct file *file, int on)
 	return fasync_helper(fd, file, on, &client->fasync);
 }
 
-static int evdev_flush(struct file *file, fl_owner_t id)
+static int evdev_flush(struct file *file, void *id)
 {
 	struct evdev_client *client = file->private_data;
 	struct evdev *evdev = client->evdev;
diff --git a/drivers/misc/mic/scif/scif_fd.c b/drivers/misc/mic/scif/scif_fd.c
index f7e826142a72..c446a1450714 100644
--- a/drivers/misc/mic/scif/scif_fd.c
+++ b/drivers/misc/mic/scif/scif_fd.c
@@ -48,7 +48,7 @@ static unsigned int scif_fdpoll(struct file *f, poll_table *wait)
 	return __scif_pollfd(f, wait, priv);
 }
 
-static int scif_fdflush(struct file *f, fl_owner_t id)
+static int scif_fdflush(struct file *f, void *id)
 {
 	struct scif_endpt *ep = f->private_data;
 
diff --git a/drivers/scsi/osst.c b/drivers/scsi/osst.c
index 929ee7e88120..366bc57f0bfb 100644
--- a/drivers/scsi/osst.c
+++ b/drivers/scsi/osst.c
@@ -4822,7 +4822,7 @@ static int os_scsi_tape_open(struct inode * inode, struct file * filp)
 
 
 /* Flush the tape buffer before close */
-static int os_scsi_tape_flush(struct file * filp, fl_owner_t id)
+static int os_scsi_tape_flush(struct file * filp, void *id)
 {
 	int		      result = 0, result2;
 	struct osst_tape    * STp    = filp->private_data;
diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index 8e5013d9cad4..7d97641fcca9 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -1338,7 +1338,7 @@ static int st_open(struct inode *inode, struct file *filp)
 
 
 /* Flush the tape buffer before close */
-static int st_flush(struct file *filp, fl_owner_t id)
+static int st_flush(struct file *filp, void *id)
 {
 	int result = 0, result2;
 	unsigned char cmd[MAX_COMMAND_SIZE];
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index ab1c85c1ed38..5f12ea3f26d3 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2278,7 +2278,7 @@ static loff_t ll_file_seek(struct file *file, loff_t offset, int origin)
 					ll_file_maxbytes(inode), eof);
 }
 
-static int ll_flush(struct file *file, fl_owner_t id)
+static int ll_flush(struct file *file, void *id)
 {
 	struct inode *inode = file_inode(file);
 	struct ll_inode_info *lli = ll_i2info(inode);
diff --git a/drivers/usb/class/cdc-wdm.c b/drivers/usb/class/cdc-wdm.c
index 8f972247b1c1..cb248f3d9565 100644
--- a/drivers/usb/class/cdc-wdm.c
+++ b/drivers/usb/class/cdc-wdm.c
@@ -582,7 +582,7 @@ static ssize_t wdm_read
 	return rv;
 }
 
-static int wdm_flush(struct file *file, fl_owner_t id)
+static int wdm_flush(struct file *file, void *id)
 {
 	struct wdm_device *desc = file->private_data;
 
diff --git a/drivers/usb/usb-skeleton.c b/drivers/usb/usb-skeleton.c
index bb0bd732e29a..547fe43678e8 100644
--- a/drivers/usb/usb-skeleton.c
+++ b/drivers/usb/usb-skeleton.c
@@ -136,7 +136,7 @@ static int skel_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int skel_flush(struct file *file, fl_owner_t id)
+static int skel_flush(struct file *file, void *id)
 {
 	struct usb_skel *dev;
 	int res;
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 82e16556afea..210838d2fa85 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -728,7 +728,7 @@ extern int afs_writepages(struct address_space *, struct writeback_control *);
 extern void afs_pages_written_back(struct afs_vnode *, struct afs_call *);
 extern ssize_t afs_file_write(struct kiocb *, struct iov_iter *);
 extern int afs_writeback_all(struct afs_vnode *);
-extern int afs_flush(struct file *, fl_owner_t);
+extern int afs_flush(struct file *, void *);
 extern int afs_fsync(struct file *, loff_t, loff_t, int);
 
 /*
diff --git a/fs/afs/write.c b/fs/afs/write.c
index 2d2fccd5044b..a38f03bd6859 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -767,7 +767,7 @@ int afs_fsync(struct file *file, loff_t start, loff_t end, int datasync)
  * Flush out all outstanding writes on a file opened for writing when it is
  * closed.
  */
-int afs_flush(struct file *file, fl_owner_t id)
+int afs_flush(struct file *file, void *id)
 {
 	_enter("");
 
diff --git a/fs/cifs/cifsfs.h b/fs/cifs/cifsfs.h
index 30bf89b1fd9a..914e5af73d32 100644
--- a/fs/cifs/cifsfs.h
+++ b/fs/cifs/cifsfs.h
@@ -108,7 +108,7 @@ extern ssize_t cifs_strict_writev(struct kiocb *iocb, struct iov_iter *from);
 extern int cifs_lock(struct file *, int, struct file_lock *);
 extern int cifs_fsync(struct file *, loff_t, loff_t, int);
 extern int cifs_strict_fsync(struct file *, loff_t, loff_t, int);
-extern int cifs_flush(struct file *, fl_owner_t id);
+extern int cifs_flush(struct file *, void *id);
 extern int cifs_file_mmap(struct file * , struct vm_area_struct *);
 extern int cifs_file_strict_mmap(struct file * , struct vm_area_struct *);
 extern const struct file_operations cifs_dir_ops;
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index bc09df6b473a..bda1fdf46937 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1165,7 +1165,7 @@ cifs_push_mandatory_locks(struct cifsFileInfo *cfile)
 }
 
 static __u32
-hash_lockowner(fl_owner_t owner)
+hash_lockowner(void *owner)
 {
 	return cifs_lock_secret ^ hash32_ptr((const void *)owner);
 }
@@ -2399,7 +2399,7 @@ int cifs_fsync(struct file *file, loff_t start, loff_t end, int datasync)
  * As file closes, flush all cached write data for this inode checking
  * for write behind errors.
  */
-int cifs_flush(struct file *file, fl_owner_t id)
+int cifs_flush(struct file *file, void *id)
 {
 	struct inode *inode = file_inode(file);
 	int rc = 0;
diff --git a/fs/ecryptfs/file.c b/fs/ecryptfs/file.c
index ca4e83750214..535039b38da8 100644
--- a/fs/ecryptfs/file.c
+++ b/fs/ecryptfs/file.c
@@ -290,7 +290,7 @@ static int ecryptfs_dir_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int ecryptfs_flush(struct file *file, fl_owner_t td)
+static int ecryptfs_flush(struct file *file, void *td)
 {
 	struct file *lower_file = ecryptfs_file_to_lower(file);
 
diff --git a/fs/exofs/file.c b/fs/exofs/file.c
index 28645f0640f7..d9e3c7ca3a0c 100644
--- a/fs/exofs/file.c
+++ b/fs/exofs/file.c
@@ -58,7 +58,7 @@ static int exofs_file_fsync(struct file *filp, loff_t start, loff_t end,
 	return ret;
 }
 
-static int exofs_flush(struct file *file, fl_owner_t id)
+static int exofs_flush(struct file *file, void *id)
 {
 	int ret = vfs_fsync(file, 0);
 	/* TODO: Flush the OSD target */
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 3ee4fdc3da9e..89fe98020374 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -254,8 +254,7 @@ void fuse_release_common(struct file *file, int opcode)
 	if (ff->flock) {
 		struct fuse_release_in *inarg = &req->misc.release.in;
 		inarg->release_flags |= FUSE_RELEASE_FLOCK_UNLOCK;
-		inarg->lock_owner = fuse_lock_owner_id(ff->fc,
-						       (fl_owner_t) file);
+		inarg->lock_owner = fuse_lock_owner_id(ff->fc, file);
 	}
 	/* Hold inode until release is finished */
 	req->misc.release.inode = igrab(file_inode(file));
@@ -307,7 +306,7 @@ EXPORT_SYMBOL_GPL(fuse_sync_release);
  * Scramble the ID space with XTEA, so that the value of the files_struct
  * pointer is not exposed to userspace.
  */
-u64 fuse_lock_owner_id(struct fuse_conn *fc, fl_owner_t id)
+u64 fuse_lock_owner_id(struct fuse_conn *fc, void *id)
 {
 	u32 *k = fc->scramble_key;
 	u64 v = (unsigned long) id;
@@ -390,7 +389,7 @@ static void fuse_sync_writes(struct inode *inode)
 	fuse_release_nowrite(inode);
 }
 
-static int fuse_flush(struct file *file, fl_owner_t id)
+static int fuse_flush(struct file *file, void *id)
 {
 	struct inode *inode = file_inode(file);
 	struct fuse_conn *fc = get_fuse_conn(inode);
@@ -643,7 +642,7 @@ static size_t fuse_async_req_send(struct fuse_conn *fc, struct fuse_req *req,
 }
 
 static size_t fuse_send_read(struct fuse_req *req, struct fuse_io_priv *io,
-			     loff_t pos, size_t count, fl_owner_t owner)
+			     loff_t pos, size_t count, void *owner)
 {
 	struct file *file = io->file;
 	struct fuse_file *ff = file->private_data;
@@ -955,7 +954,7 @@ static void fuse_write_fill(struct fuse_req *req, struct fuse_file *ff,
 }
 
 static size_t fuse_send_write(struct fuse_req *req, struct fuse_io_priv *io,
-			      loff_t pos, size_t count, fl_owner_t owner)
+			      loff_t pos, size_t count, void *owner)
 {
 	struct file *file = io->file;
 	struct fuse_file *ff = file->private_data;
@@ -1348,7 +1347,7 @@ ssize_t fuse_direct_io(struct fuse_io_priv *io, struct iov_iter *iter,
 
 	while (count) {
 		size_t nres;
-		fl_owner_t owner = current->files;
+		void *owner = current->files;
 		size_t nbytes = min(count, nmax);
 		err = fuse_get_user_pages(req, iter, &nbytes, write);
 		if (err && !nbytes)
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index 1bd7ffdad593..5f28f493b40a 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -900,7 +900,7 @@ int fuse_valid_type(int m);
  */
 int fuse_allow_current_process(struct fuse_conn *fc);
 
-u64 fuse_lock_owner_id(struct fuse_conn *fc, fl_owner_t id);
+u64 fuse_lock_owner_id(struct fuse_conn *fc, void *id);
 
 void fuse_update_ctime(struct inode *inode);
 
diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 066ac313ae5c..1734c05f3182 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -81,7 +81,7 @@ static inline uint32_t __nlm_alloc_pid(struct nlm_host *host)
 	return res;
 }
 
-static struct nlm_lockowner *__nlm_find_lockowner(struct nlm_host *host, fl_owner_t owner)
+static struct nlm_lockowner *__nlm_find_lockowner(struct nlm_host *host, void *owner)
 {
 	struct nlm_lockowner *lockowner;
 	list_for_each_entry(lockowner, &host->h_lockowners, list) {
@@ -92,7 +92,7 @@ static struct nlm_lockowner *__nlm_find_lockowner(struct nlm_host *host, fl_owne
 	return NULL;
 }
 
-static struct nlm_lockowner *nlm_find_lockowner(struct nlm_host *host, fl_owner_t owner)
+static struct nlm_lockowner *nlm_find_lockowner(struct nlm_host *host, void *owner)
 {
 	struct nlm_lockowner *res, *new = NULL;
 
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 82925f17ec45..2d72631ea968 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -45,7 +45,7 @@ nlm4svc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 		/* Set up the missing parts of the file_lock structure */
 		lock->fl.fl_file  = file->f_file;
-		lock->fl.fl_owner = (fl_owner_t) host;
+		lock->fl.fl_owner = host;
 		lock->fl.fl_lmops = &nlmsvc_lock_operations;
 	}
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 07915162581d..655a8daee20e 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -75,7 +75,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 		/* Set up the missing parts of the file_lock structure */
 		lock->fl.fl_file  = file->f_file;
-		lock->fl.fl_owner = (fl_owner_t) host;
+		lock->fl.fl_owner = host;
 		lock->fl.fl_lmops = &nlmsvc_lock_operations;
 	}
 
diff --git a/fs/locks.c b/fs/locks.c
index a3de5b96c81c..9a3c476f163a 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2429,7 +2429,7 @@ int fcntl_setlk64(unsigned int fd, struct file *filp, unsigned int cmd,
  * from the task's fd array.  POSIX locks belonging to this task
  * are deleted at this time.
  */
-void locks_remove_posix(struct file *filp, fl_owner_t owner)
+void locks_remove_posix(struct file *filp, void *owner)
 {
 	int error;
 	struct inode *inode = locks_inode(filp);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index af330c31f627..bca440fc09ff 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -136,7 +136,7 @@ EXPORT_SYMBOL_GPL(nfs_file_llseek);
  * Flush all dirty pages, and check for write errors.
  */
 static int
-nfs_file_flush(struct file *file, fl_owner_t id)
+nfs_file_flush(struct file *file, void *id)
 {
 	struct inode	*inode = file_inode(file);
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 109279d6d91b..bb2cc33c3753 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -901,7 +901,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
 	ctx->mode = f_mode;
 	ctx->flags = 0;
 	ctx->error = 0;
-	ctx->flock_owner = (fl_owner_t)filp;
+	ctx->flock_owner = filp;
 	nfs_init_lock_context(&ctx->lock_context);
 	ctx->lock_context.open_context = ctx;
 	INIT_LIST_HEAD(&ctx->list);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 40bd05f05e74..0fbe16684519 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -145,7 +145,7 @@ struct nfs4_lock_state {
 	struct nfs_seqid_counter	ls_seqid;
 	nfs4_stateid		ls_stateid;
 	atomic_t		ls_count;
-	fl_owner_t		ls_owner;
+	void *			ls_owner;
 };
 
 /* bits for nfs4_state->flags */
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 0efba77789b9..1e09d9e4dd20 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -107,7 +107,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
  * Flush all dirty pages, and check for write errors.
  */
 static int
-nfs4_file_flush(struct file *file, fl_owner_t id)
+nfs4_file_flush(struct file *file, void *id)
 {
 	struct inode	*inode = file_inode(file);
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 0378e2257ca7..f04a501a6ae9 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -813,7 +813,7 @@ void nfs4_close_sync(struct nfs4_state *state, fmode_t fmode)
  */
 static struct nfs4_lock_state *
 __nfs4_find_lock_state(struct nfs4_state *state,
-		       fl_owner_t fl_owner, fl_owner_t fl_owner2)
+		       void *fl_owner, void *fl_owner2)
 {
 	struct nfs4_lock_state *pos, *ret = NULL;
 	list_for_each_entry(pos, &state->lock_states, ls_locks) {
@@ -834,7 +834,7 @@ __nfs4_find_lock_state(struct nfs4_state *state,
  * exists, return an uninitialized one.
  *
  */
-static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
+static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, void *fl_owner)
 {
 	struct nfs4_lock_state *lsp;
 	struct nfs_server *server = state->owner->so_server;
@@ -868,7 +868,7 @@ void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp
  * exists, return an uninitialized one.
  *
  */
-static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_owner_t owner)
+static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, void *owner)
 {
 	struct nfs4_lock_state *lsp, *new = NULL;
 	
@@ -959,7 +959,7 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 		const struct nfs_lock_context *l_ctx)
 {
 	struct nfs4_lock_state *lsp;
-	fl_owner_t fl_owner, fl_flock_owner;
+	void *fl_owner, fl_flock_owner;
 	int ret = -ENOENT;
 
 	if (l_ctx == NULL)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b50a7492f47f..b0126767b5b5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1195,7 +1195,7 @@ static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
 
 	file = find_any_file(stp->st_stid.sc_file);
 	if (file)
-		filp_close(file, (fl_owner_t)lo);
+		filp_close(file, lo);
 	nfs4_free_ol_stateid(stid);
 }
 
@@ -4183,7 +4183,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
 	fl->fl_flags = FL_DELEG;
 	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
 	fl->fl_end = OFFSET_MAX;
-	fl->fl_owner = (fl_owner_t)fp;
+	fl->fl_owner = fp;
 	fl->fl_pid = current->tgid;
 	return fl;
 }
@@ -5446,8 +5446,8 @@ nfs4_transform_lock_offset(struct file_lock *lock)
 		lock->fl_end = OFFSET_MAX;
 }
 
-static fl_owner_t
-nfsd4_fl_get_owner(fl_owner_t owner)
+static void *
+nfsd4_fl_get_owner(void *owner)
 {
 	struct nfs4_lockowner *lo = (struct nfs4_lockowner *)owner;
 
@@ -5456,7 +5456,7 @@ nfsd4_fl_get_owner(fl_owner_t owner)
 }
 
 static void
-nfsd4_fl_put_owner(fl_owner_t owner)
+nfsd4_fl_put_owner(void *owner)
 {
 	struct nfs4_lockowner *lo = (struct nfs4_lockowner *)owner;
 
@@ -5886,7 +5886,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	file_lock = &nbl->nbl_lock;
 	file_lock->fl_type = fl_type;
-	file_lock->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(&lock_sop->lo_owner));
+	file_lock->fl_owner = lockowner(nfs4_get_stateowner(&lock_sop->lo_owner));
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = fl_flags;
@@ -6040,7 +6040,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	lo = find_lockowner_str(cstate->clp, &lockt->lt_owner);
 	if (lo)
-		file_lock->fl_owner = (fl_owner_t)lo;
+		file_lock->fl_owner = lo;
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_flags = FL_POSIX;
 
@@ -6102,7 +6102,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 
 	file_lock->fl_type = F_UNLCK;
-	file_lock->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(stp->st_stateowner));
+	file_lock->fl_owner = lockowner(nfs4_get_stateowner(stp->st_stateowner));
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX;
@@ -6161,7 +6161,7 @@ check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner)
 	if (flctx && !list_empty_careful(&flctx->flc_posix)) {
 		spin_lock(&flctx->flc_lock);
 		list_for_each_entry(fl, &flctx->flc_posix, fl_list) {
-			if (fl->fl_owner == (fl_owner_t)lowner) {
+			if (fl->fl_owner == lowner) {
 				status = true;
 				break;
 			}
diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index 2430a0415995..a0c804f75435 100644
--- a/fs/notify/dnotify/dnotify.c
+++ b/fs/notify/dnotify/dnotify.c
@@ -145,7 +145,7 @@ static struct fsnotify_ops dnotify_fsnotify_ops = {
  * dnotify_struct.  If that was the last dnotify_struct also remove the
  * fsnotify_mark.
  */
-void dnotify_flush(struct file *filp, fl_owner_t id)
+void dnotify_flush(struct file *filp, void *id)
 {
 	struct fsnotify_mark *fsn_mark;
 	struct dnotify_mark *dn_mark;
@@ -223,7 +223,7 @@ static __u32 convert_arg(unsigned long arg)
  * that list, or it |= the mask onto an existing dnofiy_struct.
  */
 static int attach_dn(struct dnotify_struct *dn, struct dnotify_mark *dn_mark,
-		     fl_owner_t id, int fd, struct file *filp, __u32 mask)
+		     void *id, int fd, struct file *filp, __u32 mask)
 {
 	struct dnotify_struct *odn;
 
@@ -259,7 +259,7 @@ int fcntl_dirnotify(int fd, struct file *filp, unsigned long arg)
 	struct fsnotify_mark *new_fsn_mark, *fsn_mark;
 	struct dnotify_struct *dn;
 	struct inode *inode;
-	fl_owner_t id = current->files;
+	void *id = current->files;
 	struct file *f;
 	int destroy = 0, error = 0;
 	__u32 mask;
diff --git a/fs/open.c b/fs/open.c
index 946c646b39b0..7e9d537e1d32 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -1119,7 +1119,7 @@ SYSCALL_DEFINE2(creat, const char __user *, pathname, umode_t, mode)
  * "id" is the POSIX thread ID. We use the
  * files pointer for this..
  */
-int filp_close(struct file *filp, fl_owner_t id)
+int filp_close(struct file *filp, void *id)
 {
 	int retval = 0;
 
diff --git a/include/linux/dnotify.h b/include/linux/dnotify.h
index 3290555a52ee..5c6b6004f2ca 100644
--- a/include/linux/dnotify.h
+++ b/include/linux/dnotify.h
@@ -13,7 +13,7 @@ struct dnotify_struct {
 	__u32			dn_mask;
 	int			dn_fd;
 	struct file *		dn_filp;
-	fl_owner_t		dn_owner;
+	void *			dn_owner;
 };
 
 #ifdef __KERNEL__
@@ -29,12 +29,12 @@ struct dnotify_struct {
 			    FS_MOVED_FROM | FS_MOVED_TO)
 
 extern int dir_notify_enable;
-extern void dnotify_flush(struct file *, fl_owner_t);
+extern void dnotify_flush(struct file *, void *);
 extern int fcntl_dirnotify(int, struct file *, unsigned long);
 
 #else
 
-static inline void dnotify_flush(struct file *filp, fl_owner_t id)
+static inline void dnotify_flush(struct file *filp, void *id)
 {
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2261728cc900..d0c19bb27f79 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -933,9 +933,6 @@ static inline struct file *get_file(struct file *f)
  */
 #define FILE_LOCK_DEFERRED 1
 
-/* legacy typedef, should eventually be removed */
-typedef void *fl_owner_t;
-
 struct file_lock;
 
 struct file_lock_operations {
@@ -946,8 +943,8 @@ struct file_lock_operations {
 struct lock_manager_operations {
 	int (*lm_compare_owner)(struct file_lock *, struct file_lock *);
 	unsigned long (*lm_owner_key)(struct file_lock *);
-	fl_owner_t (*lm_get_owner)(fl_owner_t);
-	void (*lm_put_owner)(fl_owner_t);
+	void *(*lm_get_owner)(void *);
+	void (*lm_put_owner)(void *);
 	void (*lm_notify)(struct file_lock *);	/* unblock callback */
 	int (*lm_grant)(struct file_lock *, int);
 	bool (*lm_break)(struct file_lock *);
@@ -996,7 +993,7 @@ struct file_lock {
 	struct list_head fl_list;	/* link into file_lock_context */
 	struct hlist_node fl_link;	/* node in global lists */
 	struct list_head fl_block;	/* circular list of blocked processes */
-	fl_owner_t fl_owner;
+	void *fl_owner;
 	unsigned int fl_flags;
 	unsigned char fl_type;
 	unsigned int fl_pid;
@@ -1073,7 +1070,7 @@ extern void locks_init_lock(struct file_lock *);
 extern struct file_lock * locks_alloc_lock(void);
 extern void locks_copy_lock(struct file_lock *, struct file_lock *);
 extern void locks_copy_conflock(struct file_lock *, struct file_lock *);
-extern void locks_remove_posix(struct file *, fl_owner_t);
+extern void locks_remove_posix(struct file *, void *);
 extern void locks_remove_file(struct file *);
 extern void locks_release_private(struct file_lock *);
 extern void posix_test_lock(struct file *, struct file_lock *);
@@ -1147,7 +1144,7 @@ static inline void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
 	return;
 }
 
-static inline void locks_remove_posix(struct file *filp, fl_owner_t owner)
+static inline void locks_remove_posix(struct file *filp, void *owner)
 {
 	return;
 }
@@ -1682,7 +1679,7 @@ struct file_operations {
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
 	int (*mmap) (struct file *, struct vm_area_struct *);
 	int (*open) (struct inode *, struct file *);
-	int (*flush) (struct file *, fl_owner_t id);
+	int (*flush) (struct file *, void *id);
 	int (*release) (struct inode *, struct file *);
 	int (*fsync) (struct file *, loff_t, loff_t, int datasync);
 	int (*fasync) (int, struct file *, int);
@@ -2412,7 +2409,7 @@ extern struct file *filp_open(const char *, int, umode_t);
 extern struct file *file_open_root(struct dentry *, struct vfsmount *,
 				   const char *, int, umode_t);
 extern struct file * dentry_open(const struct path *, int, const struct cred *);
-extern int filp_close(struct file *, fl_owner_t id);
+extern int filp_close(struct file *, void *id);
 
 extern struct filename *getname_flags(const char __user *, int, int *);
 extern struct filename *getname(const char __user *);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 3eca67728366..c7340e4bcd23 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -117,14 +117,14 @@ static inline struct sockaddr *nlm_srcaddr(const struct nlm_host *host)
 }
 
 /*
- * Map an fl_owner_t into a unique 32-bit "pid"
+ * Map a lock owner into a unique 32-bit "pid"
  */
 struct nlm_lockowner {
 	struct list_head list;
 	atomic_t count;
 
 	struct nlm_host *host;
-	fl_owner_t owner;
+	void *owner;
 	uint32_t pid;
 };
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 5cc91d6381a3..cfd37076fc4b 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -59,14 +59,14 @@ struct nfs_lock_context {
 	atomic_t count;
 	struct list_head list;
 	struct nfs_open_context *open_context;
-	fl_owner_t lockowner;
+	void *lockowner;
 	atomic_t io_count;
 };
 
 struct nfs4_state;
 struct nfs_open_context {
 	struct nfs_lock_context lock_context;
-	fl_owner_t flock_owner;
+	void *flock_owner;
 	struct dentry *dentry;
 	struct rpc_cred *cred;
 	struct nfs4_state *state;
diff --git a/include/trace/events/filelock.h b/include/trace/events/filelock.h
index 63a7680347cb..10a8b5a1b235 100644
--- a/include/trace/events/filelock.h
+++ b/include/trace/events/filelock.h
@@ -68,7 +68,7 @@ DECLARE_EVENT_CLASS(filelock_lock,
 		__field(unsigned long, i_ino)
 		__field(dev_t, s_dev)
 		__field(struct file_lock *, fl_next)
-		__field(fl_owner_t, fl_owner)
+		__field(void *, fl_owner)
 		__field(unsigned int, fl_pid)
 		__field(unsigned int, fl_flags)
 		__field(unsigned char, fl_type)
@@ -122,7 +122,7 @@ DECLARE_EVENT_CLASS(filelock_lease,
 		__field(unsigned long, i_ino)
 		__field(dev_t, s_dev)
 		__field(struct file_lock *, fl_next)
-		__field(fl_owner_t, fl_owner)
+		__field(void *, fl_owner)
 		__field(unsigned int, fl_flags)
 		__field(unsigned char, fl_type)
 		__field(unsigned long, fl_break_time)
@@ -175,7 +175,7 @@ TRACE_EVENT(generic_add_lease,
 		__field(int, dcount)
 		__field(int, icount)
 		__field(dev_t, s_dev)
-		__field(fl_owner_t, fl_owner)
+		__field(void *, fl_owner)
 		__field(unsigned int, fl_flags)
 		__field(unsigned char, fl_type)
 	),
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index eb1391b52c6f..d339f60223b5 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -507,7 +507,7 @@ static ssize_t mqueue_read_file(struct file *filp, char __user *u_data,
 	return ret;
 }
 
-static int mqueue_flush_file(struct file *filp, fl_owner_t id)
+static int mqueue_flush_file(struct file *filp, void *id)
 {
 	struct mqueue_inode_info *info = MQUEUE_I(file_inode(filp));
 
