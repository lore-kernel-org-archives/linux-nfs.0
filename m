Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38501 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751000AbeBSFER (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:04:17 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:29 +1100
Subject: [PATCH 11/23] SUNRPC: discard RPC_DO_ROOTOVERRIDE()
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654914.17421.9135409318759363962.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
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
index 592653becd91..fc762d0076c0 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -131,7 +131,6 @@ struct rpc_task_setup {
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
-#define RPC_DO_ROOTOVERRIDE(t)	((t)->tk_flags & RPC_TASK_ROOTCREDS)
 #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
 #define RPC_IS_SOFT(t)		((t)->tk_flags & (RPC_TASK_SOFT|RPC_TASK_TIMEOUT))
 #define RPC_IS_SOFTCONN(t)	((t)->tk_flags & RPC_TASK_SOFTCONN)


