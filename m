Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38868 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbcADSWA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:22:00 -0500
Received: by mail-ig0-f180.google.com with SMTP id mw1so109439020igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:22:00 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 18/18] NFSv4.1/pNFS: Cleanup constify struct pnfs_layout_range arguments
Date: Mon,  4 Jan 2016 13:21:16 -0500
Message-Id: <1451931676-68481-18-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-17-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-7-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-8-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-9-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-10-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-11-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-12-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-13-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-14-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-15-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-16-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-17-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 6 +++---
 fs/nfs/pnfs.h | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ebf896b54d9d..04db6d951b99 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -566,7 +566,7 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 int
 pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 			    struct list_head *tmp_list,
-			    struct pnfs_layout_range *recall_range)
+			    const struct pnfs_layout_range *recall_range)
 {
 	struct pnfs_layout_segment *lseg, *next;
 	int remaining = 0;
@@ -828,7 +828,7 @@ pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo)
 
 int
 pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
-			      struct pnfs_layout_range *range,
+			      const struct pnfs_layout_range *range,
 			      struct nfs4_state *open_state)
 {
 	int status = 0;
@@ -1771,7 +1771,7 @@ pnfs_set_plh_return_iomode(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode)
 int
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
-				struct pnfs_layout_range *return_range)
+				const struct pnfs_layout_range *return_range)
 {
 	struct pnfs_layout_segment *lseg, *next;
 	int remaining = 0;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index dcc76335fd4b..78df618a1596 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -261,14 +261,14 @@ void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     bool update_barrier);
 int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct pnfs_layout_hdr *lo,
-				  struct pnfs_layout_range *range,
+				  const struct pnfs_layout_range *range,
 				  struct nfs4_state *open_state);
 int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
-				struct pnfs_layout_range *recall_range);
+				const struct pnfs_layout_range *recall_range);
 int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
-				struct pnfs_layout_range *recall_range);
+				const struct pnfs_layout_range *recall_range);
 bool pnfs_roc(struct inode *ino);
 void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
-- 
2.5.0

