Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38462 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbZFXTyq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:54:46 -0400
Message-ID: <4A428482.60403@redhat.com>
Date: Wed, 24 Jun 2009 15:54:42 -0400
From: Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Brian R Cowan <brcowan@us.ibm.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] read-modify-write page updating
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <49FA0CE8.9090706@redhat.com>	 <1241126587.15476.62.camel@heimdal.trondhjem.org>	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>	 <1243615595.7155.48.camel@heimdal.trondhjem.org>	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>	 <1243618500.7155.56.camel@heimdal.trondhjem.org>	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>	 <1243686363.5209.16.camel@heimdal.trondhjem.org>	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>	 <1243963631.4868.124.camel@heimdal.trondhjem.org>	 <18982.41770.293636.786518@fisica.ufpr.br>	 <1244049027.5603.5.camel@heimdal.trondhjem.org>	 <OFB53BFCCB.0CEC7A7E-ON852575CA.006BA196-852575CB.00613ABC@us.ibm.com> <1244138698.5203.59.camel@heimdal.trondhjem.org>
In-Reply-To: <1244138698.5203.59.camel@heimdal.trondhjem.org>
Content-Type: multipart/mixed;
 boundary="------------080700050109040206070504"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------080700050109040206070504
Content-Type: text/plain; charset=ISO-8859-1
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
patch generated about 153,000 READ requests and 265,500
WRITE requests.  The modified kernel containing the patch
generated about 156,000 READ requests and 257,000 WRITE
requests.  Thus, about 3,000 more READ requests were
generated, but about 8,500 fewer WRITE requests were
generated.  I suspect that many of these additional
WRITE requests were probably FILE_SYNC requests to WRITE
a single page, but I didn't test this theory.

    Thanx...

       ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------080700050109040206070504
Content-Type: text/plain;
 name="read-modify-write.devel"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="read-modify-write.devel"

--- linux-2.6.30.i686/fs/nfs/file.c.org
+++ linux-2.6.30.i686/fs/nfs/file.c
@@ -337,15 +337,15 @@ static int nfs_write_begin(struct file *
 			struct page **pagep, void **fsdata)
 {
 	int ret;
-	pgoff_t index;
+	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 	struct page *page;
-	index = pos >> PAGE_CACHE_SHIFT;
 
 	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
+start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
 	 * sync-to-disk
@@ -364,6 +364,12 @@ static int nfs_write_begin(struct file *
 	if (ret) {
 		unlock_page(page);
 		page_cache_release(page);
+	} else if ((file->f_mode & FMODE_READ) && !PageUptodate(page) &&
+		   ((pos & (PAGE_CACHE_SIZE - 1)) || len != PAGE_CACHE_SIZE)) {
+		ret = nfs_readpage(file, page);
+		page_cache_release(page);
+		if (!ret)
+			goto start;
 	}
 	return ret;
 }

--------------080700050109040206070504--
