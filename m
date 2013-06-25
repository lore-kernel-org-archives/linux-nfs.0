Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:15583 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670Ab3FYXDP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 19:03:15 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 3/3] NFSv4.1 use pnfs_device maxcount for the objectlayout gdia_maxcount
Date: Tue, 25 Jun 2013 19:02:55 -0400
Message-Id: <1372201375-6686-4-git-send-email-andros@netapp.com>
In-Reply-To: <1372201375-6686-1-git-send-email-andros@netapp.com>
References: <1372201375-6686-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/objlayout/objlayout.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 1989908..e4f9cbf 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -613,6 +613,7 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 	pd.pgbase = 0;
 	pd.pglen = PAGE_SIZE;
 	pd.mincount = 0;
+	pd.maxcount = PAGE_SIZE;
 
 	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd,
 			pnfslay->plh_lc_cred);
-- 
1.7.11.7

