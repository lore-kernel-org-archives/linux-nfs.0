Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45399 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab1IWSzy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 14:55:54 -0400
Date: Fri, 23 Sep 2011 14:55:46 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 4/6] leases: break read leases on rename
Message-ID: <20110923185546.GA7389@fieldses.org>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
 <1316617097-21384-5-git-send-email-bfields@redhat.com>
 <1316711869.3159.54.camel@localhost.localdomain>
 <20110923165510.GA807@pad.fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110923165510.GA807@pad.fieldses.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 23, 2011 at 12:55:13PM -0400, J. Bruce Fields wrote:
> On Thu, Sep 22, 2011 at 01:17:49PM -0400, Mimi Zohar wrote:
> > On Wed, 2011-09-21 at 10:58 -0400, J. Bruce Fields wrote: 
> > > To rely on the i_mutex for exclusion between setlease and rename, we
> > > need rename to take the i_mutex on the source as well as on any possible
> > > target.
> > > 
> > > I suspect this is deadlock-free, but I need to think this proof through
> > > again.  And I'm not sure what to do about lockdep.
> > 
> > Not sure that I will be of any help, but how about posting the lockdep
> > messages?
> 
> Sure, appended below, but it's not particularly surprising--we're taking
> i_mutex's on four different objects (both parents, source, and target if
> any) where before there were three.
> 
> I suppose the solution is another i_mutex lock class, used only on the
> lock of the source inode?

That'd be something like this.  (Works for me, anyway.)  I'll fold it
into the previous patch.

--b.

diff --git a/fs/namei.c b/fs/namei.c
index f6de42d..06a8d95 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3069,7 +3069,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 		return error;
 
 	dget(new_dentry);
-	mutex_lock(&source->i_mutex);
+	mutex_lock_nested(&source->i_mutex, I_MUTEX_RENAME_SOURCE);
 	error = break_lease(source, O_WRONLY);
 	if (error)
 		goto out_unlock_source;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 76460ed..74f4979 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -839,10 +839,12 @@ static inline int inode_unhashed(struct inode *inode)
  * 0: the object of the current VFS operation
  * 1: parent
  * 2: child/target
- * 3: quota file
+ * 3: xattr
+ * 4: quota file
+ * 5: the file being renamed (used only in rename of a non-directory)
  *
  * The locking order between these classes is
- * parent -> child -> normal -> xattr -> quota
+ * parent -> child -> rename_source -> normal -> xattr -> quota
  */
 enum inode_i_mutex_lock_class
 {
@@ -850,7 +852,8 @@ enum inode_i_mutex_lock_class
 	I_MUTEX_PARENT,
 	I_MUTEX_CHILD,
 	I_MUTEX_XATTR,
-	I_MUTEX_QUOTA
+	I_MUTEX_QUOTA,
+	I_MUTEX_RENAME_SOURCE
 };
 
 /*
