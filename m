Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31269 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755282Ab2GRSUw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jul 2012 14:20:52 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: fix pnfs reversion with directio writes
Date: Wed, 18 Jul 2012 14:20:50 -0400
Message-Id: <1342635650-32105-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1342635650-32105-1-git-send-email-iisaman@netapp.com>
References: <1342635650-32105-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 57208fa7e51 "NFS: Create an write_pageio_init() function"
did not modify the calls in direct.c, preventing direct io from
using pnfs.  This reintroduces that capability.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 69f20c7..42dce909 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -478,7 +478,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	dreq->count = 0;
 	get_dreq(dreq);
 
-	nfs_pageio_init_write(&desc, dreq->inode, FLUSH_STABLE,
+	NFS_PROTO(dreq->inode)->write_pageio_init(&desc, dreq->inode, FLUSH_STABLE,
 			      &nfs_direct_write_completion_ops);
 	desc.pg_dreq = dreq;
 
@@ -782,7 +782,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	size_t requested_bytes = 0;
 	unsigned long seg;
 
-	nfs_pageio_init_write(&desc, inode, FLUSH_COND_STABLE,
+	NFS_PROTO(inode)->write_pageio_init(&desc, inode, FLUSH_COND_STABLE,
 			      &nfs_direct_write_completion_ops);
 	desc.pg_dreq = dreq;
 	get_dreq(dreq);
-- 
1.7.2.1

