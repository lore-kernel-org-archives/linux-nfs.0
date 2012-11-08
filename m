Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59995 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404Ab2KHQvw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Nov 2012 11:51:52 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v2] SUNRPC: Fix validity issues with rpc_pipefs sb->s_fs_info
Date: Thu,  8 Nov 2012 11:51:46 -0500
Message-Id: <1352393506-39590-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc_kill_sb() must defer calling put_net() until after the notifier
has been called, since most (all?) of the notifier callbacks assume
that sb->s_fs_info points to a valid net namespace. It also must not
call put_net() if the call to rpc_fill_super was unsuccessful.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: stable@vger.kernel.org [>= v3.4]
---
 net/sunrpc/rpc_pipe.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 21fde99..2a419f1 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1152,14 +1152,19 @@ static void rpc_kill_sb(struct super_block *sb)
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	mutex_lock(&sn->pipefs_sb_lock);
+	if (sn->pipefs_sb != sb) {
+		mutex_unlock(&sn->pipefs_sb_lock);
+		goto out;
+	}
 	sn->pipefs_sb = NULL;
 	mutex_unlock(&sn->pipefs_sb_lock);
-	put_net(net);
 	dprintk("RPC:	sending pipefs UMOUNT notification for net %p%s\n", net,
 								NET_NAME(net));
 	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_UMOUNT,
 					   sb);
+	put_net(net);
+out:
 	kill_litter_super(sb);
 }
 
-- 
1.7.11.7

