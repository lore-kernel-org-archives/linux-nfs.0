Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:45419 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753582AbdCTWHI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Mar 2017 18:07:08 -0400
From: <andros@netapp.com>
To: <trondmy@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/3] NFS cleanup struct nfs4_filelayout_segment
Date: Mon, 20 Mar 2017 18:07:00 -0400
Message-ID: <1490047622-35305-2-git-send-email-andros@netapp.com>
In-Reply-To: <1490047622-35305-1-git-send-email-andros@netapp.com>
References: <1490047622-35305-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/filelayout/filelayout.h | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.h b/fs/nfs/filelayout/filelayout.h
index 2896cb8..4c4d436 100644
--- a/fs/nfs/filelayout/filelayout.h
+++ b/fs/nfs/filelayout/filelayout.h
@@ -55,15 +55,15 @@ struct nfs4_file_layout_dsaddr {
 };
 
 struct nfs4_filelayout_segment {
-	struct pnfs_layout_segment generic_hdr;
-	u32 stripe_type;
-	u32 commit_through_mds;
-	u32 stripe_unit;
-	u32 first_stripe_index;
-	u64 pattern_offset;
-	struct nfs4_file_layout_dsaddr *dsaddr; /* Point to GETDEVINFO data */
-	unsigned int num_fh;
-	struct nfs_fh **fh_array;
+	struct pnfs_layout_segment	generic_hdr;
+	u32				stripe_type;
+	u32				commit_through_mds;
+	u32				stripe_unit;
+	u32				first_stripe_index;
+	u64				pattern_offset;
+	struct nfs4_file_layout_dsaddr	*dsaddr; /* Point to GETDEVINFO data */
+	unsigned int			num_fh;
+	struct nfs_fh			**fh_array;
 };
 
 struct nfs4_filelayout {
-- 
1.8.3.1

