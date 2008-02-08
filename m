From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull 2 NFS client fixes
Date: Thu, 07 Feb 2008 20:07:21 -0500
Message-ID: <1202432841.18376.50.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44777 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753986AbYBHBHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 20:07:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "master" branch of the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/Kconfig     |    7 ++-----
 fs/nfs/write.c |   20 +++++++++++++++++---
 2 files changed, 19 insertions(+), 8 deletions(-)

commit 3211e4eb5834924dd5beac8956c0bc0bfb755c37
Author: James Lentini <jlentini@netapp.com>
Date:   Mon Jan 28 12:09:28 2008 -0500

    SUNRPC xptrdma: simplify build configuration
    
    
    Trond and Bruce,
    
    This is a patch for 2.6.25. This is the same version that was sent out
    on December 12 for review (no comments to date).
    
    To simplify the RPC/RDMA client and server build configuration, make
    SUNRPC_XPRT_RDMA a hidden config option that continues to depend on
    SUNRPC and INFINIBAND. The value of SUNRPC_XPRT_RDMA will be:
    
     - N if either SUNRPC or INFINIBAND are N
     - M if both SUNRPC and INFINIBAND are on (M or Y) and at least one is M
     - Y if both SUNRPC and INFINIBAND are Y
    
    In 2.6.25, all of the RPC/RDMA related files are grouped in
    net/sunrpc/xprtrdma and the net/sunrpc/xprtrdma/Makefile builds both
    the client and server RPC/RDMA support using this config option.
    
    Signed-off-by: James Lentini <jlentini@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5d47a35600270e7115061cb1320ee60ae9bcb6b8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Feb 7 17:24:07 2008 -0500

    NFS: Fix a potential file corruption issue when writing
    
    If the inode is flagged as having an invalid mapping, then we can't rely on
    the PageUptodate() flag. Ensure that we don't use the "anti-fragmentation"
    write optimisation in nfs_updatepage(), since that will cause NFS to write
    out areas of the page that are no longer guaranteed to be up to date.
    
    A potential corruption could occur in the following scenario:
    
    client 1			client 2
    ===============			===============
    				fd=open("f",O_CREAT|O_WRONLY,0644);
    				write(fd,"fubar\n",6);	// cache last page
    				close(fd);
    fd=open("f",O_WRONLY|O_APPEND);
    write(fd,"foo\n",4);
    close(fd);
    
    				fd=open("f",O_WRONLY|O_APPEND);
    				write(fd,"bar\n",4);
    				close(fd);
    -----
    The bug may lead to the file "f" reading 'fubar\n\0\0\0\nbar\n' because
    client 2 does not update the cached page after re-opening the file for
    write. Instead it keeps it marked as PageUptodate() until someone calls
    invaldate_inode_pages2() (typically by calling read()).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/Kconfig b/fs/Kconfig
index 3bf6ace..d731282 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1778,12 +1778,9 @@ config SUNRPC_GSS
 	tristate
 
 config SUNRPC_XPRT_RDMA
-	tristate "RDMA transport for sunrpc (EXPERIMENTAL)"
+	tristate
 	depends on SUNRPC && INFINIBAND && EXPERIMENTAL
-	default m
-	help
-	  Adds a client RPC transport for supporting kernel NFS over RDMA
-	  mounts, including Infiniband and iWARP. Experimental.
+	default SUNRPC && INFINIBAND
 
 config SUNRPC_BIND34
 	bool "Support for rpcbind versions 3 & 4 (EXPERIMENTAL)"
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b144b19..f55c437 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -697,6 +697,17 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 }
 
 /*
+ * If the page cache is marked as unsafe or invalid, then we can't rely on
+ * the PageUptodate() flag. In this case, we will need to turn off
+ * write optimisations that depend on the page contents being correct.
+ */
+static int nfs_write_pageuptodate(struct page *page, struct inode *inode)
+{
+	return PageUptodate(page) &&
+		!(NFS_I(inode)->cache_validity & (NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_DATA));
+}
+
+/*
  * Update and possibly write a cached page of an NFS file.
  *
  * XXX: Keep an eye on generic_file_read to make sure it doesn't do bad
@@ -717,10 +728,13 @@ int nfs_updatepage(struct file *file, struct page *page,
 		(long long)(page_offset(page) +offset));
 
 	/* If we're not using byte range locks, and we know the page
-	 * is entirely in cache, it may be more efficient to avoid
-	 * fragmenting write requests.
+	 * is up to date, it may be more efficient to extend the write
+	 * to cover the entire page in order to avoid fragmentation
+	 * inefficiencies.
 	 */
-	if (PageUptodate(page) && inode->i_flock == NULL && !(file->f_mode & O_SYNC)) {
+	if (nfs_write_pageuptodate(page, inode) &&
+			inode->i_flock == NULL &&
+			!(file->f_mode & O_SYNC)) {
 		count = max(count + offset, nfs_page_length(page));
 		offset = 0;
 	}
