Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36460 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbbGMFUi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 01:20:38 -0400
Received: by lbbpo10 with SMTP id po10so118111120lbb.3
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 22:20:36 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] pNFS: Don't throw out valid layout segments
Date: Mon, 13 Jul 2015 07:20:05 +0200
Message-Id: <1436764805-2893-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1436764805-2893-4-git-send-email-trond.myklebust@primarydata.com>
References: <1436764805-2893-1-git-send-email-trond.myklebust@primarydata.com>
 <1436764805-2893-2-git-send-email-trond.myklebust@primarydata.com>
 <1436764805-2893-3-git-send-email-trond.myklebust@primarydata.com>
 <1436764805-2893-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is OK for layout segments to remain hashed even if no-one holds any
references to them, provided that the segments are still valid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b02e32e2abeb..18aa3b7962eb 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -422,6 +422,10 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 		pnfs_layoutreturn_before_put_lseg(lseg, lo, inode);
 
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
+		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags)) {
+			spin_unlock(&inode->i_lock);
+			return;
+		}
 		pnfs_get_layout_hdr(lo);
 		pnfs_layout_remove_lseg(lo, lseg);
 		spin_unlock(&inode->i_lock);
@@ -462,6 +466,8 @@ pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg)
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	if (atomic_dec_and_test(&lseg->pls_refcount)) {
 		struct pnfs_layout_hdr *lo = lseg->pls_layout;
+		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags))
+			return;
 		pnfs_get_layout_hdr(lo);
 		pnfs_layout_remove_lseg(lo, lseg);
 		pnfs_free_lseg_async(lseg);
-- 
2.4.3

