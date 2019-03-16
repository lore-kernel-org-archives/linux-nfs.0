Return-Path: <SRS0=f8xw=RT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 551CDC43381
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 01:43:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 28827218D0
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 01:43:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726444AbfCPBng (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 21:43:36 -0400
Received: from mx1.redhat.com ([209.132.183.28]:44460 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726218AbfCPBng (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Mar 2019 21:43:36 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 379F080472;
        Sat, 16 Mar 2019 01:43:36 +0000 (UTC)
Received: from dhcp-12-126.nay.redhat.com (dhcp-12-126.nay.redhat.com [10.66.12.126])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2CFB160BE6;
        Sat, 16 Mar 2019 01:43:34 +0000 (UTC)
From:   XiaoLi Feng <xifeng@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     Xiaoli Feng <fengxiaoli0714@gmail.com>
Subject: [PATCH] Fix nfs4.2 return -EINVAL when do dedupe operation
Date:   Sat, 16 Mar 2019 09:43:30 +0800
Message-Id: <20190316014330.22745-1-xifeng@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Sat, 16 Mar 2019 01:43:36 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Xiaoli Feng <fengxiaoli0714@gmail.com>

dedupe_file_range operations is combiled into remap_file_range.
But in nfs42_remap_file_range, it's skiped for dedupe operations.
Before this patch:
  # dd if=/dev/zero of=nfs/file bs=1M count=1
  # xfs_io -c "dedupe nfs/file 4k 64k 4k" nfs/file
  XFS_IOC_FILE_EXTENT_SAME: Invalid argument
After this patch:
  # dd if=/dev/zero of=nfs/file bs=1M count=1
  # xfs_io -c "dedupe nfs/file 4k 64k 4k" nfs/file
  deduped 4096/4096 bytes at offset 65536
  4 KiB, 1 ops; 0.0046 sec (865.988 KiB/sec and 216.4971 ops/sec)

Signed-off-by: Xiaoli Feng <fengxiaoli0714@gmail.com>
---
 fs/nfs/nfs4file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 45b2322e092d..1c5bd49de190 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -185,7 +185,7 @@ static loff_t nfs42_remap_file_range(struct file *src_file, loff_t src_off,
 	bool same_inode = false;
 	int ret;
 
-	if (remap_flags & ~REMAP_FILE_ADVISORY)
+	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
 		return -EINVAL;
 
 	/* check alignment w.r.t. clone_blksize */
-- 
2.18.1

