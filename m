From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] lockd: Update NSM state from SM_MON replies
Date: Fri, 15 May 2009 11:32:54 -0400
Message-ID: <20090515153254.17053.86338.stgit@ingres.1015granger.net>
References: <20090515153111.17053.3822.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39743 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbZEOPdO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 May 2009 11:33:14 -0400
In-Reply-To: <20090515153111.17053.3822.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

And, the kernel appears to treat NSM state as a u32 (see struct
nlm_args and nsm_res).  Make nsm_local_state a u32 as well, to ensure
we don't get bogus comparison results.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntproc.c         |    2 +-
 fs/lockd/mon.c              |   18 ++++++++++++------
 include/linux/lockd/lockd.h |    2 +-
 3 files changed, 14 insertions(+), 8 deletions(-)

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
index 6d5d4a4..3838533 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -53,7 +53,7 @@ static				DEFINE_SPINLOCK(nsm_lock);
 /*
  * Local NSM state
  */
-int	__read_mostly		nsm_local_state;
+u32	__read_mostly		nsm_local_state;
 int	__read_mostly		nsm_use_hostnames;
 
 static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
@@ -184,13 +184,19 @@ int nsm_monitor(const struct nlm_host *host)
 	nsm->sm_mon_name = nsm_use_hostnames ? nsm->sm_name : nsm->sm_addrbuf;
 
 	status = nsm_mon_unmon(nsm, NSMPROC_MON, &res);
-	if (res.status != 0)
+	if (unlikely(res.status != 0))
 		status = -EIO;
-	if (status < 0)
+	if (unlikely(status < 0)) {
 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
-	else
-		nsm->sm_monitored = 1;
-	return status;
+		return status;
+	}
+
+	nsm->sm_monitored = 1;
+	if (unlikely(nsm_local_state != res.state)) {
+		nsm_local_state = res.state;
+		dprintk("lockd: NSM state changed to %d\n", nsm_local_state);
+	}
+	return 0;
 }
 
 /**
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 51855df..c325b18 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -195,7 +195,7 @@ extern struct svc_procedure	nlmsvc_procedures4[];
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
 extern int			nsm_use_hostnames;
-extern int			nsm_local_state;
+extern u32			nsm_local_state;
 
 /*
  * Lockd client functions

