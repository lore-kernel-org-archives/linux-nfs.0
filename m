Return-Path: <SRS0=Dbg8=EN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A156C388F7
	for <linux-nfs@archiver.kernel.org>; Sat,  7 Nov 2020 14:13:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CBC46208C7
	for <linux-nfs@archiver.kernel.org>; Sat,  7 Nov 2020 14:13:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1604758424;
	bh=30nHINp2jfBYnFn8f97J7BoclOlm8gKLBwQON0gZ5qk=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=JP7/ve2iP0ox64h7HomNSKseGeyCSsNR9TvRKatpTcwRTpxGqNdafw+2pxIO2zCSN
	 +3xdsQUN6+rTltAXW81p5EnTmAFefyykVaFFRZdpcExuD7Gf0ufHBIybnivanPTFoj
	 0upd9wySKtBhSof/ABOvyaH01xOw02dH+v+bVZk8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728064AbgKGONl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 7 Nov 2020 09:13:41 -0500
Received: from mail.kernel.org ([198.145.29.99]:58260 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725880AbgKGONk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 7 Nov 2020 09:13:40 -0500
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 14C362087E
        for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2020 14:13:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1604758420;
        bh=30nHINp2jfBYnFn8f97J7BoclOlm8gKLBwQON0gZ5qk=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=gZNHvTO65iFMrXMfnkX+3Wr+hP+MC3wn6BGmIC67vnDog+JZ0Vls3gca3q1DqZ6JO
         z1rhNwxU3p/RC8XQtsrZEsu4T+c4/UJnCJD2FOMj5F3os7EJIjG6ihhJs+VXGdn55D
         jrPzPW3Qln5sG3a6CTFxZ2s0GrDHkg6XeNNoA08Y=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v4 09/21] NFS: Replace kmap() with kmap_atomic() in nfs_readdir_search_array()
Date:   Sat,  7 Nov 2020 09:03:13 -0500
Message-Id: <20201107140325.281678-10-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201107140325.281678-9-trondmy@kernel.org>
References: <20201107140325.281678-1-trondmy@kernel.org>
 <20201107140325.281678-2-trondmy@kernel.org>
 <20201107140325.281678-3-trondmy@kernel.org>
 <20201107140325.281678-4-trondmy@kernel.org>
 <20201107140325.281678-5-trondmy@kernel.org>
 <20201107140325.281678-6-trondmy@kernel.org>
 <20201107140325.281678-7-trondmy@kernel.org>
 <20201107140325.281678-8-trondmy@kernel.org>
 <20201107140325.281678-9-trondmy@kernel.org>
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
index e8b0fcc1bc9e..b9001123ec84 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -447,7 +447,7 @@ int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
 	struct nfs_cache_array *array;
 	int status;
 
-	array = kmap(desc->page);
+	array = kmap_atomic(desc->page);
 
 	if (desc->dir_cookie == 0)
 		status = nfs_readdir_search_for_pos(array, desc);
@@ -459,7 +459,7 @@ int nfs_readdir_search_array(nfs_readdir_descriptor_t *desc)
 		desc->current_index += array->size;
 		desc->page_index++;
 	}
-	kunmap(desc->page);
+	kunmap_atomic(array);
 	return status;
 }
 
-- 
2.28.0

