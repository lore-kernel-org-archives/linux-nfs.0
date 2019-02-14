Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ED3AC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 09:37:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 187A02229F
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 09:37:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389384AbfBNJhR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 04:37:17 -0500
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:43169 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387493AbfBNJhR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2019 04:37:17 -0500
Received: from vc2.ecl.ntt.co.jp (vc2.ecl.ntt.co.jp [129.60.86.154])
        by tama500.ecl.ntt.co.jp (8.13.8/8.13.8) with ESMTP id x1E9bBFI003927;
        Thu, 14 Feb 2019 18:37:11 +0900
Received: from vc2.ecl.ntt.co.jp (localhost [127.0.0.1])
        by vc2.ecl.ntt.co.jp (Postfix) with ESMTP id CD4FA639057;
        Thu, 14 Feb 2019 18:37:11 +0900 (JST)
Received: from jcms-pop11.ecl.ntt.co.jp (jcms-pop11.ecl.ntt.co.jp [129.60.87.132])
        by vc2.ecl.ntt.co.jp (Postfix) with ESMTP id C1B29638F4C;
        Thu, 14 Feb 2019 18:37:11 +0900 (JST)
Received: from [IPv6:::1] (unknown [129.60.241.209])
        by jcms-pop11.ecl.ntt.co.jp (Postfix) with ESMTPSA id BB66F70C038B;
        Thu, 14 Feb 2019 18:37:11 +0900 (JST)
From:   Kazuo Ito <ito_kazuo_g3@lab.ntt.co.jp>
Subject: [PATCH v2 1/2] pNFS: Fix potential corruption of page being written
Message-ID: <480b4d46-e290-b612-7b8e-09eb3a488ee6@lab.ntt.co.jp>
Date:   Thu, 14 Feb 2019 18:36:58 +0900
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

nfs_want_read_modify_write() didn't check for !PagePrivate when pNFS
block or SCSI layout was in use, therefore we could lose data forever
if the page being written was filled by a read before completion.

Signed-off-by: Kazuo Ito <ito_kazuo_g3@lab.ntt.co.jp>
---
 fs/nfs/file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 29553fdba8af..d8f25b1ae233 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -299,7 +299,7 @@ static int nfs_want_read_modify_write(struct file *file, struct page *page,
 	unsigned int end = offset + len;
 
 	if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
-		if (!PageUptodate(page))
+		if (!PageUptodate(page) && !PagePrivate(page))
 			return 1;
 		return 0;
 	}
-- 
2.20.1

