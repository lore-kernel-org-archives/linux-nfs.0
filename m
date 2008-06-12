From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 33/37] NFS: Fix a warning in nfs4_async_handle_error
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.96388.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18187 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754916AbYFLTeL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:11 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJY95L003118
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:34:10 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're not modifying the nfs_server when we call nfs_inc_server_stats and
friends, so allow the compiler to pass 'const' pointers too.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/iostat.h   |    8 ++++----
 fs/nfs/nfs4proc.c |    3 +--
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/iostat.h b/fs/nfs/iostat.h
index 2ec65e1..a369528 100644
--- a/fs/nfs/iostat.h
+++ b/fs/nfs/iostat.h
@@ -19,7 +19,7 @@ struct nfs_iostats {
 	unsigned long		events[__NFSIOS_COUNTSMAX];
 } ____cacheline_aligned;
 
-static inline void nfs_inc_server_stats(struct nfs_server *server,
+static inline void nfs_inc_server_stats(const struct nfs_server *server,
 					enum nfs_stat_eventcounters stat)
 {
 	struct nfs_iostats *iostats;
@@ -31,13 +31,13 @@ static inline void nfs_inc_server_stats(struct nfs_server *server,
 	put_cpu_no_resched();
 }
 
-static inline void nfs_inc_stats(struct inode *inode,
+static inline void nfs_inc_stats(const struct inode *inode,
 				 enum nfs_stat_eventcounters stat)
 {
 	nfs_inc_server_stats(NFS_SERVER(inode), stat);
 }
 
-static inline void nfs_add_server_stats(struct nfs_server *server,
+static inline void nfs_add_server_stats(const struct nfs_server *server,
 					enum nfs_stat_bytecounters stat,
 					unsigned long addend)
 {
@@ -50,7 +50,7 @@ static inline void nfs_add_server_stats(struct nfs_server *server,
 	put_cpu_no_resched();
 }
 
-static inline void nfs_add_stats(struct inode *inode,
+static inline void nfs_add_stats(const struct inode *inode,
 				 enum nfs_stat_bytecounters stat,
 				 unsigned long addend)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 75cdec4..0fc1068 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2766,8 +2766,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server)
 			task->tk_status = 0;
 			return -EAGAIN;
 		case -NFS4ERR_DELAY:
-			nfs_inc_server_stats((struct nfs_server *) server,
-						NFSIOS_DELAY);
+			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 			task->tk_status = 0;

