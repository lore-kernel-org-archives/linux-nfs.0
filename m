Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:48901 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758908AbaLLCwz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2014 21:52:55 -0500
Date: Fri, 12 Dec 2014 02:52:50 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Layton <jlayton@primarydata.com>, bfields@fieldses.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH v2 00/16] nfsd/sunrpc: add support for a workqueue-based
 nfsd
Message-ID: <20141212025250.GZ22149@ZenIV.linux.org.uk>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
 <20141212021241.GA5944@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141212021241.GA5944@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 12, 2014 at 02:12:41AM +0000, Al Viro wrote:
> On Wed, Dec 10, 2014 at 02:07:44PM -0500, Jeff Layton wrote:
> 
> > We'll also need Al's ACK on the fs_struct stuff.
> 
> ... and I'm not happy with it.  First of all, ditch those EXPORT_SYMBOL_GPL();
> if it's too low-level for general export (and many of those are), tacking
> _GPL on it doesn't make it any better.  unshare_fs_struct() misbegotten export
> is a historical accident - somebody (agruen, perhaps?) slapped a _GPL export
> on its precursors and I had taken a lazy approach back then.  Shouldn't have
> done that...  Please, don't add more of that shit.
> 
> More to the point, though, it *is* far too low-level, and for no visible
> reason.  AFAICS, what you want to achieve is zero umask in that fucker.
> TBH, I really wonder if any of that is needed at all.  Why do we want kernel
> threads to get umask shared with init(8), anyway?  It's very easy to change -
> all it takes is
> 	* make init_fs.umask zero
> 	* make kernel_init cloned without CLONE_FS and have it immediately
> set its ->fs->umask to 0022
> 	* make ____call_usermodehelper() (always called very early in the
> life of a thread that had been cloned without CLONE_FS) do the same thing.
> Voila - all kernel threads have umask 0 and it's not affected by whatever
> init(8) might be pulling off.  And that includes all worqueue workers, etc.
> 
> With that I'm not sure we need to have unshare_fs_struct() at all; at least
> not unless some thread wants to play with chdir() and chroot() and
> I don't see anything of that sort in nfsd and lustre (the only callers of
> unshare_fs_struct() in the tree).  Note that set_fs_pwd() and set_fs_root()
> are *not* exported, and neither are sys_{chdir,fchdir,chroot}, so nfsd and
> lustre would have a hard time trying to do something of that sort anyway.
> There is open-coded crap trying to implement chdir in lustre_compat25.h, but
> it has no callers...
> 
> Linus, do you see any problems with the following patch (against the mainline)?
> If not, I'll put it into the next vfs.git pull request, along with removal of
> all mentionings of ->fs-> in lustre (aside of aforementioned dead code,
> there's open-coded current_umask() in one place and broken attempt to
> reimplement dentry_path() in another).

Grr...  With includes of <linux/fs_struct.h> added in init/main.c and
kernel/kmod.c.  Sorry.  That way it builds and, AFAICT, works...  I think
it ought to be 3 commits -
	* giving PID 1 fs_struct of its own, making umask for all kernel
threads zero, while keeping the same value (0022) for PID 1 and all userland
processes spawned by call_usermodehelper().
	* removal of unshare_fs_struct() - it becomes unneeded after the
previous commit
	* removal of assorted junk in lustre.

All three combined yield this:

 .../staging/lustre/include/linux/libcfs/libcfs.h   |  1 -
 .../lustre/lustre/include/linux/lustre_compat25.h  | 24 ---------------------
 drivers/staging/lustre/lustre/llite/dir.c          |  2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 17 +--------------
 drivers/staging/lustre/lustre/obdclass/genops.c    |  1 -
 drivers/staging/lustre/lustre/obdclass/llog.c      |  2 --
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  2 --
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |  2 --
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  1 -
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |  2 --
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  2 --
 fs/fs_struct.c                                     | 25 +---------------------
 fs/nfsd/nfssvc.c                                   | 11 ----------
 include/linux/fs_struct.h                          |  1 -
 init/main.c                                        |  4 +++-
 kernel/kmod.c                                      |  2 ++
 16 files changed, 8 insertions(+), 91 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index a6b2f90..e097489 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -136,7 +136,6 @@ void cfs_enter_debugger(void);
 /*
  * Defined by platform
  */
