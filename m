From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Make ->readpages palatable to NFS
Date: 06 Nov 2002 03:25:36 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsvg3be8nz.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189Ft1-0001UD-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Nov 2002 18:25:44 -0800
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


The following patch makes the ->readpages() address_space_operation
take a struct file argument just like ->readpage().

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.46/fs/ext2/inode.c linux-2.5.46-01-readpages1/fs/ext2/inode.c
--- linux-2.5.46/fs/ext2/inode.c	2002-10-31 02:34:12.000000000 -0500
+++ linux-2.5.46-01-readpages1/fs/ext2/inode.c	2002-11-05 07:52:41.000000000 -0500
@@ -599,7 +599,7 @@
 }
 
 static int
-ext2_readpages(struct address_space *mapping,
+ext2_readpages(struct file *file, struct address_space *mapping,
 		struct list_head *pages, unsigned nr_pages)
 {
 	return mpage_readpages(mapping, pages, nr_pages, ext2_get_block);
diff -u --recursive --new-file linux-2.5.46/fs/ext3/inode.c linux-2.5.46-01-readpages1/fs/ext3/inode.c
--- linux-2.5.46/fs/ext3/inode.c	2002-10-31 02:32:56.000000000 -0500
+++ linux-2.5.46-01-readpages1/fs/ext3/inode.c	2002-11-05 07:52:41.000000000 -0500
@@ -1385,7 +1385,7 @@
 }
 
 static int
-ext3_readpages(struct address_space *mapping,
+ext3_readpages(struct file *file, struct address_space *mapping,
 		struct list_head *pages, unsigned nr_pages)
 {
 	return mpage_readpages(mapping, pages, nr_pages, ext3_get_block);
diff -u --recursive --new-file linux-2.5.46/fs/jfs/inode.c linux-2.5.46-01-readpages1/fs/jfs/inode.c
--- linux-2.5.46/fs/jfs/inode.c	2002-10-28 12:48:59.000000000 -0500
+++ linux-2.5.46-01-readpages1/fs/jfs/inode.c	2002-11-05 07:52:41.000000000 -0500
@@ -293,7 +293,7 @@
 	return mpage_readpage(page, jfs_get_block);
 }
 
-static int jfs_readpages(struct address_space *mapping,
+static int jfs_readpages(struct file *file, struct address_space *mapping,
 		struct list_head *pages, unsigned nr_pages)
 {
 	return mpage_readpages(mapping, pages, nr_pages, jfs_get_block);
diff -u --recursive --new-file linux-2.5.46/fs/xfs/linux/xfs_aops.c linux-2.5.46-01-readpages1/fs/xfs/linux/xfs_aops.c
--- linux-2.5.46/fs/xfs/linux/xfs_aops.c	2002-10-28 12:48:59.000000000 -0500
+++ linux-2.5.46-01-readpages1/fs/xfs/linux/xfs_aops.c	2002-11-05 07:52:41.000000000 -0500
@@ -644,6 +644,7 @@
 
 STATIC int
 linvfs_readpages(
+	struct file		*unused,
 	struct address_space	*mapping,
 	struct list_head	*pages,
 	unsigned		nr_pages)
diff -u --recursive --new-file linux-2.5.46/include/linux/fs.h linux-2.5.46-01-readpages1/include/linux/fs.h
--- linux-2.5.46/include/linux/fs.h	2002-11-03 14:49:39.000000000 -0500
+++ linux-2.5.46-01-readpages1/include/linux/fs.h	2002-11-05 07:52:41.000000000 -0500
@@ -297,7 +297,7 @@
 	/* Set a page dirty */
 	int (*set_page_dirty)(struct page *page);
 
-	int (*readpages)(struct address_space *mapping,
+	int (*readpages)(struct file *filp, struct address_space *mapping,
 			struct list_head *pages, unsigned nr_pages);
 
 	/*
diff -u --recursive --new-file linux-2.5.46/mm/readahead.c linux-2.5.46-01-readpages1/mm/readahead.c
--- linux-2.5.46/mm/readahead.c	2002-10-29 19:59:58.000000000 -0500
+++ linux-2.5.46-01-readpages1/mm/readahead.c	2002-11-05 07:52:41.000000000 -0500
@@ -52,7 +52,7 @@
 	pagevec_init(&lru_pvec, 0);
 
 	if (mapping->a_ops->readpages)
-		return mapping->a_ops->readpages(mapping, pages, nr_pages);
+		return mapping->a_ops->readpages(filp, mapping, pages, nr_pages);
 
 	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
 		struct page *page = list_entry(pages->prev, struct page, list);


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
