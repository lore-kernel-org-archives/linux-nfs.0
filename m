From: Jan Kara <jack@suse.cz>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Tue, 4 Aug 2009 00:29:01 +0200
Message-ID: <20090803222901.GB23162@duck.suse.cz>
References: <20090420162017.GA28079@gradator.net> <20090716172749.GC3740@atrey.karlin.mff.cuni.cz> <20090725151751.GA6419@gradator.net> <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz> <20090728164142.GA13662@gradator.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Cc: linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Sylvain Rochet <gradator-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33222 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643AbZHCW3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Aug 2009 18:29:03 -0400
In-Reply-To: <20090728164142.GA13662-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

  Hi,

On Tue 28-07-09 18:41:42, Sylvain Rochet wrote:
> On Tue, Jul 28, 2009 at 03:52:26PM +0200, Jan Kara wrote:
> > On Tue 28-07-09 13:27:15, Sylvain Rochet wrote:
> > > On Mon, Jul 27, 2009 at 05:42:53PM +0200, Jan Kara wrote:
> > > > On Sat 25-07-09 17:17:52, Sylvain Rochet wrote:
> > > > > > 
> > > > > > Can you still see the corruption with 2.6.30 kernel?
> > > > > 
> > > > > Not upgraded yet, we'll give a try.
> > > 
> > > Done, now featuring 2.6.30.3 ;)
> > 
> > OK, drop me an email if you will see corruption also with this kernel.
> 
> Lets move out the corrupted directory ;)
> 
> root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# rm -- * .ok 
> rm: cannot remove `spip%3Farticle19.f8740dca': Input/output error
> root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# cd ..
> root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache# mv e/ /data/lost+found/wooops
> 
> > > > This is probably the misleading output from ext3_iget(). It should give
> > > > you EIO in the latest kernel.
> > > 
> > > root@bazooka:/data/web/ed/90/48/walotux.walon.org/htdocs/tmp/cache/e# cat spip%3Farticle19.f8740dca 
> > > cat: spip%3Farticle19.f8740dca: Input/output error
> > > 
> > > It has much more sense now. We thought the problem was around NFS due 
> > > the the previous error message, actually this is probably not the best 
> > > looking path.
> > 
> > Yes, EIO makes more sence. I think the problem is NFS connected anyway
> > though :). But I don't have a clue how it can happen yet. Maybe I can try
> > adding some low-cost debugging checks if you'd be willing to run such
> > kernel...
> 
> Without any problem, we have 24/7/365 physical access and we don't need 
> to provide high-availability services.
> 
> Anyway, the data hosted aren't that important, there is little or even 
> no need for strict confidentiality, so we will be happy to provide ssh 
> access to whom would like to look deeper into this issue.
> 
> 
> > I'm adding to CC linux-nfs just in case someone has an idea.
> > 
> > > >   Ah, OK, here's the problem. The directory points to a file which is
> > > > obviously deleted (note the "Links: 0"). All the content of the inode seems
> > > > to indicate that the file was correctly deleted (you might check that the
> > > > corresponding bit in the bitmap is cleared via: "icheck 88541562").
> > > 
> > > root@bazooka:~# debugfs /dev/md10
> > > debugfs 1.40-WIP (14-Nov-2006)
> > > debugfs:  icheck 88541562
> > > Block   Inode number
> > > 88541562        <block not found>
> > 
> > Ah, wrong debugfs command. I should have written:
> > testi <88541562>
> 
> debugfs:  testi <88541562>
> Inode 88541562 is not in use
  OK, I've found some time and written the debugging patch. Hopefully it
will tell us more. It should output messages to the kernel log if it
finds something suspicious - like:
No dentry for unlinked inode...
Dentry ... for unlinked inode ... has no parent
Found directory entry ... for unlinked inode

  When you see such messages in the log, send them to me please. Also
attach the System.map file so that I can translate the address where
i_nlink was dropped - for that ext3 should be compiled into the kernel
(should not be a module). Thanks a lot for testing.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--LZvS9be/3tNcYl/X
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-ext3-Debug-unlinking-of-inodes.patch"

>From b32511dbd58c8d9111001a33d253a283943bbf7a Mon Sep 17 00:00:00 2001
From: Jan Kara <jack@suse.cz>
Date: Tue, 4 Aug 2009 00:17:35 +0200
Subject: [PATCH] ext3: Debug unlinking of inodes

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext3/inode.c    |   28 ++++++++++++++++++++++++++++
 fs/ext3/namei.c    |    2 +-
 include/linux/fs.h |    6 ++++++
 3 files changed, 35 insertions(+), 1 deletions(-)

diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index b49908a..dca30a2 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -2876,6 +2876,9 @@ bad_inode:
 	return ERR_PTR(ret);
 }
 
+struct buffer_head *ext3_find_entry(struct inode *dir,
+                                        struct qstr *entry,
+                                        struct ext3_dir_entry_2 **res_dir);
 /*
  * Post the struct inode info into an on-disk inode location in the
  * buffer-cache.  This gobbles the caller's reference to the
@@ -2892,6 +2895,31 @@ static int ext3_do_update_inode(handle_t *handle,
 	struct buffer_head *bh = iloc->bh;
 	int err = 0, rc, block;
 
+	if (!inode->i_nlink && !inode->i_checked_drop) {
+		struct dentry *dentry;
+		struct ext3_dir_entry_2 *de;
+		struct buffer_head *bh;
+
+		inode->i_checked_drop = 1;
+		if (list_empty(&inode->i_dentry)) {
+			printk("No dentry for unlinked inode %lu\nNlink dropped at 0x%lx\n", inode->i_ino, inode->i_dropped);
+			dump_stack();
+			goto next;
+		}
+		dentry = list_entry(inode->i_dentry.next, struct dentry, d_alias);
+		if (!dentry->d_parent) {
+			printk("Dentry %s for unlinked inode %lu has no parent\nNlink dropped at 0x%lx\n", dentry->d_name.name, inode->i_ino, inode->i_dropped);
+			dump_stack();
+			goto next;
+		}
+		bh = ext3_find_entry(dentry->d_parent->d_inode, &dentry->d_name, &de);
+		if (bh && le32_to_cpu(de->inode) == inode->i_ino) {
+			printk("Found directory entry %s for unlinked inode %lu\nNlink dropped at 0x%lx\n", dentry->d_name.name, inode->i_ino, inode->i_dropped);
+			brelse(bh);
+			dump_stack();
+		}
+	}
+next:
 	/* For fields not not tracking in the in-memory inode,
 	 * initialise them to zero for new inodes. */
 	if (ei->i_state & EXT3_STATE_NEW)
diff --git a/fs/ext3/namei.c b/fs/ext3/namei.c
index 6ff7b97..e66b6c0 100644
--- a/fs/ext3/namei.c
+++ b/fs/ext3/namei.c
@@ -850,7 +850,7 @@ static inline int search_dirblock(struct buffer_head * bh,
  * The returned buffer_head has ->b_count elevated.  The caller is expected
  * to brelse() it when appropriate.
  */
-static struct buffer_head *ext3_find_entry(struct inode *dir,
+struct buffer_head *ext3_find_entry(struct inode *dir,
 					struct qstr *entry,
 					struct ext3_dir_entry_2 **res_dir)
 {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a36ffa5..271c51c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -780,6 +780,8 @@ struct inode {
 	struct posix_acl	*i_acl;
 	struct posix_acl	*i_default_acl;
 #endif
+	unsigned long		i_dropped;
+	int			i_checked_drop;
 	void			*i_private; /* fs or device private pointer */
 };
 
@@ -1693,6 +1695,8 @@ static inline void inode_inc_link_count(struct inode *inode)
 static inline void drop_nlink(struct inode *inode)
 {
 	inode->i_nlink--;
+	inode->i_dropped = _THIS_IP_;
+	inode->i_checked_drop = 0;
 }
 
 /**
@@ -1706,6 +1710,8 @@ static inline void drop_nlink(struct inode *inode)
 static inline void clear_nlink(struct inode *inode)
 {
 	inode->i_nlink = 0;
+	inode->i_dropped = _THIS_IP_;
+	inode->i_checked_drop = 0;
 }
 
 static inline void inode_dec_link_count(struct inode *inode)
-- 
1.6.0.2


--LZvS9be/3tNcYl/X--
