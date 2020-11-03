Return-Path: <SRS0=DoCl=EJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F778C388F7
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Nov 2020 15:43:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 352A12080D
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Nov 2020 15:43:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1604418226;
	bh=d8g1ssvMEKbn5ctcVSH4O7QGnvonC32nfZcKNfIGUiE=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=Z07QKgckxtIYOsswJLs0MqTsH5CysxWesGJoT+L/aiyBqUdcb7aglnuwnroYFHeFh
	 NOi32siDVg/j0E9zlnU9WBiC24s0YnPkyjMfcP4vDogmV4WB94G1S9wg8iNjXRiJGw
	 MO5U/FJrkinW7q3Sdla3ck922OSwUDoCPo9cqKfU=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728312AbgKCPnp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 Nov 2020 10:43:45 -0500
Received: from mail.kernel.org ([198.145.29.99]:39144 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728299AbgKCPnn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Nov 2020 10:43:43 -0500
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 48DE5221FB
        for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2020 15:43:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1604418223;
        bh=d8g1ssvMEKbn5ctcVSH4O7QGnvonC32nfZcKNfIGUiE=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=c5xTiwEvquXpAxIvn5zWtshR77wWTyOhlt9qkK+bqwAJiJ2ec9cQmvAjtZxGK3ZCl
         46RP9ON8a9tLo9/vMr9rv/+FPZmaKg0o+u8LDYrWmIlkvKnEGsHrYlSNEgDL8/DtMf
         uapV73r0hta63HGZl4i0KOnDM3wFHjLj5PcCODwk=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/16] NFS: Remove unnecessary kmap in nfs_readdir_xdr_to_array()
Date:   Tue,  3 Nov 2020 10:33:19 -0500
Message-Id: <20201103153329.531942-7-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201103153329.531942-6-trondmy@kernel.org>
References: <20201103153329.531942-1-trondmy@kernel.org>
 <20201103153329.531942-2-trondmy@kernel.org>
 <20201103153329.531942-3-trondmy@kernel.org>
 <20201103153329.531942-4-trondmy@kernel.org>
 <20201103153329.531942-5-trondmy@kernel.org>
 <20201103153329.531942-6-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

The kmapped pointer is only used once per loop to check if we need to
exit.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 788c2a2eeaa3..ba3521dcd0c8 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -760,7 +760,6 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	struct page *pages[NFS_MAX_READDIR_PAGES];
 	struct nfs_entry entry;
 	struct file	*file = desc->file;
-	struct nfs_cache_array *array;
 	int status = -ENOMEM;
 	unsigned int array_size = ARRAY_SIZE(pages);
 
@@ -779,11 +778,9 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		goto out;
 	}
 
-	array = kmap(page);
-
 	status = nfs_readdir_alloc_pages(pages, array_size);
 	if (status < 0)
-		goto out_release_array;
+		goto out_release_label;
 	do {
 		unsigned int pglen;
 		status = nfs_readdir_xdr_filler(pages, desc, &entry, file, inode);
@@ -798,11 +795,10 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		}
 
 		status = nfs_readdir_page_filler(desc, &entry, pages, page, pglen);
-	} while (!status && !nfs_readdir_array_is_full(array));
+	} while (!status && nfs_readdir_page_needs_filling(page));
 
 	nfs_readdir_free_pages(pages, array_size);
-out_release_array:
-	kunmap(page);
+out_release_label:
 	nfs4_label_free(entry.label);
 out:
 	nfs_free_fattr(entry.fattr);
-- 
2.28.0

