Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:18191 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408Ab1CEXbJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Mar 2011 18:31:09 -0500
Date: Sun, 6 Mar 2011 00:30:35 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-nfs@vger.kernel.org
cc: linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFSD, VFS: Remove dead code in nfsd_rename()
Message-ID: <alpine.LNX.2.00.1103060024380.6297@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Currently we have the following code in fs/nfsd/vfs.c::nfsd_rename() :

	...
	host_err = nfsd_break_lease(odentry->d_inode);
	if (host_err)
		goto out_drop_write;
	if (ndentry->d_inode) {
		host_err = nfsd_break_lease(ndentry->d_inode);
		if (host_err)
			goto out_drop_write;
	}
	if (host_err)
		goto out_drop_write;
	...

'host_err' is guaranteed to be 0 by the time we test 'ndentry->d_inode'. 
If 'host_err' becomes != 0 inside the 'if' statement, then we goto 
'out_drop_write'. So, after the 'if' statement there is no way that 
'host_err' can be anything but 0, so the test afterwards is just dead 
code.
This patch removes the dead code.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 vfs.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index da1d970..9cc626b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1749,8 +1749,6 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 		if (host_err)
 			goto out_drop_write;
 	}
-	if (host_err)
-		goto out_drop_write;
 	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
 	if (!host_err) {
 		host_err = commit_metadata(tfhp);


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Plain text mails only, please.
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html

