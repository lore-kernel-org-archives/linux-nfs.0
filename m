Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45FE6C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 07:55:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 13E7821917
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 07:55:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727058AbfBHHzO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 02:55:14 -0500
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:41644 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726004AbfBHHzO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2019 02:55:14 -0500
Received: from vc2.ecl.ntt.co.jp (vc2.ecl.ntt.co.jp [129.60.86.154])
        by tama50.ecl.ntt.co.jp (8.13.8/8.13.8) with ESMTP id x187t4US014567;
        Fri, 8 Feb 2019 16:55:04 +0900
Received: from vc2.ecl.ntt.co.jp (localhost [127.0.0.1])
        by vc2.ecl.ntt.co.jp (Postfix) with ESMTP id EE3E3639AD5;
        Fri,  8 Feb 2019 16:55:03 +0900 (JST)
Received: from jcms-pop11.ecl.ntt.co.jp (jcms-pop11.ecl.ntt.co.jp [129.60.87.132])
        by vc2.ecl.ntt.co.jp (Postfix) with ESMTP id E2A3E639A5E;
        Fri,  8 Feb 2019 16:55:03 +0900 (JST)
Received: from [IPv6:::1] (unknown [129.60.241.190])
        by jcms-pop11.ecl.ntt.co.jp (Postfix) with ESMTPSA id D927170C076F;
        Fri,  8 Feb 2019 16:55:03 +0900 (JST)
Subject: Re: [PATCH] pNFS: Avoid read-modify-write for page-aligned full page
 write
References: <37261782-eebb-b9c5-a480-7ced59b3703f@lab.ntt.co.jp>
 <5905EB17-75B9-494A-B608-F135D6330F49@redhat.com>
From:   =?UTF-8?B?5LyK6Jek5ZKM5aSr?= <ito_kazuo_g3@lab.ntt.co.jp>
Message-ID: <4332a67f-0d50-cc30-4e2b-8d08a112a76f@lab.ntt.co.jp>
Date:   Fri, 8 Feb 2019 16:54:45 +0900
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <5905EB17-75B9-494A-B608-F135D6330F49@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-CC-Mail-RelayStamp: 1
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org,
        Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>,
        watanabe.hiroyuki@lab.ntt.co.jp
X-TM-AS-MML: disable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


On 2019/02/07 22:37, Benjamin Coddington wrote:
> On 7 Feb 2019, at 3:12, Kazuo Ito wrote:
> [snipped]
>> @@ -299,8 +305,10 @@ static int nfs_want_read_modify_write(struct file 
>> *file, struct page *page,
>>      unsigned int end = offset + len;
>>
>>      if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
>> -        if (!PageUptodate(page))
>> -            return 1;
>> +        if (!PageUptodate(page)) {
>> +            if (pglen && (end < pglen || offset))
>> +                return 1;
>> +        }
>>          return 0;
>>      }
> 
> This looks right.  I think that a static inline bool nfs_write_covers_page,
> or full_page_write or similar might make sense here, as we do the same test
> just below, and would make the code easier to quickly understand.
> 
> Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
 >
 > Ben

As per Ben's comment, I made the check for full page write a static
inline function and both the block-oriented and the non-block-
oriented paths call it.

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 29553fdba8af..458c77ccf274 100644
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
@@ -291,15 +297,23 @@ EXPORT_SYMBOL_GPL(nfs_file_fsync);
   * and that the new data won't completely replace the old data in
   * that range of the file.
   */
-static int nfs_want_read_modify_write(struct file *file, struct page *page,
-			loff_t pos, unsigned len)
+static bool nfs_full_page_write(struct page *page, loff_t pos, unsigned 
len)
  {
  	unsigned int pglen = nfs_page_length(page);
  	unsigned int offset = pos & (PAGE_SIZE - 1);
  	unsigned int end = offset + len;

+	if (pglen && ((end < pglen) || offset))
+	    return 0;
+	return 1;
+}
+
+static int nfs_want_read_modify_write(struct file *file, struct page *page,
+			loff_t pos, unsigned len)
+{
  	if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
-		if (!PageUptodate(page))
+		if (!PageUptodate(page) &&
+		    !nfs_full_page_write(page, pos, len))
  			return 1;
  		return 0;
  	}
@@ -307,8 +321,7 @@ static int nfs_want_read_modify_write(struct file 
*file, struct page *page,
  	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
  	    !PageUptodate(page) &&		/* Uptodate? */
  	    !PagePrivate(page) &&		/* i/o request already? */
-	    pglen &&				/* valid bytes of file? */
-	    (end < pglen || offset))		/* replace all valid bytes? */
+	    !nfs_full_page_write(page, pos, len))
  		return 1;
  	return 0;
  }

Signed-off-by: Kazuo Ito <ito_kazuo_g3@lab.ntt.co.jp>
