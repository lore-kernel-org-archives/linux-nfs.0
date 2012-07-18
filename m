Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31269 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755267Ab2GRSUw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jul 2012 14:20:52 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/2] NFS: fix pnfs reversion with directio reads
Date: Wed, 18 Jul 2012 14:20:49 -0400
Message-Id: <1342635650-32105-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 1abb50886af "NFS: Create an read_pageio_init() function"
did not modify the call in direct.c, preventing direct io from
using pnfs.  This reintroduces that capability.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 4825337..69f20c7 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -393,7 +393,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	size_t requested_bytes = 0;
 	unsigned long seg;
 
-	nfs_pageio_init_read(&desc, dreq->inode,
+	NFS_PROTO(dreq->inode)->read_pageio_init(&desc, dreq->inode,
 			     &nfs_direct_read_completion_ops);
 	get_dreq(dreq);
 	desc.pg_dreq = dreq;
-- 
1.7.2.1

