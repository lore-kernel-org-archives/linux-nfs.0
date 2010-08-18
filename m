Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082Ab0HROog (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:36 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 10/11] SQUASHME pnfs_submit rename pnfs_layout_type 10
Date: Wed, 18 Aug 2010 10:44:17 -0400
Message-Id: <1282142658-21579-11-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-10-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
 <1282142658-21579-2-git-send-email-andros@netapp.com>
 <1282142658-21579-3-git-send-email-andros@netapp.com>
 <1282142658-21579-4-git-send-email-andros@netapp.com>
 <1282142658-21579-5-git-send-email-andros@netapp.com>
 <1282142658-21579-6-git-send-email-andros@netapp.com>
 <1282142658-21579-7-git-send-email-andros@netapp.com>
 <1282142658-21579-8-git-send-email-andros@netapp.com>
 <1282142658-21579-9-git-send-email-andros@netapp.com>
 <1282142658-21579-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: cb_layoutrecall

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e2ea2be..638f074 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -120,7 +120,7 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
 #if defined(CONFIG_NFS_V4_1)
 
 static bool
-pnfs_is_next_layout_stateid(const struct pnfs_layout_type *lo,
+pnfs_is_next_layout_stateid(const struct pnfs_layout_hdr *lo,
 			    const nfs4_stateid stateid)
 {
 	int seqlock;
@@ -161,7 +161,7 @@ nfs_layoutrecall_find_inode(struct nfs_client *clp,
 			    const struct cb_pnfs_layoutrecallargs *args)
 {
 	struct nfs_inode *nfsi;
-	struct pnfs_layout_type *layout;
+	struct pnfs_layout_hdr *lo;
 	struct nfs_server *server;
 	struct inode *ino = NULL;
 
@@ -169,8 +169,8 @@ nfs_layoutrecall_find_inode(struct nfs_client *clp,
 		__func__, args->cbl_recall_type, clp);
 
 	spin_lock(&clp->cl_lock);
-	list_for_each_entry(layout, &clp->cl_layouts, lo_layouts) {
-		nfsi = PNFS_NFS_INODE(layout);
+	list_for_each_entry(lo, &clp->cl_layouts, lo_layouts) {
+		nfsi = PNFS_NFS_INODE(lo);
 		if (!nfsi)
 			continue;
 
-- 
1.6.2.5

