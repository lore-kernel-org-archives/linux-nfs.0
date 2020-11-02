Return-Path: <SRS0=KohJ=EI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2F7DC00A89
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Nov 2020 18:17:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8E45020731
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Nov 2020 18:17:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1604341050;
	bh=uN1IRuZs3frQ5fasnLTY20rW+4Tdu5UaBopqQniHe7Y=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=tUvTEoeq9MOIIBd2FKjwlXANs+7uvFIwwmB3FcEU6za6R3jL3FpY9yvNLY9QJS60z
	 q98pfjUpNg3LcEOnKVf9I9Ii1LaowsWgJ157f1zuvxfwM62F1A4HouViEkc/ij7c5w
	 Qvb0LHwK3l8Nntorx3CWlE7nEbxcB0SID8++S9TQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725797AbgKBSRZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 2 Nov 2020 13:17:25 -0500
Received: from mail.kernel.org ([198.145.29.99]:40892 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726283AbgKBSRY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Nov 2020 13:17:24 -0500
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id C4D6E22226
        for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2020 18:17:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1604341044;
        bh=uN1IRuZs3frQ5fasnLTY20rW+4Tdu5UaBopqQniHe7Y=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=wzDoK/49PGnE8x8C0zgbGlnenBOSvta1Gl1CzZJLSk5XAdYZ+riijDZs3lXzox+5Y
         kJGEwoy77WOeVZ8U6gr+1kNmtMbq567mSWRGiH54nce0RRt2QcyOtam/fJWgdzCjTL
         Je+ie+Z39DxpOe5jvZ5yhP9VVx9+bDRPP4zqrCow=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 07/12] NFS: Replace kmap() with kmap_atomic() in nfs_readdir_search_array()
Date:   Mon,  2 Nov 2020 13:06:53 -0500
Message-Id: <20201102180658.6218-8-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201102180658.6218-7-trondmy@kernel.org>
References: <20201102180658.6218-1-trondmy@kernel.org>
 <20201102180658.6218-2-trondmy@kernel.org>
 <20201102180658.6218-3-trondmy@kernel.org>
 <20201102180658.6218-4-trondmy@kernel.org>
 <20201102180658.6218-5-trondmy@kernel.org>
 <20201102180658.6218-6-trondmy@kernel.org>
 <20201102180658.6218-7-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 560a9c1553e5..a91f9ea87611 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -443,7 +443,7 @@ int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
 	struct nfs_cache_array *array;
 	int status;
 
-	array = kmap(desc->page);
+	array = kmap_atomic(desc->page);
 
 	if (desc->dir_cookie == 0)
 		status = nfs_readdir_search_for_pos(array, desc);
@@ -455,7 +455,7 @@ int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
 		desc->current_index += array->size;
 		desc->page_index++;
 	}
-	kunmap(desc->page);
+	kunmap_atomic(array);
 	return status;
 }
 
-- 
2.28.0

