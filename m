Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:59381 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbaLOF1a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2014 00:27:30 -0500
Received: by mail-pd0-f169.google.com with SMTP id z10so11037200pdj.0
        for <linux-nfs@vger.kernel.org>; Sun, 14 Dec 2014 21:27:29 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH 3/8] swap: don't add ITER_BVEC flag to direct_IO rw
Date: Sun, 14 Dec 2014 21:26:57 -0800
Message-Id: <5f9e8a7dcdf08bd2dd433f1a42690ab8e67e7915.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rw argument to direct_IO has some ill-defined semantics. Some
filesystems (e.g., ext4, FAT) decide whether they're doing a write with
rw == WRITE, but others (e.g., XFS) check rw & WRITE. Let's set a good
example in the swap file code and say ITER_BVEC belongs in
iov_iter->flags but not in rw. This caters to the least common
denominator and avoids a sweeping change of every direct_IO
implementation for now.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 mm/page_io.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 1630ac0..c229f88 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -285,8 +285,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		set_page_writeback(page);
 		unlock_page(page);
 		mutex_lock(&inode->i_mutex);
-		ret = mapping->a_ops->direct_IO(ITER_BVEC | WRITE,
-						&kiocb, &from,
+		ret = mapping->a_ops->direct_IO(WRITE, &kiocb, &from,
 						kiocb.ki_pos);
 		mutex_unlock(&inode->i_mutex);
 		if (ret == PAGE_SIZE) {
-- 
2.1.3

