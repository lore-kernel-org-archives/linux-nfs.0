Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45452 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727Ab1BIFE2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Feb 2011 00:04:28 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1Pn2E7-000444-Su
	for linux-nfs@vger.kernel.org; Wed, 09 Feb 2011 00:04:27 -0500
Date: Wed, 9 Feb 2011 00:04:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: break lease on unlink due to rename
Message-ID: <20110209050427.GB15514@fieldses.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When I added code to break leases on nfsd rename, I overlooked the case
where the rename unlinks a preexisting file at the target path.

It was an important oversight, and the fix is pretty minor, but there's
no regression here, so I'm a bit on the fence whether to put this off
to 2.6.39 or try to slip it into 2.6.38.

--b.

commit 090f03c2183cf0ad8596c0a8c30a3976a47cdea8
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sun Feb 6 16:46:30 2011 -0500

    nfsd: break lease on unlink due to rename
    
    4795bb37effb7b8fe77e2d2034545d062d3788a8 "nfsd: break lease on unlink,
    link, and rename", only broke the lease on the file that was being
    renamed, and didn't handle the case where the target path refers to an
    already-existing file that will be unlinked by a rename--in that case
    the target file should have any leases broken as well.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4218531..d7aa65c 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1744,6 +1744,13 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	host_err = nfsd_break_lease(odentry->d_inode);
 	if (host_err)
 		goto out_drop_write;
+	if (ndentry->d_inode) {
+		host_err = nfsd_break_lease(ndentry->d_inode);
+		if (host_err)
+			goto out_drop_write;
+	}
+	if (host_err)
+		goto out_drop_write;
 	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
 	if (!host_err) {
 		host_err = commit_metadata(tfhp);