-int unshare_fs_struct(void);
 sigset_t cfs_get_blocked_sigs(void);
 sigset_t cfs_block_allsigs(void);
 sigset_t cfs_block_sigs(unsigned long sigs);
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h b/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
index e94ab34..f10e061 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
@@ -42,28 +42,6 @@
 
 #include "lustre_patchless_compat.h"
 
-# define LOCK_FS_STRUCT(fs)	spin_lock(&(fs)->lock)
-# define UNLOCK_FS_STRUCT(fs)	spin_unlock(&(fs)->lock)
-
-static inline void ll_set_fs_pwd(struct fs_struct *fs, struct vfsmount *mnt,
-				 struct dentry *dentry)
-{
-	struct path path;
-	struct path old_pwd;
-
-	path.mnt = mnt;
-	path.dentry = dentry;
-	LOCK_FS_STRUCT(fs);
-	old_pwd = fs->pwd;
-	path_get(&path);
-	fs->pwd = path;
-	UNLOCK_FS_STRUCT(fs);
-
-	if (old_pwd.dentry)
-		path_put(&old_pwd);
-}
-
-
 /*
  * set ATTR_BLOCKS to a high value to avoid any risk of collision with other
  * ATTR_* attributes (see bug 13828)
@@ -112,8 +90,6 @@ static inline void ll_set_fs_pwd(struct fs_struct *fs, struct vfsmount *mnt,
 #define cfs_bio_io_error(a, b)   bio_io_error((a))
 #define cfs_bio_endio(a, b, c)    bio_endio((a), (c))
 
-#define cfs_fs_pwd(fs)       ((fs)->pwd.dentry)
-#define cfs_fs_mnt(fs)       ((fs)->pwd.mnt)
 #define cfs_path_put(nd)     path_put(&(nd)->path)
 
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index a79fd65..fa40474 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -661,7 +661,7 @@ int ll_dir_setdirstripe(struct inode *dir, struct lmv_user_md *lump,
 	int mode;
 	int err;
 
-	mode = (0755 & (S_IRWXUGO|S_ISVTX) & ~current->fs->umask) | S_IFDIR;
+	mode = (0755 & ~current_umask()) | S_IFDIR;
 	op_data = ll_prep_md_op_data(NULL, dir, NULL, filename,
 				     strlen(filename), mode, LUSTRE_OPC_MKDIR,
 				     lump);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 7b6b9e2..accba4f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2396,21 +2396,6 @@ char *ll_get_fsname(struct super_block *sb, char *buf, int buflen)
 	return buf;
 }
 
-static char* ll_d_path(struct dentry *dentry, char *buf, int bufsize)
-{
-	char *path = NULL;
-
-	struct path p;
-
-	p.dentry = dentry;
-	p.mnt = current->fs->root.mnt;
-	path_get(&p);
-	path = d_path(&p, buf, bufsize);
-	path_put(&p);
-
-	return path;
-}
-
 void ll_dirty_page_discard_warn(struct page *page, int ioret)
 {
 	char *buf, *path = NULL;
@@ -2422,7 +2407,7 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 	if (buf != NULL) {
 		dentry = d_find_alias(page->mapping->host);
 		if (dentry != NULL)
-			path = ll_d_path(dentry, buf, PAGE_SIZE);
+			path = dentry_path_raw(dentry, buf, PAGE_SIZE);
 	}
 
 	CDEBUG(D_WARNING,
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index c314e9c..53876f9 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -1713,7 +1713,6 @@ EXPORT_SYMBOL(obd_zombie_barrier);
  */
 static int obd_zombie_impexp_thread(void *unused)
 {
-	unshare_fs_struct();
 	complete(&obd_zombie_start);
 
 	obd_zombie_pid = current_pid();
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 3ab0529..6130b23 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -411,8 +411,6 @@ static int llog_process_thread_daemonize(void *arg)
 	struct lu_env			 env;
 	int				 rc;
 
-	unshare_fs_struct();
-
 	/* client env has no keys, tags is just 0 */
 	rc = lu_env_init(&env, LCT_LOCAL | LCT_MG_THREAD);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 2e7e717..d395e06 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1290,8 +1290,6 @@ static int ptlrpc_invalidate_import_thread(void *data)
 {
 	struct obd_import *imp = data;
 
-	unshare_fs_struct();
-
 	CDEBUG(D_HA, "thread invalidate import %s to %s@%s\n",
 	       imp->imp_obd->obd_name, obd2cli_tgt(imp->imp_obd),
 	       imp->imp_connection->c_remote_uuid.uuid);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 20341b2..9f426ea 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -586,8 +586,6 @@ static int ping_evictor_main(void *arg)
 	struct l_wait_info lwi = { 0 };
 	time_t expire_time;
 
-	unshare_fs_struct();
-
 	CDEBUG(D_HA, "Starting Ping Evictor\n");
 	pet_state = PET_READY;
 	while (1) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 357ea9f..a2a1574 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -382,7 +382,6 @@ static int ptlrpcd(void *arg)
 	struct lu_env env = { .le_ses = NULL };
 	int rc, exit = 0;
 
-	unshare_fs_struct();
 #if defined(CONFIG_SMP)
 	if (test_bit(LIOD_BIND, &pc->pc_flags)) {
 		int index = pc->pc_index;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index c500aff..9e33781 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -164,8 +164,6 @@ static int sec_gc_main(void *arg)
 	struct ptlrpc_thread *thread = (struct ptlrpc_thread *) arg;
 	struct l_wait_info    lwi;
 
-	unshare_fs_struct();
-
 	/* Record that the thread is running */
 	thread_set_flags(thread, SVC_RUNNING);
 	wake_up(&thread->t_ctl_waitq);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index a8df8a7..149c65c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -2277,7 +2277,6 @@ static int ptlrpc_main(void *arg)
 	int counter = 0, rc = 0;
 
 	thread->t_pid = current_pid();
-	unshare_fs_struct();
 
 	/* NB: we will call cfs_cpt_bind() for all threads, because we
 	 * might want to run lustre server only on a subset of system CPUs,
@@ -2478,7 +2477,6 @@ static int ptlrpc_hr_main(void *arg)
 
 	snprintf(threadname, sizeof(threadname), "ptlrpc_hr%02d_%03d",
 		 hrp->hrp_cpt, hrt->hrt_id);
-	unshare_fs_struct();
 
 	rc = cfs_cpt_bind(ptlrpc_hr.hr_cpt_table, hrp->hrp_cpt);
 	if (rc != 0) {
diff --git a/fs/fs_struct.c b/fs/fs_struct.c
index 7dca743..401fd2e 100644
--- a/fs/fs_struct.c
+++ b/fs/fs_struct.c
@@ -128,29 +128,6 @@ struct fs_struct *copy_fs_struct(struct fs_struct *old)
 	return fs;
 }
 
-int unshare_fs_struct(void)
-{
-	struct fs_struct *fs = current->fs;
-	struct fs_struct *new_fs = copy_fs_struct(fs);
-	int kill;
-
-	if (!new_fs)
-		return -ENOMEM;
-
-	task_lock(current);
-	spin_lock(&fs->lock);
-	kill = !--fs->users;
-	current->fs = new_fs;
-	spin_unlock(&fs->lock);
-	task_unlock(current);
-
-	if (kill)
-		free_fs_struct(fs);
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(unshare_fs_struct);
-
 int current_umask(void)
 {
 	return current->fs->umask;
@@ -162,5 +139,5 @@ struct fs_struct init_fs = {
 	.users		= 1,
 	.lock		= __SPIN_LOCK_UNLOCKED(init_fs.lock),
 	.seq		= SEQCNT_ZERO(init_fs.seq),
-	.umask		= 0022,
+	.umask		= 0,
 };
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 752d56b..357a73b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -573,16 +573,6 @@ nfsd(void *vrqstp)
 	/* Lock module and set up kernel thread */
 	mutex_lock(&nfsd_mutex);
 
-	/* At this point, the thread shares current->fs
-	 * with the init process. We need to create files with a
-	 * umask of 0 instead of init's umask. */
-	if (unshare_fs_struct() < 0) {
-		printk("Unable to start nfsd thread: out of memory\n");
-		goto out;
-	}
-
-	current->fs->umask = 0;
-
 	/*
 	 * thread is spawned with all signals set to SIG_IGN, re-enable
 	 * the ones that will bring down the thread
@@ -623,7 +613,6 @@ nfsd(void *vrqstp)
 	mutex_lock(&nfsd_mutex);
 	nfsdstats.th_cnt --;
 
-out:
 	rqstp->rq_server = NULL;
 
 	/* Release the thread */
diff --git a/include/linux/fs_struct.h b/include/linux/fs_struct.h
index 0efc3e6..18d369c 100644
--- a/include/linux/fs_struct.h
+++ b/include/linux/fs_struct.h
@@ -21,7 +21,6 @@ extern void set_fs_root(struct fs_struct *, const struct path *);
 extern void set_fs_pwd(struct fs_struct *, const struct path *);
 extern struct fs_struct *copy_fs_struct(struct fs_struct *);
 extern void free_fs_struct(struct fs_struct *);
-extern int unshare_fs_struct(void);
 
 static inline void get_fs_root(struct fs_struct *fs, struct path *root)
 {
diff --git a/init/main.c b/init/main.c
index ca380ec..53aea3b 100644
--- a/init/main.c
+++ b/init/main.c
@@ -77,6 +77,7 @@
 #include <linux/context_tracking.h>
 #include <linux/random.h>
 #include <linux/list.h>
+#include <linux/fs_struct.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -399,7 +400,7 @@ static noinline void __init_refok rest_init(void)
 	 * the init task will end up wanting to create kthreads, which, if
 	 * we schedule it before we create kthreadd, will OOPS.
 	 */
-	kernel_thread(kernel_init, NULL, CLONE_FS);
+	kernel_thread(kernel_init, NULL, 0);
 	numa_default_policy();
 	pid = kernel_thread(kthreadd, NULL, CLONE_FS | CLONE_FILES);
 	rcu_read_lock();
@@ -924,6 +925,7 @@ static int __ref kernel_init(void *unused)
 {
 	int ret;
 
+	current->fs->umask = 0022;
 	kernel_init_freeable();
 	/* need to finish all async __init code before freeing the memory */
 	async_synchronize_full();
diff --git a/kernel/kmod.c b/kernel/kmod.c
index 2777f40..4d775e7 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -39,6 +39,7 @@
 #include <linux/rwsem.h>
 #include <linux/ptrace.h>
 #include <linux/async.h>
+#include <linux/fs_struct.h>
 #include <asm/uaccess.h>
 
 #include <trace/events/module.h>
@@ -219,6 +220,7 @@ static int ____call_usermodehelper(void *data)
 	struct cred *new;
 	int retval;
 
+	current->fs->umask = 0022;
 	spin_lock_irq(&current->sighand->siglock);
 	flush_signal_handlers(current, 1);
 	spin_unlock_irq(&current->sighand->siglock);
