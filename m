Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f53.google.com ([209.85.220.53]:50212 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062AbaLJBqm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Dec 2014 20:46:42 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so1733320pab.12
        for <linux-nfs@vger.kernel.org>; Tue, 09 Dec 2014 17:46:41 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>, Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH v3 3/7] swap: use direct I/O for SWP_FILE swap_readpage
Date: Tue,  9 Dec 2014 17:45:44 -0800
Message-Id: <9c1d4746d1e7e41114496be8912cb74e36d5df48.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 17, 2014 at 07:48:17AM -0800, Christoph Hellwig wrote:
> With the new iov_iter infrastructure that supprots direct I/O to kernel
> pages please get rid of the ->readpage hack first.  I'm still utterly
> disapoined that this crap ever got merged.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 mm/page_io.c | 32 ++++++++++++++++++++++++++++----
 1 file changed, 28 insertions(+), 4 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 955db8b..10715e0 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -283,8 +283,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 
 		set_page_writeback(page);
 		unlock_page(page);
-		ret = mapping->a_ops->direct_IO(ITER_BVEC | WRITE,
-						&kiocb, &from,
+		ret = mapping->a_ops->direct_IO(WRITE, &kiocb, &from,
 						kiocb.ki_pos);
 		if (ret == PAGE_SIZE) {
 			count_vm_event(PSWPOUT);
@@ -348,12 +347,37 @@ int swap_readpage(struct page *page)
 	}
 
 	if (sis->flags & SWP_FILE) {
+		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
 		struct address_space *mapping = swap_file->f_mapping;
+		struct bio_vec bv = {
+			.bv_page = page,
+			.bv_len = PAGE_SIZE,
+			.bv_offset = 0,
+		};
+		struct iov_iter to = {
+			.type = ITER_BVEC | READ,
+			.count = PAGE_SIZE,
+			.iov_offset = 0,
+			.nr_segs = 1,
+		};
+		to.bvec = &bv;	/* older gcc versions are broken */
+
+		init_sync_kiocb(&kiocb, swap_file);
+		kiocb.ki_pos = page_file_offset(page);
+		kiocb.ki_nbytes = PAGE_SIZE;
 
-		ret = mapping->a_ops->readpage(swap_file, page);
-		if (!ret)
+		ret = mapping->a_ops->direct_IO(READ, &kiocb, &to,
+						kiocb.ki_pos);
+		if (ret == PAGE_SIZE) {
+			SetPageUptodate(page);
 			count_vm_event(PSWPIN);
+			ret = 0;
+		} else {
+			ClearPageUptodate(page);
+			SetPageError(page);
+		}
+		unlock_page(page);
 		return ret;
 	}
 
-- 
2.1.3

