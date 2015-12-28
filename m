Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60235 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250AbbL1Q2I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Dec 2015 11:28:08 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 06/10] lockd: Send the inode to nlmclnt_setlockargs()
Date: Mon, 28 Dec 2015 11:28:02 -0500
Message-Id: <098eb736aee2aeb55e76ff076d648acdbdd6f619.1451319354.git.bcodding@redhat.com>
In-Reply-To: <cover.1451319354.git.bcodding@redhat.com>
References: <cover.1451319354.git.bcodding@redhat.com>
In-Reply-To: <cover.1451319354.git.bcodding@redhat.com>
References: <cover.1451319354.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of using fl_file to reference the inode in nlmclnt_setlockargs() to
set the filehandle, send the inode as an argument.  That way, we can use
nlmclnt_proc without having a valid fl_file, which can happen if we are
releasing locks after a close.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/lockd/clntproc.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 72b65c4..91aa483 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -122,14 +122,15 @@ static struct nlm_lockowner *nlm_find_lockowner(struct nlm_host *host, fl_owner_
 /*
  * Initialize arguments for TEST/LOCK/UNLOCK/CANCEL calls
  */
-static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl)
+static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl,
+		struct inode *inode)
 {
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_lock	*lock = &argp->lock;
 	char *nodename = req->a_host->h_rpcclnt->cl_nodename;
 
 	nlmclnt_next_cookie(&argp->cookie);
-	memcpy(&lock->fh, NFS_FH(file_inode(fl->fl_file)), sizeof(struct nfs_fh));
+	memcpy(&lock->fh, NFS_FH(inode), sizeof(struct nfs_fh));
 	lock->caller  = nodename;
 	lock->oh.data = req->a_owner;
 	lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
@@ -171,7 +172,7 @@ int nlmclnt_proc(struct nfs_open_context *ctx, int cmd, struct file_lock *fl)
 		return -ENOMEM;
 	}
 	/* Set up the argument struct */
-	nlmclnt_setlockargs(call, fl);
+	nlmclnt_setlockargs(call, fl, inode);
 
 	if (IS_SETLK(cmd) || IS_SETLKW(cmd)) {
 		if (fl->fl_type != F_UNLCK) {
@@ -619,7 +620,7 @@ nlmclnt_reclaim(struct nlm_host *host, struct file_lock *fl,
 	req->a_host  = host;
 
 	/* Set up the argument struct */
-	nlmclnt_setlockargs(req, fl);
+	nlmclnt_setlockargs(req, fl, file_inode(fl->fl_file));
 	req->a_args.reclaim = 1;
 
 	status = nlmclnt_call(nfs_file_cred(fl->fl_file), req, NLMPROC_LOCK);
@@ -746,7 +747,7 @@ static int nlmclnt_cancel(struct nlm_host *host, int block, struct file_lock *fl
 		return -ENOMEM;
 	req->a_flags = RPC_TASK_ASYNC;
 
-	nlmclnt_setlockargs(req, fl);
+	nlmclnt_setlockargs(req, fl, file_inode(fl->fl_file));
 	req->a_args.block = block;
 
 	atomic_inc(&req->a_count);
-- 
1.7.1

