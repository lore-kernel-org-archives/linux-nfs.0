Return-Path: <SRS0=390i=5N=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C285FC2D0EF
	for <linux-nfs@archiver.kernel.org>; Sat, 28 Mar 2020 15:34:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8F7942082F
	for <linux-nfs@archiver.kernel.org>; Sat, 28 Mar 2020 15:34:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1585409678;
	bh=7EnajCoY61wyaI04/xGUaouttgnSwwfGTe62JcRBxjE=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=CdXy9He6bk4kFIOp/b6KiA6y1fdpj2KtGd7mTbYjW1qYC9BoNOs+DeEBfVSmBTJRz
	 4iekAz8znfqKQjL2KBTi8uZSH0IXJ+Rw4wUw8mEAxF46D8hAkETJkfFb1q6Do3lTZ0
	 9B/7C72TRQhNhu9Zc/l0ZeXCtf5L4Q6CBY441Jgw=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727009AbgC1Peh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 28 Mar 2020 11:34:37 -0400
Received: from mail.kernel.org ([198.145.29.99]:40304 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727131AbgC1Peg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 28 Mar 2020 11:34:36 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 48CFA2073B
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2020 15:34:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1585409676;
        bh=7EnajCoY61wyaI04/xGUaouttgnSwwfGTe62JcRBxjE=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=MrjiTozTD0XEvIu+XErgUb/KqTrZ+ZprIxMDX7SQpvaujukGiKTKijDSHgmP0v8wW
         gWtsYUM4bGi7g+Qsq8pAb0fGa1rT4DHbABEfXagtXqggyRmMavyvC21j4XobpY+QVo
         5uUnMu2Q7kJd1Wpc46LIRumSNcZhhuXRvp10tGwY=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 07/22] pNFS: Support per-layout segment commits in pnfs_generic_commit_pagelist()
Date:   Sat, 28 Mar 2020 11:32:05 -0400
Message-Id: <20200328153220.1352010-8-trondmy@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200328153220.1352010-7-trondmy@kernel.org>
References: <20200328153220.1352010-1-trondmy@kernel.org>
 <20200328153220.1352010-2-trondmy@kernel.org>
 <20200328153220.1352010-3-trondmy@kernel.org>
 <20200328153220.1352010-4-trondmy@kernel.org>
 <20200328153220.1352010-5-trondmy@kernel.org>
 <20200328153220.1352010-6-trondmy@kernel.org>
 <20200328153220.1352010-7-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Add support for scanning the full list of per-layout segment commit
arrays to pnfs_generic_commit_pagelist().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs_nfs.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index f16bd6d0e830..f895a28b1e26 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -322,6 +322,20 @@ pnfs_bucket_alloc_ds_commits(struct list_head *list,
 	return nreq;
 }
 
+static unsigned int
+pnfs_alloc_ds_commits_list(struct list_head *list,
+			   struct pnfs_ds_commit_info *fl_cinfo,
+			   struct nfs_commit_info *cinfo)
+{
+	struct pnfs_commit_array *array;
+	unsigned int ret = 0;
+
+	list_for_each_entry(array, &fl_cinfo->commits, cinfo_list)
+		ret += pnfs_bucket_alloc_ds_commits(list, array->buckets,
+				array->nbuckets, cinfo);
+	return ret;
+}
+
 /* This follows nfs_commit_list pretty closely */
 int
 pnfs_generic_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
@@ -345,6 +359,8 @@ pnfs_generic_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 
 	nreq += pnfs_bucket_alloc_ds_commits(&list, fl_cinfo->buckets,
 			fl_cinfo->nbuckets, cinfo);
+
+	nreq += pnfs_alloc_ds_commits_list(&list, fl_cinfo, cinfo);
 	if (nreq == 0)
 		goto out;
 
-- 
2.25.1

