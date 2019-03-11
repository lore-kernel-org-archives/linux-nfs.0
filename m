Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FC7EC4360F
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 20:03:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 021C52087C
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 20:03:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334583;
	bh=d7Tqjh7SIOkwevRNpGbd6OaKpbBseCw01ihijQfJa5Y=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=aptDGgmJAz2PVXqMY9PFNBvj7hN2mGxzNQ7lVgWmtX86z9Z1UDjD9hEiVAobyZJ4o
	 tbKY1rA6vdiVXS+NDnAKXSZr0j/zVRba3xSs3RTObsWgzq9bVVF6rvtKe4Acf42EjN
	 es3qaxdW83YyaVpl7ayxB3d8x7Z5L5LLTkNP3/z4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728921AbfCKUC5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 16:02:57 -0400
Received: from mail.kernel.org ([198.145.29.99]:36308 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729482AbfCKT6x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Mar 2019 15:58:53 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 7EB1F214AE;
        Mon, 11 Mar 2019 19:58:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1552334333;
        bh=d7Tqjh7SIOkwevRNpGbd6OaKpbBseCw01ihijQfJa5Y=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=ukJG49nj+34uKdHNozD+OxawY8qskoYFBoImhK9y+31GRd+i8Mw+J2oUYZ5xm9DsZ
         adENVAKHc0oqCv9b2ktTfzSnyDBgdzI14sgnCjpxoB+ntR+bUhmFBs/UIx9OdWidpt
         rHGq0PENqU2cwW7PMIL4n3SIwmvx9tgaOPHSfLWo=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Benjamin Coddington <bcodding@redhat.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.14 19/27] NFS: Don't use page_file_mapping after removing the page
Date:   Mon, 11 Mar 2019 15:58:16 -0400
Message-Id: <20190311195824.139043-19-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195824.139043-1-sashal@kernel.org>
References: <20190311195824.139043-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Benjamin Coddington <bcodding@redhat.com>

[ Upstream commit d2ceb7e57086750ea6198a31fd942d98099a0786 ]

If nfs_page_async_flush() removes the page from the mapping, then we can't
use page_file_mapping() on it as nfs_updatepate() is wont to do when
receiving an error.  Instead, push the mapping to the stack before the page
is possibly truncated.

Fixes: 8fc75bed96bb ("NFS: Fix up return value on fatal errors in nfs_page_async_flush()")
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/write.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2d956a7d5378..50ed3944d183 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -236,9 +236,9 @@ static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int c
 }
 
 /* A writeback failed: mark the page as bad, and invalidate the page cache */
-static void nfs_set_pageerror(struct page *page)
+static void nfs_set_pageerror(struct address_space *mapping)
 {
-	nfs_zap_mapping(page_file_mapping(page)->host, page_file_mapping(page));
+	nfs_zap_mapping(mapping->host, mapping);
 }
 
 /*
@@ -994,7 +994,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 		nfs_list_remove_request(req);
 		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
 		    (hdr->good_bytes < bytes)) {
-			nfs_set_pageerror(req->wb_page);
+			nfs_set_pageerror(page_file_mapping(req->wb_page));
 			nfs_context_set_write_error(req->wb_context, hdr->error);
 			goto remove_req;
 		}
@@ -1330,7 +1330,8 @@ int nfs_updatepage(struct file *file, struct page *page,
 		unsigned int offset, unsigned int count)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
-	struct inode	*inode = page_file_mapping(page)->host;
+	struct address_space *mapping = page_file_mapping(page);
+	struct inode	*inode = mapping->host;
 	int		status = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
@@ -1348,7 +1349,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 
 	status = nfs_writepage_setup(ctx, page, offset, count);
 	if (status < 0)
-		nfs_set_pageerror(page);
+		nfs_set_pageerror(mapping);
 	else
 		__set_page_dirty_nobuffers(page);
 out:
-- 
2.19.1

