Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52426 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbcGRDss (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Jul 2016 23:48:48 -0400
Date: Sun, 17 Jul 2016 20:48:47 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 24/28] NFS: Getattr doesn't require data sync semantics
Message-ID: <20160718034847.GA1195@infradead.org>
References: <1467844205-76852-16-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-17-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-18-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-21-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-22-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 06, 2016 at 06:30:01PM -0400, Trond Myklebust wrote:
> When retrieving stat() information, NFS unfortunately does require us to
> sync writes to disk in order to ensure that mtime and ctime are up to
> date. However we shouldn't have to ensure that those writes are persisted.
> 
> Relaxing that requirement does mean that we may see an mtime/ctime change
> if the server reboots and forces us to replay all writes.
> 
> The exception to this rule are pNFS clients that are required to send
> layoutcommit, however that is dealt with by the call to pnfs_sync_inode()
> in _nfs_revalidate_inode().

This one breaks xfstests generic/207 on block/scsi layout for me.  The
reason for that is that we need a layoutcommit after writing out all
data for the file for the file size to be updated on the server.

Below is my attempt to fix this by re-adding pnfs_sync_inode to
nfs_getattr.  The call in _nfs_revalidate_inode isn't enough as it
doesn't get called in most cases we care about.

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 22a53ee..8bd04cf 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -660,11 +660,20 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	int err = 0;
 
 	trace_nfs_getattr_enter(inode);
-	/* Flush out writes to the server in order to update c/mtime.  */
+
+	/*
+	 * Flush out writes to the server in order to update c/mtime as well
+	 * as the file size.  In the pNFS case this also requires a
+	 * LAYOUTCOMMIT.
+	 */
 	if (S_ISREG(inode->i_mode)) {
 		err = filemap_write_and_wait(inode->i_mapping);
 		if (err)
 			goto out;
+
+		err = pnfs_sync_inode(inode, true);
+		if (err)
+			goto out;
 	}
 
 	/*

