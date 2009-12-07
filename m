From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 30/35] pnfsd: gfs2: use generic file layout pnfs operations vector
Date: Mon,  7 Dec 2009 11:36:26 +0200
Message-ID: <1260178586-15984-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42227 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934920AbZLGJfa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:35:30 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
[gfs2: set pnfs_dlm_export_ops only for CONFIG_PNFSD]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
---
 fs/gfs2/ops_fstype.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
index 52fb6c0..f5abd93 100644
--- a/fs/gfs2/ops_fstype.c
+++ b/fs/gfs2/ops_fstype.c
@@ -18,6 +18,7 @@
 #include <linux/mount.h>
 #include <linux/gfs2_ondisk.h>
 #include <linux/slow-work.h>
+#include <linux/nfsd/nfs4pnfsdlm.h>
 
 #include "gfs2.h"
 #include "incore.h"
@@ -1147,6 +1148,9 @@ static int fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_magic = GFS2_MAGIC;
 	sb->s_op = &gfs2_super_ops;
 	sb->s_export_op = &gfs2_export_ops;
+#if defined(CONFIG_PNFSD)
+	sb->s_pnfs_op = &pnfs_dlm_export_ops;
+#endif /* CONFIG_PNFSD */
 	sb->s_xattr = gfs2_xattr_handlers;
 	sb->s_time_gran = 1;
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
-- 
1.6.5.1

