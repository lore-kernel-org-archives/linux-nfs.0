From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/8] NLM/lockd: Ensure we don't corrupt fl->fl_flags in
	nlmclnt_unlock()
Date: Thu, 03 Apr 2008 18:39:21 -0400
Message-ID: <20080403223921.12713.20317.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080403223921.12713.71396.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8113 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751900AbYDCW57 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2008 18:57:59 -0400
In-Reply-To: <20080403223921.12713.71396.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also fix up nlmclnt_lock() so that it doesn't pass modified versions of
fl->fl_flags to nlmclnt_cancel() and other helpers.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index b6b74a6..4e1c012 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -493,6 +493,7 @@ nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 	}
 	fl->fl_flags |= FL_ACCESS;
 	status = do_vfs_lock(fl);
+	fl->fl_flags = fl_flags;
 	if (status < 0)
 		goto out;
 
@@ -530,10 +531,11 @@ again:
 			goto again;
 		}
 		/* Ensure the resulting lock will get added to granted list */
-		fl->fl_flags = fl_flags | FL_SLEEP;
+		fl->fl_flags |= FL_SLEEP;
 		if (do_vfs_lock(fl) < 0)
 			printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __FUNCTION__);
 		up_read(&host->h_rwsem);
+		fl->fl_flags = fl_flags;
 	}
 	status = nlm_stat_to_errno(resp->status);
 out_unblock:
@@ -543,7 +545,6 @@ out_unblock:
 		nlmclnt_cancel(host, req->a_args.block, fl);
 out:
 	nlm_release_call(req);
-	fl->fl_flags = fl_flags;
 	return status;
 }
 
@@ -598,7 +599,8 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 {
 	struct nlm_host	*host = req->a_host;
 	struct nlm_res	*resp = &req->a_res;
-	int status = 0;
+	int status;
+	unsigned char fl_flags = fl->fl_flags;
 
 	/*
 	 * Note: the server is supposed to either grant us the unlock
@@ -607,11 +609,13 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 	 */
 	fl->fl_flags |= FL_EXISTS;
 	down_read(&host->h_rwsem);
-	if (do_vfs_lock(fl) == -ENOENT) {
-		up_read(&host->h_rwsem);
+	status = do_vfs_lock(fl);
+	up_read(&host->h_rwsem);
+	fl->fl_flags = fl_flags;
+	if (status == -ENOENT) {
+		status = 0;
 		goto out;
 	}
-	up_read(&host->h_rwsem);
 
 	if (req->a_flags & RPC_TASK_ASYNC)
 		return nlm_async_call(req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);

