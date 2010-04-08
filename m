From: andros@netapp.com
Subject: [PATCH 11/14] SQUASHME pnfs_submit: change nfs4_pnfs_ds_add parameter
Date: Thu,  8 Apr 2010 15:54:07 -0400
Message-ID: <1270756450-5570-12-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
 <1270756450-5570-2-git-send-email-andros@netapp.com>
 <1270756450-5570-3-git-send-email-andros@netapp.com>
 <1270756450-5570-4-git-send-email-andros@netapp.com>
 <1270756450-5570-5-git-send-email-andros@netapp.com>
 <1270756450-5570-6-git-send-email-andros@netapp.com>
 <1270756450-5570-7-git-send-email-andros@netapp.com>
 <1270756450-5570-8-git-send-email-andros@netapp.com>
 <1270756450-5570-9-git-send-email-andros@netapp.com>
 <1270756450-5570-10-git-send-email-andros@netapp.com>
 <1270756450-5570-11-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933345Ab0DHTy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:58 -0400
In-Reply-To: <1270756450-5570-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation to use the generic deviceid cache

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 4882149..2cbe931 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -416,11 +416,11 @@ nfs4_pnfs_device_add(struct filelayout_mount_type *mt,
 }
 
 static void
-nfs4_pnfs_ds_add(struct filelayout_mount_type *mt, struct nfs4_pnfs_ds **dsp,
+nfs4_pnfs_ds_add(struct inode *inode, struct nfs4_pnfs_ds **dsp,
 		 u32 ip_addr, u32 port, char *r_addr, int len)
 {
 	struct nfs4_pnfs_ds *tmp_ds, *ds;
-	struct nfs4_pnfs_dev_hlist *hlist = mt->hlist;
+	struct nfs4_pnfs_dev_hlist *hlist = FILE_MT(inode)->hlist;
 
 	*dsp = NULL;
 
@@ -493,7 +493,7 @@ decode_and_add_ds(uint32_t **pp, struct inode *inode)
 	ip_addr = htonl((tmp[0]<<24) | (tmp[1]<<16) | (tmp[2]<<8) | (tmp[3]));
 	port = htons((tmp[4] << 8) | (tmp[5]));
 
-	nfs4_pnfs_ds_add(FILE_MT(inode), &ds, ip_addr, port, r_addr, len);
+	nfs4_pnfs_ds_add(inode, &ds, ip_addr, port, r_addr, len);
 
 	dprintk("%s: addr:port string = %s\n", __func__, r_addr);
 	return ds;
-- 
1.6.6

