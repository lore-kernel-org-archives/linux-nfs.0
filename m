Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:53933 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaLOF12 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2014 00:27:28 -0500
Received: by mail-pa0-f43.google.com with SMTP id kx10so11097383pab.16
        for <linux-nfs@vger.kernel.org>; Sun, 14 Dec 2014 21:27:27 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Date: Sun, 14 Dec 2014 21:26:56 -0800
Message-Id: <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The generic write code locks i_mutex for a direct_IO. Swap-over-NFS
doesn't grab the mutex because nfs_direct_IO doesn't expect i_mutex to
be held, but most direct_IO implementations do.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 mm/page_io.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_io.c b/mm/page_io.c
index 955db8b..1630ac0 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -263,6 +263,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	if (sis->flags & SWP_FILE) {
 		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
+		struct inode *inode = file_inode(swap_file);
 		struct address_space *mapping = swap_file->f_mapping;
 		struct bio_vec bv = {
 			.bv_page = page,
@@ -283,9 +284,11 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 
 		set_page_writeback(page);
 		unlock_page(page);
+		mutex_lock(&inode->i_mutex);
 		ret = mapping->a_ops->direct_IO(ITER_BVEC | WRITE,
 						&kiocb, &from,
 						kiocb.ki_pos);
+		mutex_unlock(&inode->i_mutex);
 		if (ret == PAGE_SIZE) {
 			count_vm_event(PSWPOUT);
 			ret = 0;
-- 
2.1.3

