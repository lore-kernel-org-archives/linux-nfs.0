From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/16] lockd: change nlmclnt_grant() to take a "struct
	sockaddr *"
Date: Mon, 30 Jun 2008 19:00:14 -0400
Message-ID: <20080630230013.25407.64641.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:17405 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763272AbYF3XEv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:04:51 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adjust the signature and callers of nlmclnt_grant() to pass a "struct
sockaddr *" instead of a "struct sockaddr_in *" in order to support IPv6
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntlock.c         |    5 ++---
 fs/lockd/svc4proc.c         |    2 +-
 fs/lockd/svcproc.c          |    2 +-
 include/linux/lockd/lockd.h |    3 ++-
 4 files changed, 6 insertions(+), 6 deletions(-)


diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 9eaf306..2976bf0 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -141,7 +141,7 @@ int nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long timeout)
 /*
  * The server lockd has called us back to tell us the lock was granted
  */
-__be32 nlmclnt_grant(const struct sockaddr_in *addr, const struct nlm_lock *lock)
+__be32 nlmclnt_grant(const struct sockaddr *addr, const struct nlm_lock *lock)
 {
 	const struct file_lock *fl = &lock->fl;
 	const struct nfs_fh *fh = &lock->fh;
@@ -165,8 +165,7 @@ __be32 nlmclnt_grant(const struct sockaddr_in *addr, const struct nlm_lock *lock
 		 */
 		if (fl_blocked->fl_u.nfs_fl.owner->pid != lock->svid)
 			continue;
-		if (!nlm_cmp_addr(nlm_addr(block->b_host),
-					(struct sockaddr *)addr))
+		if (!nlm_cmp_addr(nlm_addr(block->b_host), addr))
 			continue;
 		if (nfs_compare_fh(NFS_FH(fl_blocked->fl_file->f_path.dentry->d_inode) ,fh) != 0)
 			continue;
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 385437e..5cc8999 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -232,7 +232,7 @@ nlm4svc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	dprintk("lockd: GRANTED       called\n");
-	resp->status = nlmclnt_grant(svc_addr_in(rqstp), &argp->lock);
+	resp->status = nlmclnt_grant(svc_addr(rqstp), &argp->lock);
 	dprintk("lockd: GRANTED       status %d\n", ntohl(resp->status));
 	return rpc_success;
 }
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 88379cc..c7b5889 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -262,7 +262,7 @@ nlmsvc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	dprintk("lockd: GRANTED       called\n");
-	resp->status = nlmclnt_grant(svc_addr_in(rqstp), &argp->lock);
+	resp->status = nlmclnt_grant(svc_addr(rqstp), &argp->lock);
 	dprintk("lockd: GRANTED       status %d\n", ntohl(resp->status));
 	return rpc_success;
 }
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index e327914..a48d87a 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -206,7 +206,8 @@ int		  nlm_async_reply(struct nlm_rqst *, u32, const struct rpc_call_ops *);
 struct nlm_wait * nlmclnt_prepare_block(struct nlm_host *host, struct file_lock *fl);
 void		  nlmclnt_finish_block(struct nlm_wait *block);
 int		  nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long timeout);
-__be32		  nlmclnt_grant(const struct sockaddr_in *addr, const struct nlm_lock *);
+__be32		  nlmclnt_grant(const struct sockaddr *addr,
+				const struct nlm_lock *lock);
 void		  nlmclnt_recovery(struct nlm_host *);
 int		  nlmclnt_reclaim(struct nlm_host *, struct file_lock *);
 void		  nlmclnt_next_cookie(struct nlm_cookie *);

