Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.7 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 412D0C432BE
	for <linux-nfs@archiver.kernel.org>; Fri, 27 Aug 2021 18:00:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 21EFD60F4F
	for <linux-nfs@archiver.kernel.org>; Fri, 27 Aug 2021 18:00:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236657AbhH0SBr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 27 Aug 2021 14:01:47 -0400
Received: from mail.kernel.org ([198.145.29.99]:57884 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231359AbhH0SBq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Aug 2021 14:01:46 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 7E55160F35;
        Fri, 27 Aug 2021 18:00:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1630087257;
        bh=p+B933KvPu08re7lkMfC9NDHAxMff6Xh275mOr2AcLY=;
        h=From:To:Cc:Subject:Date:From;
        b=UNz/wN5prEvsD9FS0C2npoHKIxmYmSDHy0WbrA+PoONDkGVX7M42beAg/jessIJaT
         6cAcjKfbVsLpF5T1clCICRK32t4DGs/mtSWFh86XMVZKYERdqqw+yL8MgDPz+RtE9F
         cIlnTXRwTmUVz89ORcd9WMZjosUdx/R+z4Ex2KMWNBL6GA3EgkTur5IAEUgxQJboBi
         +2jXAjyavle+RrUgG5G4nowBsGj7TYdJH7YN9zvTxJMkC+zQnHIOB3XzE9NxW1PYr6
         k9Bq1DCF0o1upTDnkCjf40cRIOdMb6RLLSS8zblp95ua9y6c9041K+A+0oCkkP9aj+
         Gg/GD+2zp5Xsg==
From:   trondmy@kernel.org
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Always provide aligned buffers to the RPC read layers
Date:   Fri, 27 Aug 2021 14:00:56 -0400
Message-Id: <20210827180056.610170-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Instead of messing around with XDR padding in the RDMA layer, we should
just give the RPC layer an aligned buffer. Try to avoid creating extra
RPC calls by aligning to the smaller value of ALIGN(len, rsize) and
PAGE_SIZE.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/read.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 9f39e0a1a38b..08d6cc57cbc3 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -293,15 +293,19 @@ static int
 readpage_async_filler(void *data, struct page *page)
 {
 	struct nfs_readdesc *desc = data;
+	struct inode *inode = page_file_mapping(page)->host;
+	unsigned int rsize = NFS_SERVER(inode)->rsize;
 	struct nfs_page *new;
-	unsigned int len;
+	unsigned int len, aligned_len;
 	int error;
 
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
-	new = nfs_create_request(desc->ctx, page, 0, len);
+	aligned_len = min_t(unsigned int, ALIGN(len, rsize), PAGE_SIZE);
+
+	new = nfs_create_request(desc->ctx, page, 0, aligned_len);
 	if (IS_ERR(new))
 		goto out_error;
 
-- 
2.31.1

