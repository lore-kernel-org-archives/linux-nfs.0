Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24130 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755264Ab1EPN71 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 09:59:27 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/4] pnfs: align layoutget requests on page boundaries
Date: Mon, 16 May 2011 06:59:17 -0700
Message-Id: <1305554357-29114-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DCC715C.1090101@panasas.com>
References: <4DCC715C.1090101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

---
 fs/nfs/pnfs.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e689bdf..589989d 100644
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
 	lseg = send_layoutget(lo, ctx, &arg);
 	if (!lseg && first) {
 		spin_lock(&clp->cl_lock);
-- 
1.7.3.4

