Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46084 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168Ab1ARUpR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 15:45:17 -0500
Date: Tue, 18 Jan 2011 15:45:09 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20110118204509.GA10903@fieldses.org>
References: <20101129193248.GA9897@fieldses.org>
 <AANLkTikwzDJ_q65==uxDsAhp3h8bU7Rkt7U9gVgRAK0D@mail.gmail.com>
 <20101203223326.GB28763@fieldses.org>
 <20101213051944.GA8688@amd>
 <20101214220102.GM24828@fieldses.org>
 <20101217180022.GB11515@fieldses.org>
 <20101218020118.GA3179@amd>
 <20101218161609.GA22150@fieldses.org>
 <AANLkTingRv_gtRSctGzMfYrKg02M_sKj97HSQPRm_mA_@mail.gmail.com>
 <20101227234641.GA22248@fieldses.org>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20101227234641.GA22248@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

An updated version attempting to take into account the new locking.
(Nick, did I get this right?)

--b.

From: J. Bruce Fields <bfields@redhat.com>
Date: Fri, 17 Dec 2010 09:05:04 -0500
Subject: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed dentries

Without this patch, inodes are not promptly freed on last close of an
unlinked file by an nfs client:

       client$ mount -tnfs4 server:/export/ /mnt/
       client$ tail -f /mnt/FOO
       ...
       server$ df -i /export
       server$ rm /export/FOO
       (^C the tail -f)
       server$ df -i /export
       server$ echo 2 >/proc/sys/vm/drop_caches
       server$ df -i /export

the df's will show that the inode is not freed on the filesystem until
the last step, when it could have been freed after killing the client's
tail -f.  On-disk data won't be deallocated either, leading to possible
spurious ENOSPC.

This occurs because when the client does the close, it arrives in a
compound with a putfh and a close, processed like:

	- putfh: look up the filehandle.  The only alias found for the
	  inode will be DCACHE_UNHASHED alias referenced by the filp
	  this, so it creates a new DCACHE_DISCONECTED dentry and
	  returns that instead.
	- close: closes the existing filp, which is destroyed
	  immediately by dput() since it's DCACHE_UNHASHED.
	- end of the compound: release the reference
	  to the current filehandle, and dput() the new
	  DCACHE_DISCONECTED dentry, which gets put on the
	  unused list instead of being destroyed immediately.

Nick Piggin suggested fixing this by allowing d_obtain_alias to return
the unhashed dentry that is referenced by the filp, instead of making it
create a new dentry.

Leave __d_find_alias() alone to avoid changing behavior of other
callers.

Also nfsd doesn't need all the checks of __d_find_alias(); any dentry,
hashed or unhashed, disconnected or not, should work.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 9f493ee..2849258 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1521,6 +1521,28 @@ struct dentry * d_alloc_root(struct inode * root_inode)
 }
 EXPORT_SYMBOL(d_alloc_root);
 
+static struct dentry * __d_find_any_alias(struct inode *inode)
+{
+	struct dentry *alias;
+
+	if (list_empty(&inode->i_dentry))
+		return NULL;
+	alias = list_first_entry(&inode->i_dentry, struct dentry, d_alias);
+	__dget(alias);
+	return alias;
+}
+
+static struct dentry * d_find_any_alias(struct inode *inode)
+{
+	struct dentry *de;
+
+	spin_lock(&inode->i_lock);
+	de = __d_find_any_alias(inode);
+	spin_unlock(&inode->i_lock);
+	return de;
+}
+
+
 /**
  * d_obtain_alias - find or allocate a dentry for a given inode
  * @inode: inode to allocate the dentry for
@@ -1550,7 +1572,7 @@ struct dentry *d_obtain_alias(struct inode *inode)
 	if (IS_ERR(inode))
 		return ERR_CAST(inode);
 
-	res = d_find_alias(inode);
+	res = d_find_any_alias(inode);
 	if (res)
 		goto out_iput;
 
@@ -1563,7 +1585,7 @@ struct dentry *d_obtain_alias(struct inode *inode)
 
 
 	spin_lock(&inode->i_lock);
-	res = __d_find_alias(inode, 0);
+	res = __d_find_any_alias(inode);
 	if (res) {
 		spin_unlock(&inode->i_lock);
 		dput(tmp);
-- 
1.7.1

