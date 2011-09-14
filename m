Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:50483 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932918Ab1INTuq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Sep 2011 15:50:46 -0400
Received: by gyg10 with SMTP id 10so1699431gyg.19
        for <linux-nfs@vger.kernel.org>; Wed, 14 Sep 2011 12:50:45 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] lockd: Use my_name instead of utsname when constructing
	NLM_LOCK args
To: skinsbursky@parallels.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 14 Sep 2011 15:50:44 -0400
Message-ID: <20110914195043.3008.548.stgit@matisse.1015granger.net>
In-Reply-To: <20110914194646.3008.77560.stgit@matisse.1015granger.net>
References: <20110914194646.3008.77560.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The caller_name value can now be set in nlmclnt_lookup_host().  The
lockd client code should use that value instead of utsname()->nodename
everywhere.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntproc.c |    6 +++---
 fs/lockd/svclock.c  |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 8392cb8..01db71c 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -12,7 +12,6 @@
 #include <linux/errno.h>
 #include <linux/fs.h>
 #include <linux/nfs_fs.h>
-#include <linux/utsname.h>
 #include <linux/freezer.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
@@ -123,16 +122,17 @@ static struct nlm_lockowner *nlm_find_lockowner(struct nlm_host *host, fl_owner_
  */
 static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl)
 {
+	char *my_name = req->a_host->h_nsmhandle->sm_my_name;
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_lock	*lock = &argp->lock;
 
 	nlmclnt_next_cookie(&argp->cookie);
 	memcpy(&lock->fh, NFS_FH(fl->fl_file->f_path.dentry->d_inode), sizeof(struct nfs_fh));
-	lock->caller  = utsname()->nodename;
+	lock->caller  = my_name;
 	lock->oh.data = req->a_owner;
 	lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
 				(unsigned int)fl->fl_u.nfs_fl.owner->pid,
-				utsname()->nodename);
+				my_name);
 	lock->svid = fl->fl_u.nfs_fl.owner->pid;
 	lock->fl.fl_start = fl->fl_start;
 	lock->fl.fl_end = fl->fl_end;
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index f0179c3..36cadab 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -315,7 +315,7 @@ static int nlmsvc_setgrantargs(struct nlm_rqst *call, struct nlm_lock *lock)
 {
 	locks_copy_lock(&call->a_args.lock.fl, &lock->fl);
 	memcpy(&call->a_args.lock.fh, &lock->fh, sizeof(call->a_args.lock.fh));
-	call->a_args.lock.caller = utsname()->nodename;
+	call->a_args.lock.caller = call->a_host->h_nsmhandle->sm_my_name;
 	call->a_args.lock.oh.len = lock->oh.len;
 
 	/* set default data area */

