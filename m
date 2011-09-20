Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38376 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411Ab1ITStc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 14:49:32 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1R65Nr-00042P-PZ
	for linux-nfs@vger.kernel.org; Tue, 20 Sep 2011 14:49:31 -0400
Date: Tue, 20 Sep 2011 14:49:31 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: fix open downgrade, again
Message-ID: <20110920184931.GA15273@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I intend to queue this up for 3.2.--b.

commit 3d02fa29dec920c597dd7b7db608a4bc71f088ce
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Sep 19 15:07:41 2011 -0400

    nfsd4: fix open downgrade, again
    
    Yet another open-management regression:
    
    	- nfs4_file_downgrade() doesn't remove the BOTH access bit on
    	  downgrade, so the server's idea of the stateid's access gets
    	  out of sync with the client's.  If we want to keep an O_RDWR
    	  open in this case, we should do that in the file_put_access
    	  logic rather than here.
    	- We forgot to convert v4 access to an open mode here.
    
    This logic has proven too hard to get right.  In the future we may
    consider:
    	- reexamining the lock/openowner relationship (locks probably
    	  don't really need to take their own references here).
    	- adding open upgrade/downgrade support to the vfs.
    	- removing the atomic operations.  They're redundant as long as
    	  this is all under some other lock.
    
    Also, maybe some kind of additional static checking would help catch
    O_/NFS4_SHARE_ACCESS confusion.
    
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e5cba83..edcced1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -194,8 +194,15 @@ static void nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
 static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 {
 	if (atomic_dec_and_test(&fp->fi_access[oflag])) {
-		nfs4_file_put_fd(fp, O_RDWR);
 		nfs4_file_put_fd(fp, oflag);
+		/*
+		 * It's also safe to get rid of the RDWR open *if*
+		 * we no longer have need of the other kind of access
+		 * or if we already have the other kind of open:
+		 */
+		if (fp->fi_fds[1-oflag]
+			|| atomic_read(&fp->fi_access[1 - oflag]) == 0)
+			nfs4_file_put_fd(fp, O_RDWR);
 	}
 }
 
@@ -3500,8 +3507,9 @@ static inline void nfs4_file_downgrade(struct nfs4_ol_stateid *stp, unsigned int
 	int i;
 
 	for (i = 1; i < 4; i++) {
-		if (test_bit(i, &stp->st_access_bmap) && !(i & to_access)) {
-			nfs4_file_put_access(stp->st_file, i);
+		if (test_bit(i, &stp->st_access_bmap)
+					&& ((i & to_access) != i)) {
+			nfs4_file_put_access(stp->st_file, nfs4_access_to_omode(i));
 			__clear_bit(i, &stp->st_access_bmap);
 		}
 	}
