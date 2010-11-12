Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49806 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810Ab0KLSnz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 13:43:55 -0500
Date: Fri, 12 Nov 2010 13:43:54 -0500
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: lifetime of DCACHE_DISCONECTED dentries
Message-ID: <20101112184353.GA32745@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

DCACHE_DISCONECTED dentries aren't always getting destroyed as soon as
I'd have expected in the NFSv4 case.

I'm not sure what the right fix is; any ideas?  The below at least
demonstrates the problem.

--b.

commit bb125ffbe5fc3f80ac7a5b20f51cc542c175cd49
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Nov 11 19:22:00 2010 -0500

    dput: free DCACHE_DISCONNECTED dentries sooner
    
    DCACHE_DISCONECTED dentries are normally left around for the benefit of
    future nfsd operations.  But there's no point keeping them around once
    the inode has been deleted.
    
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
    tail -f.  On-disk data won't be deallocated either, leading to possible
    spurious ENOSPC.
    
    This occurs because when the client does the close, it arrives in a
    compound with a putfh and a close, processed like:
    
    	- putfh: look up the filehandle.  The only alias found for the
    	  inode will be DCACHE_UNHASHED alias referenced by the filp
    	  associated with the nfsd open.  d_obtain_alias() doesn't like
    	  this, so it creates a new DCACHE_DISCONECTED dentry and
    	  returns that instead.
    	- close: closes the existing filp, which is destroyed
    	  immediately by dput() since it's DCACHE_UNHASHED.
    	- end of the compound: release the reference to the current
    	  filehandle, and dput() the new DCACHE_DISCONECTED dentry,
    	  which gets put on the unused list instead of being destroyed
    	  immediately.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/dcache.c b/fs/dcache.c
index 28fa7e5..5132f13 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -241,6 +241,10 @@ repeat:
 	/* Unreachable? Get rid of it */
  	if (d_unhashed(dentry))
 		goto kill_it;
+	if (dentry->d_flags & DCACHE_DISCONNECTED
+	    && dentry->d_inode
+	    && dentry->d_inode->i_nlink == 0)
+		goto kill_it;
   	if (list_empty(&dentry->d_lru)) {
   		dentry->d_flags |= DCACHE_REFERENCED;
 		dentry_lru_add(dentry);
