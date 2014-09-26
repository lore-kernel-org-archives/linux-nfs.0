Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:41870 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875AbaIZCYJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2014 22:24:09 -0400
Received: by mail-ig0-f173.google.com with SMTP id l13so9597704iga.12
        for <linux-nfs@vger.kernel.org>; Thu, 25 Sep 2014 19:24:08 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Ensure rpc_fill_super sets sb->s_fs_info before calling notifiers
Date: Thu, 25 Sep 2014 22:24:02 -0400
Message-Id: <1411698242-126323-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpc_pipefs event handlers expect the sb->s_fs_info field to contain
the net namespace. Ensure that we set it before we call the notifier list.

Fixes: 2d00131acc64 (SUNRPC: send notification events on pipefs sb creation...)
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/rpc_pipe.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 2d12b76b5a64..17d685680c46 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1414,12 +1414,12 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 		net, NET_NAME(net));
 	mutex_lock(&sn->pipefs_sb_lock);
 	sn->pipefs_sb = sb;
+	sb->s_fs_info = get_net(net);
 	err = blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_MOUNT,
 					   sb);
 	if (err)
 		goto err_depopulate;
-	sb->s_fs_info = get_net(net);
 	mutex_unlock(&sn->pipefs_sb_lock);
 	return 0;
 
@@ -1431,6 +1431,7 @@ err_depopulate:
 	sn->pipefs_sb = NULL;
 	__rpc_depopulate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF);
 	mutex_unlock(&sn->pipefs_sb_lock);
+	put_net(net);
 	return err;
 }
 
-- 
1.9.3

