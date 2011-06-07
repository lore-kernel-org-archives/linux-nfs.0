Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52595 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756691Ab1FGRfW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:35:22 -0400
Date: Tue, 7 Jun 2011 13:35:19 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 80/88] SQUASHME: pnfs-block: fixup setup_layoutcommit
 arguments
Message-ID: <0a87173438422d20c18b5b9783a7eb71296ecd7b.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 5f11fb8..ff94ee2 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -617,7 +617,7 @@ bl_alloc_lseg(struct pnfs_layout_hdr *lo,
 
 static int
 bl_setup_layoutcommit(struct pnfs_layout_hdr *lo,
-		      struct nfs4_layoutcommit_args *arg)
+		      struct nfs4_layoutcommit_op_args *arg)
 {
 	struct nfs_server *nfss = NFS_SERVER(lo->inode);
 	struct bl_layoutupdate_data *layoutupdate_data;
-- 
1.7.4.1

