Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:33605 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754731Ab2JWOxX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:23 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 13/25] SUNRPC: remove BUG_ON in rpc_put_sb_net
Date: Tue, 23 Oct 2012 10:43:37 -0400
Message-Id: <1351003429-18887-14-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON() - the condition is definitely a misuse
of the API, but shouldn't cause a crash.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/rpc_pipe.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 80f5dd2..3128a15 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1093,7 +1093,7 @@ void rpc_put_sb_net(const struct net *net)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
-	BUG_ON(sn->pipefs_sb == NULL);
+	WARN_ON(sn->pipefs_sb == NULL);
 	mutex_unlock(&sn->pipefs_sb_lock);
 }
 EXPORT_SYMBOL_GPL(rpc_put_sb_net);
-- 
1.7.9.6 (Apple Git-31.1)

