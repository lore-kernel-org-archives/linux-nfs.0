From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/6] rpc: eliminate unused variable in auth_gss upcall code
Date: Mon,  9 Jun 2008 16:51:33 -0400
Message-ID: <1213044696-32741-4-git-send-email-bfields@citi.umich.edu>
References: <1213044696-32741-1-git-send-email-bfields@citi.umich.edu>
 <1213044696-32741-2-git-send-email-bfields@citi.umich.edu>
 <1213044696-32741-3-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48632 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751808AbYFIUvi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 16:51:38 -0400
In-Reply-To: <1213044696-32741-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also, a minor comment grammar fix in the same file.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index c3ca6f0..92a820e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -272,7 +272,7 @@ __gss_find_upcall(struct rpc_inode *rpci, uid_t uid)
 	return NULL;
 }
 
-/* Try to add a upcall to the pipefs queue.
+/* Try to add an upcall to the pipefs queue.
  * If an upcall owned by our uid already exists, then we return a reference
  * to that upcall instead of adding the new upcall.
  */
@@ -493,7 +493,6 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 {
 	const void *p, *end;
 	void *buf;
-	struct rpc_clnt *clnt;
 	struct gss_upcall_msg *gss_msg;
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	struct gss_cl_ctx *ctx;
@@ -507,7 +506,6 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	if (!buf)
 		goto out;
 
-	clnt = RPC_I(inode)->private;
 	err = -EFAULT;
 	if (copy_from_user(buf, src, mlen))
 		goto err;
-- 
1.5.5.rc1

