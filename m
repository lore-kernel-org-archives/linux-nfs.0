Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40265 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752259AbdLKElR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 10 Dec 2017 23:41:17 -0500
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 45E93AAB5
        for <linux-nfs@vger.kernel.org>; Mon, 11 Dec 2017 04:41:16 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 11 Dec 2017 15:40:17 +1100
Subject: [PATCH 07/19] SUNRPC: discard RPC_DO_ROOTOVERRIDE()
Message-ID: <151296721769.24753.8382369037328622827.stgit@noble>
In-Reply-To: <151296579813.24753.5905981862981613395.stgit@noble>
References: <151296579813.24753.5905981862981613395.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

it is never used.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/sched.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d96e74e114c0..3b3c5ab57341 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -131,7 +131,6 @@ struct rpc_task_setup {
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
-#define RPC_DO_ROOTOVERRIDE(t)	((t)->tk_flags & RPC_TASK_ROOTCREDS)
 #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
 #define RPC_IS_SOFT(t)		((t)->tk_flags & (RPC_TASK_SOFT|RPC_TASK_TIMEOUT))
 #define RPC_IS_SOFTCONN(t)	((t)->tk_flags & RPC_TASK_SOFTCONN)


