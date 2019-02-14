Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FE18C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 09:39:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D00B2229F
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 09:39:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387778AbfBNJjl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 04:39:41 -0500
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:52757 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2406202AbfBNJjk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2019 04:39:40 -0500
Received: from vc1.ecl.ntt.co.jp (vc1.ecl.ntt.co.jp [129.60.86.153])
        by tama50.ecl.ntt.co.jp (8.13.8/8.13.8) with ESMTP id x1E9dEAK024571;
        Thu, 14 Feb 2019 18:39:14 +0900
Received: from vc1.ecl.ntt.co.jp (localhost [127.0.0.1])
        by vc1.ecl.ntt.co.jp (Postfix) with ESMTP id 05F0AEA7DDB;
        Thu, 14 Feb 2019 18:39:14 +0900 (JST)
Received: from jcms-pop11.ecl.ntt.co.jp (jcms-pop11.ecl.ntt.co.jp [129.60.87.132])
        by vc1.ecl.ntt.co.jp (Postfix) with ESMTP id EF45CEA7DD5;
        Thu, 14 Feb 2019 18:39:13 +0900 (JST)
Received: from [IPv6:::1] (unknown [129.60.241.209])
        by jcms-pop11.ecl.ntt.co.jp (Postfix) with ESMTPSA id E81AE70C038B;
        Thu, 14 Feb 2019 18:39:13 +0900 (JST)
From:   Kazuo Ito <ito_kazuo_g3@lab.ntt.co.jp>
Subject: [PATCH v2 2/2] pNFS: Avoid read/modify/write when it is not necessary
Message-ID: <94577467-ccc5-1957-e4ce-e93b4fd68245@lab.ntt.co.jp>
Date:   Thu, 14 Feb 2019 18:39:03 +0900
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CC-Mail-RelayStamp: 1
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org, konishi.ryusuke@lab.ntt.co.jp,
        =?UTF-8?B?T1PmuKHovro=?= <watanabe.hiroyuki@lab.ntt.co.jp>
X-TM-AS-MML: disable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

As the block and SCSI layouts can only read/write fixed-length
blocks, we must perform read-modify-write when data to be written is
not aligned to a block boundary or smaller than the block size.
(612aa983a0410 pnfs: add flag to force read-modify-write in ->write_begin)

The current code tries to see if we have to do read-modify-write
on block-oriented pNFS layouts by just checking !PageUptodate(page),
but the same condition also applies for overwriting of any uncached
potions of existing files, making such operations excessively slow
even it is block-aligned.

The change does not affect the optimization for modify-write-read
cases (38c73044f5f4d NFS: read-modify-write page updating),
because partial update of !PageUptodate() pages can only happen
in layouts that can do arbitrary length read/write and never
in block-based ones.

Testing results:

We ran fio on one of the pNFS clients running 4.20 kernel
(vanilla and patched) in this configuration to read/write/overwrite
files on the storage array, exported as pnfs share by the server.

 pNFS clients ---1G Ethernet--- pNFS server
 (HP DL360 G8)                  (HP DL360 G8)
       |                              |
       |                              |
       +------8G Fiber Channel--------+
                     |
               Storage Array
                 (HP P6350)

Throughput of overwrite (both buffered and O_SYNC) is noticeably
improved.

Ops.     |block size|   Throughput   |
         |  (KiB)   |    (MiB/s)     |
         |          |  4.20 | patched|
---------+----------+----------------+
buffered |         4|  21.3 |  232   |
overwrite|        32|  22.2 |  256   |
         |       512|  22.4 |  260   |
---------+----------+----------------+
O_SYNC   |         4|   3.84|    4.77|
overwrite|        32|  12.2 |   32.0 |
         |       512|  18.5 |  152   |
---------+----------+----------------+

Read and write (buffered and O_SYNC) by the same client remain unchanged
by the patch either negatively or positively, as they should do.

Ops.     |block size|   Throughput   |
         |  (KiB)   |    (MiB/s)     |
         |          |  4.20 | patched|
---------+----------+----------------+
read     |         4| 548   |  550   |
         |        32| 547   |  551   |
         |       512| 548   |  551   |
---------+----------+----------------+
buffered |         4| 237   |  244   |
write    |        32| 261   |  268   |
         |       512| 265   |  272   |
---------+----------+----------------+
O_SYNC   |         4|   0.46|    0.46|
write    |        32|   3.60|    3.57|
         |       512| 105   |  106   |
---------+----------+----------------+

Signed-off-by: Kazuo Ito <ito_kazuo_g3@lab.ntt.co.jp>
Tested-by: Hiroyuki Watanabe <watanabe.hiroyuki@lab.ntt.co.jp>
---
 fs/nfs/file.c | 40 ++++++++++++++++++++++++++--------------
 1 file changed, 26 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d8f25b1ae233..275f35a7a62d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -276,6 +276,12 @@ EXPORT_SYMBOL_GPL(nfs_file_fsync);
  * then a modify/write/read cycle when writing to a page in the
  * page cache.
  *
+ * Some pNFS layout drivers can only read/write at a certain block
+ * granularity like all block devices and therefore we must perform
+ * read/modify/write whenever a page hasn't read yet and the data
+ * to be written there is not aligned to a block boundary and/or
+ * smaller than the block size.
+ *
  * The modify/write/read cycle may occur if a page is read before
  * being completely filled by the writer.  In this situation, the
  * page must be completely written to stable storage on the server
@@ -291,26 +297,32 @@ EXPORT_SYMBOL_GPL(nfs_file_fsync);
  * and that the new data won't completely replace the old data in
  * that range of the file.
  */
-static int nfs_want_read_modify_write(struct file *file, struct page *page,
-			loff_t pos, unsigned len)
+static bool nfs_full_page_write(struct page *page, loff_t pos, unsigned int len)
 {
 	unsigned int pglen = nfs_page_length(page);
 	unsigned int offset = pos & (PAGE_SIZE - 1);
 	unsigned int end = offset + len;
 
-	if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
-		if (!PageUptodate(page) && !PagePrivate(page))
-			return 1;
-		return 0;
-	}
+	return !pglen || (end >= pglen && !offset);
+}
 
-	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
-	    !PageUptodate(page) &&		/* Uptodate? */
-	    !PagePrivate(page) &&		/* i/o request already? */
-	    pglen &&				/* valid bytes of file? */
-	    (end < pglen || offset))		/* replace all valid bytes? */
-		return 1;
-	return 0;
+static bool nfs_want_read_modify_write(struct file *file, struct page *page,
+			loff_t pos, unsigned int len)
+{
+	/*
+	 * Up-to-date pages, those with ongoing or full-page write
+	 * don't need read/modify/write
+	 */
+	if (PageUptodate(page) || PagePrivate(page) ||
+	    nfs_full_page_write(page, pos, len))
+		return false;
+
+	if (pnfs_ld_read_whole_page(file->f_mapping->host))
+		return true;
+	/* Open for reading too? */
+	if (file->f_mode & FMODE_READ)
+		return true;
+	return false;
 }
 
 /*
-- 
2.20.1

