From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 27/32] NFS: read-modify-write page updating
Date: Wed, 19 Aug 2009 19:38:50 -0400
Message-ID: <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Peter Staubach <staubach@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754097AbZHSXkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:55 -0400
In-Reply-To: <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peter Staubach <staubach@redhat.com>

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

The difference between this patch and the previous one was
to remove the unneeded PageDirty() test.  I then retested to
ensure that the resulting system continued to behave as
desired.

	Thanx...

		ps

Signed-off-by: Peter Staubach <staubach@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index dfc8967..5021b75 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -328,6 +328,42 @@ nfs_file_fsync(struct file *file, struct dentry *dentry, int datasync)
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
+ * as Uptodate, it is not dirty or waiting to be committed,
+ * indicating that it was previously allocated and then modified,
+ * that there were valid bytes of data in that range of the file,
+ * and that the new data won't completely replace the old data in
+ * that range of the file.
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
@@ -340,15 +376,16 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
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
@@ -367,6 +404,13 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
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
-- 
1.6.0.4
