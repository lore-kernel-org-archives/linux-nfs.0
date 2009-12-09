From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH] rpc: remove unneeded function parameter in gss_add_msg()
Date: Wed,  9 Dec 2009 23:15:22 +0530
Message-ID: <1260380722-7599-1-git-send-email-sjayaraman@suse.de>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Suresh Jayaraman <sjayaraman@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The pointer to struct gss_auth parameter in gss_add_msg is not really needed
after commit 5b7ddd4a. Zap it.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 net/sunrpc/auth_gss/auth_gss.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index fc6a43c..85ee2ca 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -304,7 +304,7 @@ __gss_find_upcall(struct rpc_inode *rpci, uid_t uid)
  * to that upcall instead of adding the new upcall.
  */
 static inline struct gss_upcall_msg *
-gss_add_msg(struct gss_auth *gss_auth, struct gss_upcall_msg *gss_msg)
+gss_add_msg(struct gss_upcall_msg *gss_msg)
 {
 	struct rpc_inode *rpci = gss_msg->inode;
 	struct inode *inode = &rpci->vfs_inode;
@@ -445,7 +445,7 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
 	gss_new = gss_alloc_msg(gss_auth, uid, clnt, gss_cred->gc_machine_cred);
 	if (IS_ERR(gss_new))
 		return gss_new;
-	gss_msg = gss_add_msg(gss_auth, gss_new);
+	gss_msg = gss_add_msg(gss_new);
 	if (gss_msg == gss_new) {
 		struct inode *inode = &gss_new->inode->vfs_inode;
 		int res = rpc_queue_upcall(inode, &gss_new->msg);
-- 
1.6.4.2

