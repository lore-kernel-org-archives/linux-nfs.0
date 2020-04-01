Return-Path: <SRS0=udTg=5R=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCBD7C2BA12
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Apr 2020 18:59:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 95D35207FF
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Apr 2020 18:59:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1585767543;
	bh=RODUwAhVKI/sjSWmzSh5I+TaLw3MXqfk3S9LJvnSulc=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=BTVn0ldZ7HE27LgfuiFKbQNSvUSIAlcqpjD2cMlpuNrjqlS5YWFbkGdjFdMJufIGp
	 bq8YW8SXOCvvIah/RMRezrypU5CVp+xJxNiltl/GV6bu2MGpxl18feKy2Zp/RfpvV4
	 Ojs3NITYr6Vv6ppYA3LEMgpJDBxjiHWWZhdhHS2M=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732148AbgDAS7C (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 1 Apr 2020 14:59:02 -0400
Received: from mail.kernel.org ([198.145.29.99]:36664 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732211AbgDAS7C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Apr 2020 14:59:02 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1E57E207FF
        for <linux-nfs@vger.kernel.org>; Wed,  1 Apr 2020 18:59:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1585767542;
        bh=RODUwAhVKI/sjSWmzSh5I+TaLw3MXqfk3S9LJvnSulc=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=z7c0y4U8CBl/nlKWIx8GC8GXk25WyZNAiDkYtdhhEOwh/PSFLW8vdonH3ORZlmrrI
         +Y51uXIm7LjXHk2rJ5nrA2k0sHN5ymuYTs3NKwrB+fGIjT61LXjCedqMNs0dab5vpf
         iwmGIVh6WGgg6Jd3Hxu8g0wu9o9/VMcn7FLnEHyo=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 04/10] NFS: Fix a request reference leak in nfs_direct_write_clear_reqs()
Date:   Wed,  1 Apr 2020 14:56:46 -0400
Message-Id: <20200401185652.1904777-5-trondmy@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200401185652.1904777-4-trondmy@kernel.org>
References: <20200401185652.1904777-1-trondmy@kernel.org>
 <20200401185652.1904777-2-trondmy@kernel.org>
 <20200401185652.1904777-3-trondmy@kernel.org>
 <20200401185652.1904777-4-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

nfs_direct_write_scan_commit_list() will lock the request and bump
the reference count, but we also need to account for the reference
that was taken when we initially added the request to the commit list.

Fixes: fb5f7f20cdb9 ("NFS: commit errors should be fatal")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/direct.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 51ab4627c4d6..8074304fd5b4 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -646,6 +646,7 @@ static void nfs_direct_write_clear_reqs(struct nfs_direct_req *dreq)
 	while (!list_empty(&reqs)) {
 		req = nfs_list_entry(reqs.next);
 		nfs_list_remove_request(req);
+		nfs_release_request(req);
 		nfs_unlock_and_release_request(req);
 	}
 }
-- 
2.25.1

