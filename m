From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/2] nfsd: make sure data is on disk before calling ->fsync
Date: Fri, 25 Dec 2009 17:44:45 +0100
Message-ID: <20091225164445.GA4578@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: bfields@fieldses.org, viro@zeniv.linux.org.uk, jack@suse.cz
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd is not using vfs_fsync, so I missed it when changing the calling
convention during the 2.6.32 window.  This patch fixes it to not only
start the data writeout, but also wait for it to complete before calling
into ->fsync.

Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.orig/fs/nfsd/vfs.c	2009-12-25 17:21:32.371024157 +0100
+++ linux-2.6/fs/nfsd/vfs.c	2009-12-25 17:31:39.644006085 +0100
@@ -780,12 +780,9 @@ static inline int nfsd_dosync(struct fil
 	int (*fsync) (struct file *, struct dentry *, int);
 	int err;
 
-	err = filemap_fdatawrite(inode->i_mapping);
+	err = filemap_write_and_wait(inode->i_mapping);
 	if (err == 0 && fop && (fsync = fop->fsync))
 		err = fsync(filp, dp, 0);
-	if (err == 0)
-		err = filemap_fdatawait(inode->i_mapping);
-
 	return err;
 }
 
