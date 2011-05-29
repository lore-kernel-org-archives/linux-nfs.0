Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50816 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246Ab1E2SUR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:20:17 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 10/32] pnfs: align layoutget requests on page boundaries
Date: Sun, 29 May 2011 21:20:06 +0300
Message-Id: <1306693206-7983-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

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
1.7.2.3

