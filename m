Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59075 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752629Ab3JDWMu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Oct 2013 18:12:50 -0400
Date: Fri, 4 Oct 2013 18:12:16 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        sandeen@redhat.com
Subject: Re: [PATCH 2/2] exportfs: fix 32-bit nfsd handling of 64-bit inode
 numbers
Message-ID: <20131004221216.GC18051@fieldses.org>
References: <20131002210736.GA20598@fieldses.org>
 <1380749295-20854-1-git-send-email-bfields@redhat.com>
 <1380749295-20854-2-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380749295-20854-2-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 02, 2013 at 05:28:14PM -0400, J. Bruce Fields wrote:
> @@ -268,6 +268,16 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
>  	if (!dir->i_fop)
>  		goto out;
>  	/*
> +	 * inode->i_ino is unsigned long, kstat->ino is u64, so the
> +	 * former would be insufficient on 32-bit hosts when the
> +	 * filesystem supports 64-bit inode numbers.  So we need to
> +	 * actually call ->getattr, not just read i_ino:
> +	 */
> +	error = vfs_getattr_nosec(path, &stat);

Doh, "path" here is for the parent....  The following works better!

--b.

commit 231d38b6f775c4677a61b4d7dc15e0a0d6bbb709
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Sep 10 11:41:12 2013 -0400

    exportfs: fix 32-bit nfsd handling of 64-bit inode numbers
    
    Symptoms were spurious -ENOENTs on stat of an NFS filesystem from a
    32-bit NFS server exporting a very large XFS filesystem, when the
    server's cache is cold (so the inodes in question are not in cache).
    
    Reviewed-by: Christoph Hellwig <hch@lst.de>
    Reported-by: Trevor Cordes <trevor@tecnopolis.ca>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index a235f00..c43fe9b 100644
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
@@ -255,10 +255,14 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
 	struct inode *dir = path->dentry->d_inode;
 	int error;
 	struct file *file;
+	struct kstat stat;
+	struct path child_path = {
+		.mnt = path->mnt,
+		.dentry = child,
+	};
 	struct getdents_callback buffer = {
 		.ctx.actor = filldir_one,
 		.name = name,
-		.ino = child->d_inode->i_ino
 	};
 
 	error = -ENOTDIR;
@@ -268,6 +272,16 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
 	if (!dir->i_fop)
 		goto out;
 	/*
+	 * inode->i_ino is unsigned long, kstat->ino is u64, so the
+	 * former would be insufficient on 32-bit hosts when the
+	 * filesystem supports 64-bit inode numbers.  So we need to
+	 * actually call ->getattr, not just read i_ino:
+	 */
+	error = vfs_getattr_nosec(&child_path, &stat);
+	if (error)
+		return error;
+	buffer.ino = stat.ino;
+	/*
 	 * Open the directory ...
 	 */
 	file = dentry_open(path, O_RDONLY, cred);
