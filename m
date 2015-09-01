Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34379 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbIATTp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2015 15:19:45 -0400
Received: by padhy1 with SMTP id hy1so5055935pad.1
        for <linux-nfs@vger.kernel.org>; Tue, 01 Sep 2015 12:19:44 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFSv4.1/flexfiles: Fix freeing of mirrors
Date: Tue,  1 Sep 2015 12:19:42 -0700
Message-Id: <1441135182-6075-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mirrors are now shared objects, so we should not be freeing them directly
inside ff_layout_free_lseg(). We should already be doing the right thing
in _ff_layout_free_lseg(), so just let it handle things.

Also ensure that ff_layout_free_mirror() frees the RPC credential if it
is set.

Fixes: 28a0d72c6867 ("Add refcounting to struct nfs4_ff_layout_mirror")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 61ccf1122494..ee8e7013454f 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -213,6 +213,8 @@ static void ff_layout_free_mirror(struct nfs4_ff_layout_mirror *mirror)
 {
 	ff_layout_remove_mirror(mirror);
 	kfree(mirror->fh_versions);
+	if (mirror->cred)
+		put_rpccred(mirror->cred);
 	nfs4_ff_layout_put_deviceid(mirror->mirror_ds);
 	kfree(mirror);
 }
@@ -525,21 +527,9 @@ static void
 ff_layout_free_lseg(struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
-	int i;
 
 	dprintk("--> %s\n", __func__);
 
-	for (i = 0; i < fls->mirror_array_cnt; i++) {
-		if (fls->mirror_array[i]) {
-			nfs4_ff_layout_put_deviceid(fls->mirror_array[i]->mirror_ds);
-			fls->mirror_array[i]->mirror_ds = NULL;
-			if (fls->mirror_array[i]->cred) {
-				put_rpccred(fls->mirror_array[i]->cred);
-				fls->mirror_array[i]->cred = NULL;
-			}
-		}
-	}
-
 	if (lseg->pls_range.iomode == IOMODE_RW) {
 		struct nfs4_flexfile_layout *ffl;
 		struct inode *inode;
-- 
2.4.3

