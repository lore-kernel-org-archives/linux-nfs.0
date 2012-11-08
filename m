Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:17796 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600Ab2KHPdA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Nov 2012 10:33:00 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] SUNRPC: Fix validity issues with rpc_pipefs sb->s_fs_info
Date: Thu,  8 Nov 2012 10:32:54 -0500
Message-Id: <1352388774-37495-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc_fill_super must not exit without setting sb->s_fs_info, since it is
used in rpc_kill_sb(), which is called by mount_ns() on failure.

rpc_kill_sb() must defer calling put_net() until after the notifier
has been called, since most (all?) of the notifier callbacks assume
that sb->s_fs_info points to a valid net namespace.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: stable@vger.kernel.org [>= v3.4]
---
 net/sunrpc/rpc_pipe.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 21fde99..253af66 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1112,6 +1112,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_magic = RPCAUTH_GSSMAGIC;
 	sb->s_op = &s_ops;
 	sb->s_time_gran = 1;
+	sb->s_fs_info = get_net(net);
 
 	inode = rpc_get_inode(sb, S_IFDIR | S_IRUGO | S_IXUGO);
 	sb->s_root = root = d_make_root(inode);
@@ -1127,7 +1128,6 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 					   sb);
 	if (err)
 		goto err_depopulate;
-	sb->s_fs_info = get_net(net);
 	return 0;
 
 err_depopulate:
@@ -1154,13 +1154,13 @@ static void rpc_kill_sb(struct super_block *sb)
 	mutex_lock(&sn->pipefs_sb_lock);
 	sn->pipefs_sb = NULL;
 	mutex_unlock(&sn->pipefs_sb_lock);
-	put_net(net);
 	dprintk("RPC:	sending pipefs UMOUNT notification for net %p%s\n", net,
 								NET_NAME(net));
 	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_UMOUNT,
 					   sb);
 	kill_litter_super(sb);
+	put_net(net);
 }
 
 static struct file_system_type rpc_pipe_fs_type = {
-- 
1.7.11.7

