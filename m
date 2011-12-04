Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41971 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143Ab1LDNsw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:48:52 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so3592866eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:48:52 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/13] pnfsd-block: do not override s_pnfs_op
Date: Sun,  4 Dec 2011 15:48:46 +0200
Message-Id: <1323006526-13620-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 9585795..a12d7a9 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -402,7 +402,7 @@ static int pnfsd_check_export(struct inode *inode, int *flags)
 
 #if defined(CONFIG_SPNFS)
 #if defined(CONFIG_SPNFS_BLOCK)
-	if (pnfs_block_enabled(inode, *flags)) {
+	if (!inode->i_sb->s_pnfs_op && pnfs_block_enabled(inode, *flags)) {
 		dprintk("set pnfs block export structure... \n");
 		inode->i_sb->s_pnfs_op = &bl_export_ops;
 	} else
-- 
1.7.6

