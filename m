Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53223 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753868Ab1GOXUS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jul 2011 19:20:18 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@kernel.org
Subject: [PATCH 1/2] nfsd4: remember to put RW access on stateid destruction
Date: Fri, 15 Jul 2011 19:20:14 -0400
Message-Id: <1310772015-29056-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Without this, for example,

	open read
	open read+write
	close

will result in a struct file leak.

Regression from 7d94784293096c0a46897acdb83be5abd9278ece "nfsd4: fix
downgrade/lock logic".

Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 12244ce..5e8806a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -385,14 +385,6 @@ static int nfs4_access_to_omode(u32 access)
 	BUG();
 }
 
-static int nfs4_access_bmap_to_omode(struct nfs4_stateid *stp)
-{
-	unsigned int access;
-
-	set_access(&access, stp->st_access_bmap);
-	return nfs4_access_to_omode(access);
-}
-
 static void unhash_generic_stateid(struct nfs4_stateid *stp)
 {
 	list_del(&stp->st_hash);
@@ -402,11 +394,14 @@ static void unhash_generic_stateid(struct nfs4_stateid *stp)
 
 static void free_generic_stateid(struct nfs4_stateid *stp)
 {
-	int oflag;
+	int i;
 
 	if (stp->st_access_bmap) {
-		oflag = nfs4_access_bmap_to_omode(stp);
-		nfs4_file_put_access(stp->st_file, oflag);
+		for (i = 1; i < 4; i++) {
+			if (test_bit(i, &stp->st_access_bmap))
+				nfs4_file_put_access(stp->st_file,
+						nfs4_access_to_omode(i));
+		}
 	}
 	put_nfs4_file(stp->st_file);
 	kmem_cache_free(stateid_slab, stp);
-- 
1.7.4.1

