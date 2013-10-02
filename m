Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50438 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753767Ab3JBV2l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 17:28:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, sandeen@redhat.com,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] exportfs: fix 32-bit nfsd handling of 64-bit inode numbers
Date: Wed,  2 Oct 2013 17:28:14 -0400
Message-Id: <1380749295-20854-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1380749295-20854-1-git-send-email-bfields@redhat.com>
References: <20131002210736.GA20598@fieldses.org>
 <1380749295-20854-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Symptoms were spurious -ENOENTs on stat of an NFS filesystem from a
32-bit NFS server exporting a very large XFS filesystem, when the
server's cache is cold (so the inodes in question are not in cache).

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reported-by: Trevor Cordes <trevor@tecnopolis.ca>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 293bc2e..811831a 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -215,7 +215,7 @@ struct getdents_callback {
 	struct dir_context ctx;
 	char *name;		/* name that was found. It already points to a
 				   buffer NAME_MAX+1 is size */
-	unsigned long ino;	/* the inum we are looking for */
+	u64 ino;		/* the inum we are looking for */
 	int found;		/* inode matched? */
 	int sequence;		/* sequence counter */
 };
@@ -255,10 +255,10 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
 	struct inode *dir = path->dentry->d_inode;
 	int error;
 	struct file *file;
+	struct kstat stat;
 	struct getdents_callback buffer = {
 		.ctx.actor = filldir_one,
 		.name = name,
-		.ino = child->d_inode->i_ino
 	};
 
 	error = -ENOTDIR;
@@ -268,6 +268,16 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
 	if (!dir->i_fop)
 		goto out;
 	/*
+	 * inode->i_ino is unsigned long, kstat->ino is u64, so the
+	 * former would be insufficient on 32-bit hosts when the
+	 * filesystem supports 64-bit inode numbers.  So we need to
+	 * actually call ->getattr, not just read i_ino:
+	 */
+	error = vfs_getattr_nosec(path, &stat);
+	if (error)
+		return error;
+	buffer.ino = stat.ino;
+	/*
 	 * Open the directory ...
 	 */
 	file = dentry_open(path, O_RDONLY, cred);
-- 
1.7.9.5

