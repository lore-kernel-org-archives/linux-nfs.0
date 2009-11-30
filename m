From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Client cache updates missing? (2.6.31.5)
Date: Mon, 30 Nov 2009 13:40:35 -0500
Message-ID: <20091130184035.GD6348@fieldses.org>
References: <4B122FB2.7040505@krogh.cc> <20091130182643.GB6348@fieldses.org> <4B140F5F.6050107@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53685 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752722AbZK3Sjf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2009 13:39:35 -0500
In-Reply-To: <4B140F5F.6050107-Q2TZfHgGEy4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 30, 2009 at 07:30:55PM +0100, Jesper Krogh wrote:
> J. Bruce Fields wrote:
> >> Wether or not it has anything to do. The file has been written to the
> >> NFS-server from another NFS-client. The server is running 2.6.31.5 and
> >> the client that above was run on is 2.6.24-24 (Ubuntu Jaunty), the
> >> client that wrote the file was running 2.6.29.1.
> > 
> > I this v3 or v4?  What's the exported filesystem?  (ext3?)
> 
> v3 and ext3
> 
> > It's probably a timestamp resolution problem; if the directory was
> > modified twice in the same second, the later change won't change the
> > timestamp, and so the client may assume its cache is still good.
> 
> That's not nice..  but given the situation is may quite well be the
> problem.
> 
> > Recent clients try a little harder to work around this. 
> 
> How recent and how much harder?

There's the following.  Looks like it was first included in 2.6.30.  I
thought I remembered one or two other related changes, but perhaps the
others didn't make it in.

--b.

commit 37d9d76d8b3a2ac5817e1fa3263cfe0fdb439e51
Author: NeilBrown <neilb@suse.de>
Date:   Wed Mar 11 14:10:23 2009 -0400

    NFS: flush cached directory information slightly more readily.
    
    If cached directory contents becomes incorrect, there is no way to
    flush the contents.  This contrasts with files where file locking is
    the recommended way to ensure cache consistency between multiple
    applications (a read-lock always flushes the cache).
    
    Also while changes to files often change the size of the file (thus
    triggering a cache flush), changes to directories often do not change
    the apparent size (as the size is often rounded to a block size).
    
    So it is particularly important with directories to avoid the
    possibility of an incorrect cache wherever possible.
    
    When the link count on a directory changes it implies a change in the
    number of child directories, and so a change in the contents of this
    directory.  So use that as a trigger to flush cached contents.
    
    When the ctime changes but the mtime does not, there are two possible
    reasons.
     1/ The owner/mode information has been changed.
     2/ utimes has been used to set the mtime backwards.
    
    In the first case, a data-cache flush is not required.
    In the second case it is.
    
    So on the basis that correctness trumps performance, flush the
    directory contents cache in this case also.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index acaaa7c..268ce3a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1113,8 +1113,16 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				nfs_force_lookup_revalidate(inode);
 		}
 		/* If ctime has changed we should definitely clear access+acl caches */
-		if (!timespec_equal(&inode->i_ctime, &fattr->ctime))
+		if (!timespec_equal(&inode->i_ctime, &fattr->ctime)) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+			/* and probably clear data for a directory too as utimes can cause
+			 * havoc with our cache.
+			 */
+			if (S_ISDIR(inode->i_mode)) {
+				invalid |= NFS_INO_INVALID_DATA;
+				nfs_force_lookup_revalidate(inode);
+			}
+		}
 	} else if (nfsi->change_attr != fattr->change_attr) {
 		dprintk("NFS: change_attr change on server for file %s/%ld\n",
 				inode->i_sb->s_id, inode->i_ino);
@@ -1148,8 +1156,11 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	    inode->i_gid != fattr->gid)
 		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 
-	if (inode->i_nlink != fattr->nlink)
+	if (inode->i_nlink != fattr->nlink) {
 		invalid |= NFS_INO_INVALID_ATTR;
+		if (S_ISDIR(inode->i_mode))
+			invalid |= NFS_INO_INVALID_DATA;
+	}
 
 	inode->i_mode = fattr->mode;
 	inode->i_nlink = fattr->nlink;
