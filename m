Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:62757 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab2HMVVe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 17:21:34 -0400
Received: by ghrr11 with SMTP id r11so3559707ghr.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 14:21:34 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] SUNRPC: Clean up dprintk messages in rpc_pipe.c
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Aug 2012 17:21:32 -0400
Message-ID: <20120813212132.1680.63593.stgit@degas.1015granger.net>
In-Reply-To: <20120813210739.1680.53741.stgit@degas.1015granger.net>
References: <20120813210739.1680.53741.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The blank space in front of the message must be spaces.
Tabs show up on the console as a graphical character.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpc_pipe.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 21fde99..80f5dd2 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1119,8 +1119,8 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 		return -ENOMEM;
 	if (rpc_populate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF, NULL))
 		return -ENOMEM;
-	dprintk("RPC:	sending pipefs MOUNT notification for net %p%s\n", net,
-								NET_NAME(net));
+	dprintk("RPC:       sending pipefs MOUNT notification for net %p%s\n",
+		net, NET_NAME(net));
 	sn->pipefs_sb = sb;
 	err = blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_MOUNT,
@@ -1155,8 +1155,8 @@ static void rpc_kill_sb(struct super_block *sb)
 	sn->pipefs_sb = NULL;
 	mutex_unlock(&sn->pipefs_sb_lock);
 	put_net(net);
-	dprintk("RPC:	sending pipefs UMOUNT notification for net %p%s\n", net,
-								NET_NAME(net));
+	dprintk("RPC:       sending pipefs UMOUNT notification for net %p%s\n",
+		net, NET_NAME(net));
 	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_UMOUNT,
 					   sb);

