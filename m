Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44895 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755325Ab3IIUrI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Sep 2013 16:47:08 -0400
Date: Mon, 9 Sep 2013 16:46:55 -0400
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/4] dcache: don't clear DCACHE_DISCONNECTED too early
Message-ID: <20130909204655.GA10599@fieldses.org>
References: <1378579561-26868-1-git-send-email-bfields@redhat.com>
 <1378579561-26868-5-git-send-email-bfields@redhat.com>
 <20130909004647.GK13318@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130909004647.GK13318@ZenIV.linux.org.uk>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 09, 2013 at 01:46:47AM +0100, Al Viro wrote:
> On Sat, Sep 07, 2013 at 02:46:01PM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > DCACHE_DISCONNECTED should not be cleared until we're sure the dentry is
> > connected all the way up to the root of the filesystem.  It *shouldn't*
> > be cleared as soon as the dentry is connected to a parent.  That will
> > cause bugs at least on exportable filesystems.
> 
> Then you probably want this
>                 if (!IS_ROOT(pd)) {
>                         /* must have found a connected parent - great */
>                         spin_lock(&pd->d_lock);
>                         pd->d_flags &= ~DCACHE_DISCONNECTED;
>                         spin_unlock(&pd->d_lock);
>                         noprogress = 0;
> to go through all intermediates, clearing DCACHE_DISCONNECTED on all of
> them; O(depth^2) can suck when we have a long chain of directories...

I'm not sure what you mean--something like the following?

Not having seen complaints about filehandle lookup performance I'm
inclined to leave it alone, though.

--b.

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 5816e19..72ed705 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -90,6 +90,22 @@ find_disconnected_root(struct dentry *dentry)
 	return dentry;
 }
 
+static void clear_disconnected(struct dentry *dentry)
+{
+	dget(dentry);
+	while (dentry->d_flags & DCACHE_DISCONNECTED) {
+		struct dentry *parent = dget_parent(dentry);
+
+		spin_lock(&dentry->d_lock);
+		dentry->d_flags &= ~DCACHE_DISCONNECTED;
+		spin_unlock(&dentry->d_lock);
+
+		dput(dentry);
+		dentry = parent;
+	}
+	dput(dentry);
+}
+
 /*
  * Make sure target_dir is fully connected to the dentry tree.
  *
@@ -114,15 +130,11 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 
 		if (!IS_ROOT(pd)) {
 			/* must have found a connected parent - great */
-			spin_lock(&pd->d_lock);
-			pd->d_flags &= ~DCACHE_DISCONNECTED;
-			spin_unlock(&pd->d_lock);
+			clear_disconnected(target_dir);
 			noprogress = 0;
 		} else if (pd == mnt->mnt_sb->s_root) {
 			printk(KERN_ERR "export: Eeek filesystem root is not connected, impossible\n");
-			spin_lock(&pd->d_lock);
-			pd->d_flags &= ~DCACHE_DISCONNECTED;
-			spin_unlock(&pd->d_lock);
+			clear_disconnected(target_dir);
 			noprogress = 0;
 		} else {
 			/*
