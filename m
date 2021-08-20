Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FA1AC432BE
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Aug 2021 21:02:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1BEEF610CC
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Aug 2021 21:02:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239999AbhHTVCt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 20 Aug 2021 17:02:49 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41684 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S240038AbhHTVCs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Aug 2021 17:02:48 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A4B8AC061757
        for <linux-nfs@vger.kernel.org>; Fri, 20 Aug 2021 14:02:09 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id E81CB200B; Fri, 20 Aug 2021 17:02:08 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org E81CB200B
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc:     daire@dneg.com, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/8] lockd: update nlm_lookup_file reexport comment
Date:   Fri, 20 Aug 2021 17:02:02 -0400
Message-Id: <1629493326-28336-5-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629493326-28336-1-git-send-email-bfields@redhat.com>
References: <1629493326-28336-1-git-send-email-bfields@redhat.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Update comment to reflect that we *do* allow reexport, whether it's a
good idea or not....

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/lockd/svcsubs.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 2558598610a9..f43d89e89c45 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -111,8 +111,9 @@ nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
 	INIT_HLIST_NODE(&file->f_list);
 	INIT_LIST_HEAD(&file->f_blocks);
 
-	/* Open the file. Note that this must not sleep for too long, else
-	 * we would lock up lockd:-) So no NFS re-exports, folks.
+	/*
+	 * Open the file. Note that if we're reexporting, for example,
+	 * this could block the lockd thread for a while.
 	 *
 	 * We have to make sure we have the right credential to open
 	 * the file.
-- 
2.31.1

