Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:34095 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756600Ab2DTOUH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 10:20:07 -0400
Subject: [PATCH 3/3] SUNRPC: set per-net PipeFS superblock before notification
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 20 Apr 2012 18:19:56 +0400
Message-ID: <20120420141950.10848.46577.stgit@localhost6.localdomain6>
In-Reply-To: <20120420141419.10848.84280.stgit@localhost6.localdomain6>
References: <20120420141419.10848.84280.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There can be a case, when on MOUNT event RPC client (after it's dentries were
created) is not longer hold by anyone except notification callback.
I.e. on release this client will be destoroyed. And it's dentries have to be
destroyed as well. Which in turn requires per-net PipeFS superblock to be set.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpc_pipe.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 0af37fc..3b62cf2 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1126,19 +1126,20 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 		return -ENOMEM;
 	dprintk("RPC:	sending pipefs MOUNT notification for net %p%s\n", net,
 								NET_NAME(net));
+	sn->pipefs_sb = sb;
 	err = blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_MOUNT,
 					   sb);
 	if (err)
 		goto err_depopulate;
 	sb->s_fs_info = get_net(net);
-	sn->pipefs_sb = sb;
 	return 0;
 
 err_depopulate:
 	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_UMOUNT,
 					   sb);
+	sn->pipefs_sb = NULL;
 	__rpc_depopulate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF);
 	return err;
 }

