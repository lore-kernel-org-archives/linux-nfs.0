Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f50.google.com ([209.85.128.50]:33562 "EHLO
	mail-qe0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103Ab3IZSmr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:47 -0400
Received: by mail-qe0-f50.google.com with SMTP id a11so1075653qen.23
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:47 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 42/49] pnfsd: gfs2: use generic file layout pnfs operations vector
Date: Thu, 26 Sep 2013 14:42:44 -0400
Message-Id: <1380220964-14623-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
[gfs2: set pnfs_dlm_export_ops only for CONFIG_PNFSD]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/gfs2/ops_fstype.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
index 19ff5e8..d16a6e6 100644
--- a/fs/gfs2/ops_fstype.c
+++ b/fs/gfs2/ops_fstype.c
@@ -21,6 +21,7 @@
 #include <linux/quotaops.h>
 #include <linux/lockdep.h>
 #include <linux/module.h>
+#include <linux/nfsd/nfs4pnfsdlm.h>
 
 #include "gfs2.h"
 #include "incore.h"
@@ -1154,6 +1155,9 @@ static int fill_super(struct super_block *sb, struct gfs2_args *args, int silent
 	sb->s_op = &gfs2_super_ops;
 	sb->s_d_op = &gfs2_dops;
 	sb->s_export_op = &gfs2_export_ops;
+#if defined(CONFIG_PNFSD)
+	sb->s_pnfs_op = &pnfs_dlm_export_ops;
+#endif /* CONFIG_PNFSD */
 	sb->s_xattr = gfs2_xattr_handlers;
 	sb->s_qcop = &gfs2_quotactl_ops;
 	sb_dqopt(sb)->flags |= DQUOT_QUOTA_SYS_FILE;
-- 
1.8.3.1

