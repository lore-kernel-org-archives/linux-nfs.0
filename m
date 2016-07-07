Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191AbcGGLCe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jul 2016 07:02:34 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>,
        bfields@fieldses.org
Subject: [PATCH 1/2] nfsd: allow SCSI layout support without block layout
Date: Thu,  7 Jul 2016 07:02:31 -0400
Message-Id: <5ff05b585226b689866f4604adddffc94910f63f.1467889001.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We shouldn't have to configure both NFSD_BLOCKLAYOUT and NFSD_SCSILAYOUT if
all we want are SCSI layouts on the server, so define the xfs export
operations for either configuration.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/xfs/xfs_export.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_export.c b/fs/xfs/xfs_export.c
index a1b2dd828b9d..b08a5541f292 100644
--- a/fs/xfs/xfs_export.c
+++ b/fs/xfs/xfs_export.c
@@ -246,7 +246,7 @@ const struct export_operations xfs_export_operations = {
 	.fh_to_parent		= xfs_fs_fh_to_parent,
 	.get_parent		= xfs_fs_get_parent,
 	.commit_metadata	= xfs_fs_nfs_commit_metadata,
-#ifdef CONFIG_NFSD_BLOCKLAYOUT
+#if defined(CONFIG_NFSD_BLOCKLAYOUT) || defined(CONFIG_NFSD_SCSILAYOUT)
 	.get_uuid		= xfs_fs_get_uuid,
 	.map_blocks		= xfs_fs_map_blocks,
 	.commit_blocks		= xfs_fs_commit_blocks,
-- 
2.5.5

