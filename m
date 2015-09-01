Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36603 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbbIATOd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2015 15:14:33 -0400
Received: by pacwi10 with SMTP id wi10so4822108pac.3
        for <linux-nfs@vger.kernel.org>; Tue, 01 Sep 2015 12:14:33 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/flexfiles: Fix freeing of mirrors
Date: Tue,  1 Sep 2015 12:14:29 -0700
Message-Id: <1441134869-3887-1-git-send-email-trond.myklebust@primarydata.com>
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
 fs/nfs/flexfilelayout/flexfilelayout.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 61ccf1122494..beb14e55c217 100644
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
@@ -529,17 +531,6 @@ ff_layout_free_lseg(struct pnfs_layout_segment *lseg)
 
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

