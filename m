Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33791 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751838AbeAHFb1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Jan 2018 00:31:27 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 08 Jan 2018 16:26:19 +1100
Subject: [PATCH 08/20] SUNRPC: discard RPC_DO_ROOTOVERRIDE()
Cc: linux-nfs@vger.kernel.org
Message-ID: <151538917898.25812.10186715232567272272.stgit@noble>
In-Reply-To: <151538903497.25812.13293229343061416612.stgit@noble>
References: <151538903497.25812.13293229343061416612.stgit@noble>
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


