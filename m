Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53712 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759207AbZGIOM3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jul 2009 10:12:29 -0400
Message-ID: <4A55FAC8.5040309@redhat.com>
Date: Thu, 09 Jul 2009 10:12:24 -0400
From: Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Brian R Cowan <brcowan@us.ibm.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2] read-modify-write page updating
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <49FA0CE8.9090706@redhat.com>	 <1241126587.15476.62.camel@heimdal.trondhjem.org>	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>	 <1243615595.7155.48.camel@heimdal.trondhjem.org>	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>	 <1243618500.7155.56.camel@heimdal.trondhjem.org>	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>	 <1243686363.5209.16.camel@heimdal.trondhjem.org>	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>	 <1243963631.4868.124.camel@heimdal.trondhjem.org>	 <18982.41770.293636.786518@fisica.ufpr.br>	 <1244049027.5603.5.camel@heimdal.trondhjem.org>	 <OFB53BFCCB.0CEC7A7E-ON852575CA.006BA196-852575CB.00613ABC@us.ibm.com> <1244138698.5203.59.camel@heimdal.trondhjem.org> <4A428482.60403@redhat.com>
In-Reply-To: <4A428482.60403@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------080409010305010204050802"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------080409010305010204050802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

I have a proposal for possibly resolving this issue.

I believe that this situation occurs due to the way that the
Linux NFS client handles writes which modify partial pages.

The Linux NFS client handles partial page modifications by
allocating a page from the page cache, copying the data from
the user level into the page, and then keeping track of the
offset and length of the modified portions of the page.  The
page is not marked as up to date because there are portions
of the page which do not contain valid file contents.

When a read call comes in for a portion of the page, the
contents of the page must be read in the from the server.
However, since the page may already contain some modified
data, that modified data must be written to the server
before the file contents can be read back in the from server.
And, since the writing and reading can not be done atomically,
the data must be written and committed to stable storage on
the server for safety purposes.  This means either a
FILE_SYNC WRITE or a UNSTABLE WRITE followed by a COMMIT.
This has been discussed at length previously.

This algorithm could be described as modify-write-read.  It
is most efficient when the application only updates pages
and does not read them.

My proposed solution is to add a heuristic to decide whether
to do this modify-write-read algorithm or switch to a read-
modify-write algorithm when initially allocating the page
in the write system call path.  The heuristic uses the modes
that the file was opened with, the offset in the page to
read from, and the size of the region to read.

If the file was opened for reading in addition to writing
and the page would not be filled completely with data from
the user level, then read in the old contents of the page
and mark it as Uptodate before copying in the new data.  If
the page would be completely filled with data from the user
level, then there would be no reason to read in the old
contents because they would just be copied over.

This would optimize for applications which randomly access
and update portions of files.  The linkage editor for the
C compiler is an example of such a thing.

I tested the attached patch by using rpmbuild to build the
current Fedora rawhide kernel.  The kernel without the
patch generated about 269,500 WRITE requests.  The modified
kernel containing the patch generated about 261,000 WRITE
requests.  Thus, about 8,500 fewer WRITE requests were
generated.  I suspect that many of these additional
WRITE requests were probably FILE_SYNC requests to WRITE
a single page, but I didn't test this theory.

The previous version of this patch caused the NFS client to
generate around 3,000 more READ requests.  This version
actually causes the NFS client to generate almost 500 fewer
READ requests.

    Thanx...

       ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------080409010305010204050802
Content-Type: application/x-troff-man;
 name="read-modify-write.devel.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="read-modify-write.devel.2"

--- linux-2.6.30.i686/fs/nfs/file.c.org
+++ linux-2.6.30.i686/fs/nfs/file.c
@@ -329,6 +329,42 @@ nfs_file_fsync(struct file *file, struct
 }
 
 /*
+ * Decide whether a read/modify/write cycle may be more efficient
+ * then a modify/write/read cycle when writing to a page in the
+ * page cache.
+ *
+ * The modify/write/read cycle may occur if a page is read before
+ * being completely filled by the writer.  In this situation, the
+ * page must be completely written to stable storage on the server
+ * before it can be refilled by reading in the page from the server.
+ * This can lead to expensive, small, FILE_SYNC mode writes being
+ * done.
+ *
+ * It may be more efficient to read the page first if the file is
+ * open for reading in addition to writing, the page is not marked
+ * as Uptodate, it is not dirty, indicating that it was previously
+ * allocated and then modified, that there were valid bytes of
+ * data in that range of the file, and that the new data won't
+ * completely replace the old data in that range of the file.
+ */
+static int nfs_want_read_modify_write(struct file *file, struct page *page,
+			loff_t pos, unsigned len)
+{
+	unsigned int pglen = nfs_page_length(page);
+	unsigned int offset = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned int end = offset + len;
+
+	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
+	    !PageUptodate(page) &&		/* Uptodate? */
+	    !PageDirty(page) &&			/* Dirty already? */
+	    !PagePrivate(page) &&		/* i/o request already? */
+	    pglen &&				/* valid bytes of file? */
+	    (end < pglen || offset))		/* replace all valid bytes? */
+		return 1;
+	return 0;
+}
+
+/*
  * This does the "real" work of the write. We must allocate and lock the
  * page to be sent back to the generic routine, which then copies the
  * data from user space.
@@ -341,15 +377,16 @@ static int nfs_write_begin(struct file *
 			struct page **pagep, void **fsdata)
 {
 	int ret;
-	pgoff_t index;
+	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 	struct page *page;
-	index = pos >> PAGE_CACHE_SHIFT;
+	int once_thru = 0;
 
 	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
+start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
 	 * sync-to-disk
@@ -368,6 +405,13 @@ static int nfs_write_begin(struct file *
 	if (ret) {
 		unlock_page(page);
 		page_cache_release(page);
+	} else if (!once_thru &&
+		   nfs_want_read_modify_write(file, page, pos, len)) {
+		once_thru = 1;
+		ret = nfs_readpage(file, page);
+		page_cache_release(page);
+		if (!ret)
+			goto start;
 	}
 	return ret;
 }

--------------080409010305010204050802--
