Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12039 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752968Ab1EKPzB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2011 11:55:01 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1: remove pnfs_layout_hdr from pnfs_destroy_all_layouts tmp_list
Date: Tue, 10 May 2011 20:54:05 -0400
Message-Id: <1305075245-27123-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Prevents an infinite loop as list was never emptied.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ff681ab..7626369 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -383,6 +383,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 				plh_layouts);
 		dprintk("%s freeing layout for inode %lu\n", __func__,
 			lo->plh_inode->i_ino);
+		list_del(&lo->plh_layouts);
 		pnfs_destroy_layout(NFS_I(lo->plh_inode));
 	}
 }
-- 
1.7.3.1

