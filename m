From: andros@netapp.com
Subject: [PATCH 10/14] SQUASHME pnfs_submit: change decode_and_add_ds parameter
Date: Thu,  8 Apr 2010 15:54:06 -0400
Message-ID: <1270756450-5570-11-git-send-email-andros@netapp.com>
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
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39333 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933059Ab0DHTy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:58 -0400
In-Reply-To: <1270756450-5570-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation to use the generic deviceid cache

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 506ede1..4882149 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -456,7 +456,7 @@ nfs4_pnfs_ds_add(struct filelayout_mount_type *mt, struct nfs4_pnfs_ds **dsp,
 }
 
 static struct nfs4_pnfs_ds *
-decode_and_add_ds(uint32_t **pp, struct filelayout_mount_type *mt)
+decode_and_add_ds(uint32_t **pp, struct inode *inode)
 {
 	struct nfs4_pnfs_ds *ds = NULL;
 	char r_addr[29]; /* max size of ip/port string */
@@ -493,7 +493,7 @@ decode_and_add_ds(uint32_t **pp, struct filelayout_mount_type *mt)
 	ip_addr = htonl((tmp[0]<<24) | (tmp[1]<<16) | (tmp[2]<<8) | (tmp[3]));
 	port = htons((tmp[4] << 8) | (tmp[5]));
 
-	nfs4_pnfs_ds_add(mt, &ds, ip_addr, port, r_addr, len);
+	nfs4_pnfs_ds_add(FILE_MT(inode), &ds, ip_addr, port, r_addr, len);
 
 	dprintk("%s: addr:port string = %s\n", __func__, r_addr);
 	return ds;
@@ -572,8 +572,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev)
 		}
 		for (j = 0; j < dummy; j++) {
 			if (j == 0) {
-				dsaddr->ds_list[i] = decode_and_add_ds(&p,
-								FILE_MT(ino));
+				dsaddr->ds_list[i] = decode_and_add_ds(&p,ino);
 				if (dsaddr->ds_list[i] == NULL)
 					goto out_err_free;
 			} else {
-- 
1.6.6

