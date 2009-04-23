From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/19] lockd: Update NSM state from SM_MON replies
Date: Thu, 23 Apr 2009 19:33:33 -0400
Message-ID: <20090423233332.17283.23011.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26871 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755347AbZDWXeb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:34:31 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When rpc.statd starts up in user space at boot time, it attempts to
write the latest NSM local state number into
/proc/sys/fs/nfs/nsm_local_state.

If lockd.ko isn't loaded yet (as is the case in most configurations),
that file doesn't exist, thus the kernel's NSM state remains set to
its initial value of zero during lockd operation.

This is a problem because rpc.statd and lockd use the NSM state number
to prevent repeated lock recovery on rebooted hosts.  If lockd sends
a zero NSM state, but then a delayed SM_NOTIFY with a real NSM state
number is received, there is no way for lockd or rpc.statd to
distinguish that stale SM_NOTIFY from an actual reboot.  Thus lock
recovery could be performed after the rebooted host has already
started reclaiming locks, and those locks will be lost.

We could change /etc/init.d/nfslock so it always modprobes lockd.ko
before starting rpc.statd.  However, if lockd.ko is ever unloaded
and reloaded, we are back at square one, since the NSM state is not
preserved across an unload/reload cycle.  This may happen frequently
on clients that use automounter.  A period of NFS inactivity causes
lockd.ko to be unloaded, and the kernel loses its NSM state setting.

Instead, let's use the fact that rpc.statd plants the local system's
NSM state in every SM_MON (and SM_UNMON) reply.  lockd performs a
synchronous SM_MON upcall to the local rpc.statd _before_ sending its
first NLM request to a new remote.  This would permit rpc.statd to
provide the current NSM state to lockd, even after lockd.ko had been
unloaded and reloaded.

Note that NLMPROC_LOCK arguments are constructed before the
nsm_monitor() call, so we have to rearrange argument construction very
slightly to make this all work out.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntproc.c |    2 +-
 fs/lockd/mon.c      |    6 +++++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index dd79570..f55b900 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -126,7 +126,6 @@ static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl)
 	struct nlm_lock	*lock = &argp->lock;
 
 	nlmclnt_next_cookie(&argp->cookie);
-	argp->state   = nsm_local_state;
 	memcpy(&lock->fh, NFS_FH(fl->fl_file->f_path.dentry->d_inode), sizeof(struct nfs_fh));
 	lock->caller  = utsname()->nodename;
 	lock->oh.data = req->a_owner;
@@ -519,6 +518,7 @@ nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 
 	if (nsm_monitor(host) < 0)
 		goto out;
+	req->a_args.state = nsm_local_state;
 
 	fl->fl_flags |= FL_ACCESS;
 	status = do_vfs_lock(fl);
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 6d5d4a4..5017d50 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -188,8 +188,12 @@ int nsm_monitor(const struct nlm_host *host)
 		status = -EIO;
 	if (status < 0)
 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
-	else
+	else {
 		nsm->sm_monitored = 1;
+		nsm_local_state = res.state;
+		dprintk("lockd: nsm_monitor: NSM state is now %d\n",
+				nsm_local_state);
+	}
 	return status;
 }
 

