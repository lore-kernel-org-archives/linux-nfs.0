From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] lockd: change nlmclnt_grant() to take a "struct sockaddr
	*"
Date: Fri, 03 Oct 2008 12:50:36 -0400
Message-ID: <20081003165036.10198.22807.stgit@ingres.1015granger.net>
References: <20081003162856.10198.20451.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:40634 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbYJCQwG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 12:52:06 -0400
In-Reply-To: <20081003162856.10198.20451.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index 4a714f6..89eb6f9 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -231,7 +231,7 @@ nlm4svc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	dprintk("lockd: GRANTED       called\n");
-	resp->status = nlmclnt_grant(svc_addr_in(rqstp), &argp->lock);
+	resp->status = nlmclnt_grant(svc_addr(rqstp), &argp->lock);
 	dprintk("lockd: GRANTED       status %d\n", ntohl(resp->status));
 	return rpc_success;
 }
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 76262c1..361aac2 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -261,7 +261,7 @@ nlmsvc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	dprintk("lockd: GRANTED       called\n");
-	resp->status = nlmclnt_grant(svc_addr_in(rqstp), &argp->lock);
+	resp->status = nlmclnt_grant(svc_addr(rqstp), &argp->lock);
 	dprintk("lockd: GRANTED       status %d\n", ntohl(resp->status));
 	return rpc_success;
 }
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 2e13c0b..165ef7a 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -207,7 +207,8 @@ int		  nlm_async_reply(struct nlm_rqst *, u32, const struct rpc_call_ops *);
 struct nlm_wait * nlmclnt_prepare_block(struct nlm_host *host, struct file_lock *fl);
 void		  nlmclnt_finish_block(struct nlm_wait *block);
 int		  nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long timeout);
-__be32		  nlmclnt_grant(const struct sockaddr_in *addr, const struct nlm_lock *);
+__be32		  nlmclnt_grant(const struct sockaddr *addr,
+				const struct nlm_lock *lock);
 void		  nlmclnt_recovery(struct nlm_host *);
 int		  nlmclnt_reclaim(struct nlm_host *, struct file_lock *);
 void		  nlmclnt_next_cookie(struct nlm_cookie *);

