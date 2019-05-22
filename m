Return-Path: <SRS0=9PwK=TW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEB81C282DC
	for <linux-nfs@archiver.kernel.org>; Wed, 22 May 2019 19:25:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 871EA217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 22 May 2019 19:25:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558553146;
	bh=aU4CXQ1D+LlLoIV1mmGR+NNarxByWPbHFnIBHyz5C9o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=kJgoMMzfiv2xFprcXsl0x8sCn6hQCRGtqMc5vLSrLWkQV3+YTDQzweaA3/i8/JjI3
	 hXsaR1w2jS7kNtqhCuyvZLMeAaFcQ4gZ0V/tptjvyVo72muXBIJ/MzHA07fzvqplm/
	 +g4hPg58f2O8r8aAviLgPysSmWWUov5WfIEmqvyY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731726AbfEVTZp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 May 2019 15:25:45 -0400
Received: from mail.kernel.org ([198.145.29.99]:47100 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731719AbfEVTZo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 May 2019 15:25:44 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 002D3217D9;
        Wed, 22 May 2019 19:25:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1558553143;
        bh=aU4CXQ1D+LlLoIV1mmGR+NNarxByWPbHFnIBHyz5C9o=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=enJDO+kb2GKPbQbcZI3C4IEVISQaE2+mPHYbhG8lVDiiRw25WasNNxX8uxvcgsv87
         TyqF5RlnNB1UbY7GgrPxcOz41fgEIjM3aiDomxB9UY6JZ8mGc3FMMjkxyS13Ak0257
         2jCP32KXALZ8aXP9uLCkrP9DHY+NSSioY6R8HrTY=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Xiaoli Feng <fengxiaoli0714@gmail.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.0 073/317] Fix nfs4.2 return -EINVAL when do dedupe operation
Date:   Wed, 22 May 2019 15:19:34 -0400
Message-Id: <20190522192338.23715-73-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190522192338.23715-1-sashal@kernel.org>
References: <20190522192338.23715-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Xiaoli Feng <fengxiaoli0714@gmail.com>

[ Upstream commit ce96e888fe48ecfa868c9a39adc03292c78a80ff ]

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
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs4file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 00d17198ee12a..f10b660805fc4 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -187,7 +187,7 @@ static loff_t nfs42_remap_file_range(struct file *src_file, loff_t src_off,
 	bool same_inode = false;
 	int ret;
 
-	if (remap_flags & ~REMAP_FILE_ADVISORY)
+	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
 		return -EINVAL;
 
 	/* check alignment w.r.t. clone_blksize */
-- 
2.20.1

