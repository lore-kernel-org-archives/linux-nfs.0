Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:42133 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755339Ab2JWOx6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:58 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 01/25] SUNRPC: remove BUG_ON in __rpc_clnt_handle_event
Date: Tue, 23 Oct 2012 10:43:25 -0400
Message-Id: <1351003429-18887-2-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Print a KERN_INFO message before rpc_d_lookup_sb returns NULL, like
other error paths in that function.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index cdc7564..abb7f5e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -132,8 +132,10 @@ static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
 	int error;
 
 	dir = rpc_d_lookup_sb(sb, dir_name);
-	if (dir == NULL)
+	if (dir == NULL) {
+		pr_info("RPC: pipefs directory doesn't exist: %s\n", dir_name);
 		return dir;
+	}
 	for (;;) {
 		q.len = snprintf(name, sizeof(name), "clnt%x", (unsigned int)clntid++);
 		name[sizeof(name) - 1] = '\0';
@@ -192,7 +194,8 @@ static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
 	case RPC_PIPEFS_MOUNT:
 		dentry = rpc_setup_pipedir_sb(sb, clnt,
 					      clnt->cl_program->pipe_dir_name);
-		BUG_ON(dentry == NULL);
+		if (!dentry)
+			return -ENOENT;
 		if (IS_ERR(dentry))
 			return PTR_ERR(dentry);
 		clnt->cl_dentry = dentry;
-- 
1.7.9.6 (Apple Git-31.1)

