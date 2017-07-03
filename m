Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51357 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750861AbdGCF2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Jul 2017 01:28:05 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 03 Jul 2017 15:27:26 +1000
Subject: [PATCH 1/2] NFS: guard against confused server in nfs_atomic_open()
Cc: linux-nfs@vger.kernel.org
Message-ID: <149905964664.6926.2427823210014981309.stgit@noble>
In-Reply-To: <149905933708.6926.8527235505351389675.stgit@noble>
References: <149905933708.6926.8527235505351389675.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A confused server could return a filehandle for an
NFSv4 OPEN request, which it previously returned for a directory.
So the inode returned by  ->open_context() in nfs_atomic_open()
could conceivably be a directory inode.

This has particular implications for the call to
nfs_file_set_open_context() in nfs_finish_open().
If that is called on a directory inode, then the nfs_open_context
that gets stored in the filp->private_data will be linked to
nfs_inode->open_files.

When the directory is closed, nfs_closedir() will (ultimately)
free the ->private_data, but not unlink it from nfs_inode->open_files
(because it doesn't expect an nfs_open_context there).

Subsequently the memory could get used for something else and eventually
if the ->open_files list is walked, the walker will fall off the end and
crash.

So: change nfs_finish_open() to only call nfs_file_set_open_context()
for regular-file inodes.

This failure mode has been seen in a production setting (unknown NFS
server implementation).  The kernel was v3.0 and the specific sequence
seen would not affect more recent kernels, but I think a risk is still
present, and caution is wise.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/dir.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2ac00bf4ecf1..4f0706bd387f 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1427,8 +1427,10 @@ static int nfs_finish_open(struct nfs_open_context *ctx,
 	err = finish_open(file, dentry, do_open, opened);
 	if (err)
 		goto out;
-	nfs_file_set_open_context(file, ctx);
-
+	if (S_ISREG(file->f_path.dentry->d_inode->i_mode))
+		nfs_file_set_open_context(file, ctx);
+	else
+		err = -ESTALE;
 out:
 	return err;
 }


