Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54027 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068Ab0L0Xqv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Dec 2010 18:46:51 -0500
Date: Mon, 27 Dec 2010 18:46:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20101227234641.GA22248@fieldses.org>
References: <AANLkTinMq1W1vx-jZnf7cb1cAnh9OyoVRYtVS7zpujfs@mail.gmail.com>
 <20101129193248.GA9897@fieldses.org>
 <AANLkTikwzDJ_q65==uxDsAhp3h8bU7Rkt7U9gVgRAK0D@mail.gmail.com>
 <20101203223326.GB28763@fieldses.org>
 <20101213051944.GA8688@amd>
 <20101214220102.GM24828@fieldses.org>
 <20101217180022.GB11515@fieldses.org>
 <20101218020118.GA3179@amd>
 <20101218161609.GA22150@fieldses.org>
 <AANLkTingRv_gtRSctGzMfYrKg02M_sKj97HSQPRm_mA_@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <AANLkTingRv_gtRSctGzMfYrKg02M_sKj97HSQPRm_mA_@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

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

Acked-by: Nick Piggin <npiggin@kernel.dk>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

On Mon, Dec 20, 2010 at 01:53:10AM +1100, Nick Piggin wrote:
> On Sun, Dec 19, 2010 at 3:16 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Sat, Dec 18, 2010 at 01:01:18PM +1100, Nick Piggin wrote:
> >> Well I don't really know if this is clearer. By convention,
> >> __ prefix version should be same as non prefix version but just
> >> take fewer locks. Why do you have the new d_find_any_alias()?
> >
> > Argh, apologies; with typo fixed.
> 
> OK that makes a lot more sense :)

Thanks very much for your help!--b.

diff --git a/fs/dcache.c b/fs/dcache.c
index 5ed93cd..5c014a5 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1135,6 +1135,28 @@ static inline struct hlist_head *d_hash(struct dentry *parent,
 	return dentry_hashtable + (hash & D_HASHMASK);
 }
 
+static struct dentry * __d_find_any_alias(struct inode *inode)
+{
+	struct dentry *alias;
+
+	if (list_empty(&inode->i_dentry))
+		return NULL;
+	alias = list_first_entry(&inode->i_dentry, struct dentry, d_alias);
+	__dget_locked(alias);
+	return alias;
+}
+
+static struct dentry * d_find_any_alias(struct inode *inode)
+{
+	struct dentry *de;
+
+	spin_lock(&dcache_lock);
+	de = __d_find_any_alias(inode);
+	spin_unlock(&dcache_lock);
+	return de;
+}
+
+
 /**
  * d_obtain_alias - find or allocate a dentry for a given inode
  * @inode: inode to allocate the dentry for
@@ -1164,7 +1186,7 @@ struct dentry *d_obtain_alias(struct inode *inode)
 	if (IS_ERR(inode))
 		return ERR_CAST(inode);
 
-	res = d_find_alias(inode);
+	res = d_find_any_alias(inode);
 	if (res)
 		goto out_iput;
 
@@ -1176,7 +1198,7 @@ struct dentry *d_obtain_alias(struct inode *inode)
 	tmp->d_parent = tmp; /* make sure dput doesn't croak */
 
 	spin_lock(&dcache_lock);
-	res = __d_find_alias(inode, 0);
+	res = __d_find_any_alias(inode);
 	if (res) {
 		spin_unlock(&dcache_lock);
 		dput(tmp);
-- 
1.7.3.4

