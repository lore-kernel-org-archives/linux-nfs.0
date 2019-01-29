Return-Path: <SRS0=GD9Z=QF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35652C169C4
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 07:34:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F33CB2175B
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 07:34:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725773AbfA2Hea (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Jan 2019 02:34:30 -0500
Received: from out30-131.freemail.mail.aliyun.com ([115.124.30.131]:33985 "EHLO
        out30-131.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725554AbfA2Hea (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2019 02:34:30 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=zhangliguang@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0TJC-uzl_1548747257;
Received: from localhost(mailfrom:zhangliguang@linux.alibaba.com fp:SMTPD_---0TJC-uzl_1548747257)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 29 Jan 2019 15:34:25 +0800
From:   zhangliguang <zhangliguang@linux.alibaba.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org, zhangliguang@linux.alibaba.com
Subject: [RFC v3] NFS: readdirplus optimization by cache mechanism
Date:   Tue, 29 Jan 2019 15:34:17 +0800
Message-Id: <1548747257-102749-1-git-send-email-zhangliguang@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: luanshi <zhangliguang@linux.alibaba.com>

When listing very large directories via NFS, clients may take a long
time to complete. There are about three factors involved:

First of all, ls and practically every other method of listing a
directory including python os.listdir and find rely on libc readdir().
However readdir() only reads 32K of directory entries at a time, which
means that if you have a lot of files in the same directory, it is going
to take an insanely long time to read all the directory entries.

Secondly, libc readdir() reads 32K of directory entries at a time, in
kernel space 32K buffer split into 8 pages. One NFS readdirplus rpc will
be called for one page, which introduces many readdirplus rpc calls.

Lastly, one NFS readdirplus rpc asks for 32K data (filled by nfs_dentry)
to fill one page (filled by dentry), we found that nearly one third of
data was wasted.

To solve above problems, pagecache mechanism was introduced. One NFS
readdirplus rpc will ask for a large data (more than 32k), the data can
fill more than one page, the cached pages can be used for next readdir
call. This can reduce many readdirplus rpc calls and improve readdirplus
performance.

TESTING:
When listing very large directories(include 300 thousand files) via NFS

time ls -l /nfs_mount | wc -l

without the patch:
300001
real    1m53.524s
user    0m2.314s
sys     0m2.599s

with the patch:
300001
real    0m23.487s
user    0m2.305s
sys     0m2.558s

Improved performance: 79.6%
readdirplus rpc calls decrease: 85%

Signed-off-by: Liguang Zhang <zhangliguang@linux.alibaba.com>
---
 fs/nfs/dir.c      | 90 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 fs/nfs/internal.h |  3 +-
 2 files changed, 86 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a9577b0..cd43b7a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -139,12 +139,19 @@ struct nfs_cache_array {
 	struct nfs_cache_array_entry array[0];
 };
 
+struct readdirvec {
+	unsigned long nr;
+	unsigned long index;
+	struct page *pages[NFS_MAX_READDIR_RAPAGES];
+};
+
 typedef int (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, bool);
 typedef struct {
 	struct file	*file;
 	struct page	*page;
 	struct dir_context *ctx;
 	unsigned long	page_index;
+	struct readdirvec pvec;
 	u64		*dir_cookie;
 	u64		last_cookie;
 	loff_t		current_index;
@@ -524,6 +531,10 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 	struct nfs_cache_array *array;
 	unsigned int count = 0;
 	int status;
+	int max_rapages = NFS_MAX_READDIR_RAPAGES;
+
+	desc->pvec.index = desc->page_index;
+	desc->pvec.nr = 0;
 
 	scratch = alloc_page(GFP_KERNEL);
 	if (scratch == NULL)
@@ -548,20 +559,40 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
 		if (desc->plus)
 			nfs_prime_dcache(file_dentry(desc->file), entry);
 
-		status = nfs_readdir_add_to_array(entry, page);
+		status = nfs_readdir_add_to_array(entry, desc->pvec.pages[desc->pvec.nr]);
+		if (status == -ENOSPC) {
+			desc->pvec.nr++;
+			if (desc->pvec.nr == max_rapages)
+				break;
+			status = nfs_readdir_add_to_array(entry, desc->pvec.pages[desc->pvec.nr]);
+		}
 		if (status != 0)
 			break;
 	} while (!entry->eof);
 
+	/*
+	 * page and desc->pvec.pages[0] are valid, don't need to check
+	 * whether or not to be NULL.
+	 */
+	copy_highpage(page, desc->pvec.pages[0]);
+
 out_nopages:
 	if (count == 0 || (status == -EBADCOOKIE && entry->eof != 0)) {
-		array = kmap(page);
+		array = kmap_atomic(desc->pvec.pages[desc->pvec.nr]);
 		array->eof_index = array->size;
 		status = 0;
-		kunmap(page);
+		kunmap_atomic(array);
 	}
 
 	put_page(scratch);
+
+	/*
+	 * desc->pvec.nr > 0 means at least one page was completely filled,
+	 * we should return -ENOSPC. Otherwise function
+	 * nfs_readdir_xdr_to_array will enter infinite loop.
+	 */
+	if (desc->pvec.nr > 0)
+		return -ENOSPC;
 	return status;
 }
 
@@ -595,6 +626,24 @@ int nfs_readdir_alloc_pages(struct page **pages, unsigned int npages)
 	return -ENOMEM;
 }
 
+/*
+ * nfs_readdir_rapages_init initialize rapages by nfs_cache_array structure.
+ */
+static
+void nfs_readdir_rapages_init(nfs_readdir_descriptor_t *desc)
+{
+	struct nfs_cache_array *array;
+	int max_rapages = NFS_MAX_READDIR_RAPAGES;
+	int index;
+
+	for (index = 0; index < max_rapages; index++) {
+		array = kmap_atomic(desc->pvec.pages[index]);
+		memset(array, 0, sizeof(struct nfs_cache_array));
+		array->eof_index = -1;
+		kunmap_atomic(array);
+	}
+}
+
 static
 int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page, struct inode *inode)
 {
@@ -605,6 +654,12 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	int status = -ENOMEM;
 	unsigned int array_size = ARRAY_SIZE(pages);
 
+	/*
+	 * This means we hit readdir rdpages miss, the preallocated rdpages
+	 * are useless, the preallocate rdpages should be reinitialized.
+	 */
+	nfs_readdir_rapages_init(desc);
+
 	entry.prev_cookie = 0;
 	entry.cookie = desc->last_cookie;
 	entry.eof = 0;
@@ -664,9 +719,24 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 	struct inode	*inode = file_inode(desc->file);
 	int ret;
 
-	ret = nfs_readdir_xdr_to_array(desc, page, inode);
-	if (ret < 0)
-		goto error;
+	/*
+	 * If desc->page_index in range desc->pvec.index and
+	 * desc->pvec.index + desc->pvec.nr, we get readdir cache hit.
+	 */
+	if (desc->page_index >= desc->pvec.index &&
+		desc->page_index < (desc->pvec.index + desc->pvec.nr)) {
+		/*
+		 * page and desc->pvec.pages[x] are valid, don't need to check
+		 * whether or not to be NULL.
+		 */
+		copy_highpage(page, desc->pvec.pages[desc->page_index - desc->pvec.index]);
+		ret = 0;
+	} else {
+		ret = nfs_readdir_xdr_to_array(desc, page, inode);
+		if (ret < 0)
+			goto error;
+	}
+
 	SetPageUptodate(page);
 
 	if (invalidate_inode_pages2_range(inode->i_mapping, page->index + 1, -1) < 0) {
@@ -831,6 +901,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 			*desc = &my_desc;
 	struct nfs_open_dir_context *dir_ctx = file->private_data;
 	int res = 0;
+	int max_rapages = NFS_MAX_READDIR_RAPAGES;
 
 	dfprintk(FILE, "NFS: readdir(%pD2) starting at cookie %llu\n",
 			file, (long long)ctx->pos);
@@ -850,6 +921,12 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	desc->decode = NFS_PROTO(inode)->decode_dirent;
 	desc->plus = nfs_use_readdirplus(inode, ctx);
 
+	res = nfs_readdir_alloc_pages(desc->pvec.pages, max_rapages);
+	if (res < 0)
+		return -ENOMEM;
+
+	nfs_readdir_rapages_init(desc);
+
 	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode))
 		res = nfs_revalidate_mapping(inode, file->f_mapping);
 	if (res < 0)
@@ -885,6 +962,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 			break;
 	} while (!desc->eof);
 out:
+	nfs_readdir_free_pages(desc->pvec.pages, max_rapages);
 	if (res > 0)
 		res = 0;
 	dfprintk(FILE, "NFS: readdir(%pD2) returns %d\n", file, res);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b1e5773..b4ba6f4 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -69,7 +69,8 @@ struct nfs_clone_mount {
  * Maximum number of pages that readdir can use for creating
  * a vmapped array of pages.
  */
-#define NFS_MAX_READDIR_PAGES 8
+#define NFS_MAX_READDIR_PAGES 64
+#define NFS_MAX_READDIR_RAPAGES 8
 
 struct nfs_client_initdata {
 	unsigned long init_flags;
-- 
1.8.3.1

