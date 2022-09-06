Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C5F0ECAAD3
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Sep 2022 02:41:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229575AbiIFCls (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 5 Sep 2022 22:41:48 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54722 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229472AbiIFClr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2022 22:41:47 -0400
Received: from mail-m974.mail.163.com (mail-m974.mail.163.com [123.126.97.4])
        by lindbergh.monkeyblade.net (Postfix) with ESMTP id CCE1165555;
        Mon,  5 Sep 2022 19:41:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
        s=s110527; h=From:Subject:Date:Message-Id:MIME-Version; bh=jSpPT
        WdtMtXvwqC1KrSF9evfL6rrCirDZ6dY71IUeLM=; b=dP7O0LQkmLj2YhVinRHvb
        baveZtGOI5AOGJtr2gwnmP0QC/xEOEGVh2Oq8uuI4RkeJPuD19winqqNF86EVZE2
        GHmk4YH0+/bsQPMwEdN97HjxuK3pIAFKkYAaw4SNLnylAnsa3rvelFmO09TSoXy5
        fbCsjHbncyjqFlU9CCtfmU=
Received: from localhost.localdomain (unknown [116.128.244.169])
        by smtp4 (Coremail) with SMTP id HNxpCgBXeMlTsxZjhTN6ag--.39988S2;
        Tue, 06 Sep 2022 10:41:25 +0800 (CST)
From:   Jiangshan Yi <13667453960@163.com>
To:     trond.myklebust@hammerspace.com, anna@kernel.org
Cc:     rdunlap@infradead.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Jiangshan Yi <yijiangshan@kylinos.cn>,
        k2ci <kernel-bot@kylinos.cn>
Subject: [PATCH v2] fs/nfs/pnfs_nfs.c: fix spelling typo and syntax error in comment
Date:   Tue,  6 Sep 2022 10:41:19 +0800
Message-Id: <20220906024119.424210-1-13667453960@163.com>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID: HNxpCgBXeMlTsxZjhTN6ag--.39988S2
X-Coremail-Antispam: 1Uf129KBjvdXoWrZF43GFyUKrW8Kr4UZry5urg_yoWktFb_Ga
        ySv34DWw4UJrs3Zw17Kr4a9FWY9FsxKFZ3JF4qqF1ak345G395XayktFWSy39xWr48Krn5
        Gwn2yr90yrySvjkaLaAFLSUrUUUUUb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
        9fnUUvcSsGvfC2KfnxnUUI43ZEXa7IU1uMN5UUUUU==
X-Originating-IP: [116.128.244.169]
X-CM-SenderInfo: bprtllyxuvjmiwq6il2tof0z/1tbiVxV0+1etoL9o1wAAsX
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Jiangshan Yi <yijiangshan@kylinos.cn>

Fix spelling typo and syntax error in comment.

Suggested-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: k2ci <kernel-bot@kylinos.cn>
Signed-off-by: Jiangshan Yi <yijiangshan@kylinos.cn>
---
 fs/nfs/pnfs_nfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 657c242a18ff..987c88ddeaf0 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -374,12 +374,12 @@ pnfs_bucket_search_commit_reqs(struct pnfs_commit_bucket *buckets,
 	return NULL;
 }
 
-/* pnfs_generic_search_commit_reqs - Search lists in @cinfo for the head reqest
+/* pnfs_generic_search_commit_reqs - Search lists in @cinfo for the head request
  *				   for @page
  * @cinfo - commit info for current inode
  * @page - page to search for matching head request
  *
- * Returns a the head request if one is found, otherwise returns NULL.
+ * Return: the head request if one is found, otherwise %NULL.
  */
 struct nfs_page *
 pnfs_generic_search_commit_reqs(struct nfs_commit_info *cinfo, struct page *page)
-- 
2.25.1


No virus found
		Checked by Hillstone Network AntiVirus

