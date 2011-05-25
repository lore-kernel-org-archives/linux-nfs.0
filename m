Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57097 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869Ab1EYV1n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2011 17:27:43 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v8 10/32] pnfs: align layoutget requests on page boundaries
Date: Thu, 26 May 2011 00:27:40 +0300
Message-Id: <1306358860-17150-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDD7392.6040505@panasas.com>
References: <4DDD7392.6040505@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c2f09e9..2357ee3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -850,6 +850,7 @@ pnfs_update_layout(struct inode *ino,
 		.offset = pos,
 		.length = count,
 	};
+	unsigned pg_offset;
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
 	struct pnfs_layout_hdr *lo;
@@ -899,6 +900,13 @@ pnfs_update_layout(struct inode *ino,
 		spin_unlock(&clp->cl_lock);
 	}
 
+	pg_offset = arg.offset & ~PAGE_CACHE_MASK;
+	if (pg_offset) {
+		arg.offset -= pg_offset;
+		arg.length += pg_offset;
+	}
+	arg.length = PAGE_CACHE_ALIGN(arg.length);
+
 	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
 	if (!lseg && first) {
 		spin_lock(&clp->cl_lock);
-- 
1.7.3.4

