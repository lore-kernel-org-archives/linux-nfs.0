From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 26/37] rpc: eliminate unused variable in auth_gss upcall
	code
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.71758.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14765 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759492AbYFLTex (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:53 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: \"J. Bruce Fields\" <bfields@citi.umich.edu>

Also, a minor comment grammar fix in the same file.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index bf7585b..ebfd630 100644
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

