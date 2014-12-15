Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:58621 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbaLOF1j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2014 00:27:39 -0500
Received: by mail-pd0-f180.google.com with SMTP id w10so10964026pde.11
        for <linux-nfs@vger.kernel.org>; Sun, 14 Dec 2014 21:27:38 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH 7/8] swap: use direct I/O for SWP_FILE swap_readpage
Date: Sun, 14 Dec 2014 21:27:01 -0800
Message-Id: <d3fed803654ace449a61aefb37792ae5647e1cf3.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 17, 2014 at 07:48:17AM -0800, Christoph Hellwig wrote:
> With the new iov_iter infrastructure that supprots direct I/O to kernel
> pages please get rid of the ->readpage hack first.  I'm still utterly
> disapoined that this crap ever got merged.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 mm/page_io.c | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 4741248..956307c 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -346,12 +346,33 @@ int swap_readpage(struct page *page)
 	}
 
 	if (sis->flags & SWP_FILE) {
+		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
 		struct address_space *mapping = swap_file->f_mapping;
+		struct iov_iter to;
+		struct bio_vec bv = {
+			.bv_page = page,
+			.bv_len = PAGE_SIZE,
+			.bv_offset = 0,
+		};
+
+		iov_iter_bvec(&to, ITER_BVEC | READ, &bv, 1, PAGE_SIZE);
 
-		ret = mapping->a_ops->readpage(swap_file, page);
-		if (!ret)
+		init_sync_kiocb(&kiocb, swap_file);
+		kiocb.ki_pos = page_file_offset(page);
+		kiocb.ki_nbytes = PAGE_SIZE;
+
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

