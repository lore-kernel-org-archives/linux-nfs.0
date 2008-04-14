From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/24] SUNRPC: Use unsigned index when looping over arrays
Date: Mon, 14 Apr 2008 12:27:38 -0400
Message-ID: <20080414162738.12741.26613.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:57381 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755060AbYDNQbA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:31:00 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Suppress a handful of harmless compiler warnings in the RPC
client related to array indices.

ARRAY_SIZE() returns a size_t, so use unsigned type for a loop index when
looping over arrays.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpc_pipe.c |    2 +-
 net/sunrpc/sched.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 1b395a4..5209444 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -529,7 +529,7 @@ static void rpc_depopulate(struct dentry *parent,
 	struct inode *dir = parent->d_inode;
 	struct list_head *pos, *next;
 	struct dentry *dentry, *dvec[10];
-	int n = 0;
+	unsigned int n = 0;
 
 	mutex_lock_nested(&dir->i_mutex, I_MUTEX_CHILD);
 repeat:
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 63fe132..01fc7b8 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -222,7 +222,7 @@ static inline void rpc_reset_waitqueue_priority(struct rpc_wait_queue *queue)
 
 static void __rpc_init_priority_wait_queue(struct rpc_wait_queue *queue, const char *qname, unsigned char nr_queues)
 {
-	int i;
+	unsigned int i;
 
 	spin_lock_init(&queue->lock);
 	for (i = 0; i < ARRAY_SIZE(queue->tasks); i++)

