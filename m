Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46355 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751260AbdLKGEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Dec 2017 01:04:25 -0500
From: NeilBrown <neilb@suse.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Date: Mon, 11 Dec 2017 17:04:05 +1100
Subject: [PATCH 1/4] fs/notify: fdinfo can report unsupported file handles.
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amir Goldstein <amir73il@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Message-ID: <151297224512.7818.18333908109878259066.stgit@noble>
In-Reply-To: <151297214390.7818.7216826079527521005.stgit@noble>
References: <151297214390.7818.7216826079527521005.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a filesystem does not set sb->s_export_op, then it
does not support filehandles and export_fs_encode_fh()
and exportfs_encode_inode_fh() should not be called.
They will use export_encode_fh() is which is a default
that uses inode number generation number, but in general
they may not be stable.

So change exportfs_encode_inode_fh() to return FILEID_INVALID
if called on an unsupported Filesystem.  Currently only
notify/fdinfo can do that.

Also remove the WARNing from fdinfo when exportfs_encode_inode_fh()
returns FILEID_INVALID, as that is no an erroneous condition.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/exportfs/expfs.c |    4 +++-
 fs/notify/fdinfo.c  |    4 +---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 329a5d103846..f5b27dd843a1 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -385,7 +385,9 @@ int exportfs_encode_inode_fh(struct inode *inode, struct fid *fid,
 {
 	const struct export_operations *nop = inode->i_sb->s_export_op;
 
-	if (nop && nop->encode_fh)
+	if (nop)
+		return FILEID_INVALID;
+	if (nop->encode_fh)
 		return nop->encode_fh(inode, fid->raw, max_len, parent);
 
 	return export_encode_fh(inode, fid, max_len, parent);
diff --git a/fs/notify/fdinfo.c b/fs/notify/fdinfo.c
index d478629c728b..d1135ed61229 100644
--- a/fs/notify/fdinfo.c
+++ b/fs/notify/fdinfo.c
@@ -50,10 +50,8 @@ static void show_mark_fhandle(struct seq_file *m, struct inode *inode)
 	size = f.handle.handle_bytes >> 2;
 
 	ret = exportfs_encode_inode_fh(inode, (struct fid *)f.handle.f_handle, &size, 0);
-	if ((ret == FILEID_INVALID) || (ret < 0)) {
-		WARN_ONCE(1, "Can't encode file handler for inotify: %d\n", ret);
+	if ((ret == FILEID_INVALID) || (ret < 0))
 		return;
-	}
 
 	f.handle.handle_type = ret;
 	f.handle.handle_bytes = size * sizeof(u32);


