Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50239 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754883Ab0LQSAZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 13:00:25 -0500
Date: Fri, 17 Dec 2010 13:00:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nick Piggin <npiggin@kernel.dk>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 2/2] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20101217180022.GB11515@fieldses.org>
References: <20101112184353.GA32745@fieldses.org>
 <AANLkTinOSGtrW1S3LKWXarJF-=ZKgh_GMKuPA2ppu-P4@mail.gmail.com>
 <20101115174837.GB10044@fieldses.org>
 <AANLkTim1QjTwOZ4SHdMy8Y6TOAnaOYtTwgwHXfH5H5Xn@mail.gmail.com>
 <AANLkTinMq1W1vx-jZnf7cb1cAnh9OyoVRYtVS7zpujfs@mail.gmail.com>
 <20101129193248.GA9897@fieldses.org>
 <AANLkTikwzDJ_q65==uxDsAhp3h8bU7Rkt7U9gVgRAK0D@mail.gmail.com>
 <20101203223326.GB28763@fieldses.org>
 <20101213051944.GA8688@amd>
 <20101214220102.GM24828@fieldses.org>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20101214220102.GM24828@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Without this patch

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
         associated with the nfsd open.  d_obtain_alias() doesn't like
         this, so it creates a new DCACHE_DISCONECTED dentry and
         returns that instead.

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

On Tue, Dec 14, 2010 at 05:01:02PM -0500, J. Bruce Fields wrote:
> On Mon, Dec 13, 2010 at 04:19:44PM +1100, Nick Piggin wrote:
> > Not sure where Al's hiding...
> > 
> > But I would like to update the comments, and perhaps even a new
> > add a new function here (or new flag to __d_find_alias).
> > 
> > AFAIKS, the callers are OK, however I suppose d_splice_alias and
> > d_materialise_unique should not have unlinked inodes at this point,
> > so at least a BUG_ON for them might be a good idea?
> 
> That does sound safer.  I'm pretty confused by the various
> __di_splice_alias callers.  I'll go search through them and see if I can
> understand better....

I think a new __d_find_alias flag would just make it more confusing.
And it looks like all d_obtain_alias needs is something much simpler.
This works for me.

--b.

diff --git a/fs/dcache.c b/fs/dcache.c
index 5ed93cd..d5f9da4 100644
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
+	de = __d_find_alias(inode, 0);
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
1.7.1

