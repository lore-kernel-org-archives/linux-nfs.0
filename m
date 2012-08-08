Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:35121 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab2HHBuE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Aug 2012 21:50:04 -0400
Received: by ghrr11 with SMTP id r11so282185ghr.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Aug 2012 18:50:03 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/2] NFS41: fix error of setting blocklayoutdriver
Date: Wed,  8 Aug 2012 09:49:37 +0800
Message-Id: <1344390577-1602-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344390577-1602-1-git-send-email-bergwolf@gmail.com>
References: <1344390577-1602-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After commit e38eb650 (NFS: set_pnfs_layoutdriver() from
nfs4_proc_fsinfo()), set_pnfs_layoutdriver() is called inside
nfs4_proc_fsinfo(), but pnfs_blksize is not set. It causes setting
blocklayoutdriver failure and pnfsblock mount failure.

Cc: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 fs/nfs/nfs4proc.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78b2163..299c311 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3362,8 +3362,11 @@ static int nfs4_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, s
 
 	nfs_fattr_init(fsinfo->fattr);
 	error = nfs4_do_fsinfo(server, fhandle, fsinfo);
-	if (error == 0)
+	if (error == 0) {
+		/* block layout checks this! */
+		server->pnfs_blksize = fsinfo->blksize;
 		set_pnfs_layoutdriver(server, fhandle, fsinfo->layouttype);
+	}
 
 	return error;
 }
-- 
1.7.1.262.g5ef3d

