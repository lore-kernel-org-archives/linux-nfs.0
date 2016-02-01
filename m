Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34610 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933239AbcBABjn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jan 2016 20:39:43 -0500
Received: by mail-pa0-f68.google.com with SMTP id yy13so6461114pab.1
        for <linux-nfs@vger.kernel.org>; Sun, 31 Jan 2016 17:39:43 -0800 (PST)
Subject: [PATCH v2] pnfs/blocklayout: fix a memeory leak when
 using,vmalloc_to_page
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <201601312118.eeYQZfII%fengguang.wu@intel.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <56AEB751.9010201@gmail.com>
Date: Mon, 1 Feb 2016 09:39:29 +0800
MIME-Version: 1.0
In-Reply-To: <201601312118.eeYQZfII%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

unreferenced object 0xffffc90000abf000 (size 16900):
  comm "fsync02", pid 15765, jiffies 4297431627 (age 423.772s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 a0 c2 19 00 88 ff ff  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8174d54e>] kmemleak_alloc+0x4e/0xb0
    [<ffffffff811b9b91>] __vmalloc_node_range+0x231/0x280
    [<ffffffff811b9c2a>] __vmalloc+0x4a/0x50
    [<ffffffffa02c9ec1>] ext_tree_prepare_commit+0x231/0x2e0 [blocklayoutdriver]
    [<ffffffffa02c700e>] bl_prepare_layoutcommit+0xe/0x10 [blocklayoutdriver]
    [<ffffffffa0596a6c>] pnfs_layoutcommit_inode+0x29c/0x330 [nfsv4]
    [<ffffffffa0596b13>] pnfs_generic_sync+0x13/0x20 [nfsv4]
    [<ffffffffa0585188>] nfs4_file_fsync+0x58/0x150 [nfsv4]
    [<ffffffff81228e5b>] vfs_fsync_range+0x4b/0xb0
    [<ffffffff81228f1d>] do_fsync+0x3d/0x70
    [<ffffffff812291d0>] SyS_fsync+0x10/0x20
    [<ffffffff81757def>] entry_SYSCALL_64_fastpath+0x12/0x76
    [<ffffffffffffffff>] 0xffffffffffffffff

v2, add missing include header

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/blocklayout/extent_tree.c | 10 ++++++++--
 include/linux/nfs_xdr.h          |  1 +
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index c59a59c..35ab51c 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -476,6 +476,7 @@ static void ext_tree_free_commitdata(struct nfs4_layoutcommit_args *arg,
 
 		for (i = 0; i < nr_pages; i++)
 			put_page(arg->layoutupdate_pages[i]);
+		vfree(arg->start_p);
 		kfree(arg->layoutupdate_pages);
 	} else {
 		put_page(arg->layoutupdate_page);
@@ -559,10 +560,15 @@ retry:
 
 	if (unlikely(arg->layoutupdate_pages != &arg->layoutupdate_page)) {
 		void *p = start_p, *end = p + arg->layoutupdate_len;
+		struct page *page = NULL;
 		int i = 0;
 
-		for ( ; p < end; p += PAGE_SIZE)
-			arg->layoutupdate_pages[i++] = vmalloc_to_page(p);
+		arg->start_p = start_p;
+		for ( ; p < end; p += PAGE_SIZE) {
+			page = vmalloc_to_page(p);
+			arg->layoutupdate_pages[i++] = page;
+			get_page(page);
+		}
 	}
 
 	dprintk("%s found %zu ranges\n", __func__, count);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 791098a..d320906 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -275,6 +275,7 @@ struct nfs4_layoutcommit_args {
 	size_t layoutupdate_len;
 	struct page *layoutupdate_page;
 	struct page **layoutupdate_pages;
+	__be32 *start_p;
 };
 
 struct nfs4_layoutcommit_res {
-- 
2.5.0

