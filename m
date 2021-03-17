Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3032FC433E0
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Mar 2021 13:01:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CAEDD64E41
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Mar 2021 13:01:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229944AbhCQNB0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Mar 2021 09:01:26 -0400
Received: from mail.kernel.org ([198.145.29.99]:35070 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230044AbhCQNBM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Mar 2021 09:01:12 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 1C96F64E41;
        Wed, 17 Mar 2021 13:01:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1615986072;
        bh=m0gnAiNhAkVhqUExZnTGjItJOz5/NZPMJSgKXlK/Jh0=;
        h=From:To:Cc:Subject:Date:From;
        b=snZPwiC8rzHVNm3q5snfqZXR9RlLfWf7joAf1GVzScAICW4/jF3I/6EkZx1auY7ij
         wOkSHV6nzJO+119o6Y+WsS1proPtc8YtOk3MkIy4Y0aW0HwtN9hqOe5zEWd54MQxSw
         W1iLY7VuzMCrz6dy0bfvwEpSonI8jnoIUqdPR0S6SOOeM8VoH+kLR1JDmBYiBiE6z0
         4Sn0OxoiFBQvCE3DKyurMoWlNNjFBq+GCB2CqUrkID9IFUenkOJ/yA8UcMdQJ+Xyz5
         OsSTkS5Y32uBh6wivxEtw4VWB+SSgQie91XQIf3nB9qWPBj+O8Ua5uDQfIKRahtYnu
         9nXsEskZCggog==
From:   trondmy@kernel.org
To:     Nagendra S Tomar <natomar@microsoft.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Only change the cookie verifier if the directory page cache is empty
Date:   Wed, 17 Mar 2021 09:01:10 -0400
Message-Id: <20210317130110.1257066-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.30.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

The cached NFSv3/v4 readdir cookies are associated with a verifier,
which is checked by the server on subsequent calls to readdir, and is
only expected to change when the cookies (and hence also the page cache
contents) are considered invalid.
We therefore do have to store the verifier, but only when the page cache
is empty.

Fixes: b593c09f83a2 ("NFS: Improve handling of directory verifiers")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2cf2a7d92faf..0cd7c59a6601 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -929,7 +929,12 @@ static int find_and_lock_cache_page(struct nfs_readdir_descriptor *desc)
 			}
 			return res;
 		}
-		memcpy(nfsi->cookieverf, verf, sizeof(nfsi->cookieverf));
+		/*
+		 * Set the cookie verifier if the page cache was empty
+		 */
+		if (desc->page_index == 0)
+			memcpy(nfsi->cookieverf, verf,
+			       sizeof(nfsi->cookieverf));
 	}
 	res = nfs_readdir_search_array(desc);
 	if (res == 0) {
-- 
2.30.2

