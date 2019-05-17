Return-Path: <SRS0=6Oa6=TR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CCC6C04AB4
	for <linux-nfs@archiver.kernel.org>; Fri, 17 May 2019 20:33:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 62ADD2087B
	for <linux-nfs@archiver.kernel.org>; Fri, 17 May 2019 20:33:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726990AbfEQUd6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 17 May 2019 16:33:58 -0400
Received: from fieldses.org ([173.255.197.46]:54152 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726726AbfEQUd6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 May 2019 16:33:58 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 3A35F14D8; Fri, 17 May 2019 16:33:58 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd: note inadequate stats locking
Date:   Fri, 17 May 2019 16:33:57 -0400
Message-Id: <1558125237-21030-2-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558125237-21030-1-git-send-email-bfields@redhat.com>
References: <1558125237-21030-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

After 89a26b3d295d "nfsd: split DRC global spinlock into per-bucket
locks", there is no longer a single global spinlock to protect these
stats.

So, really we need to fix that.  For now, at least fix the comment.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/netns.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 4146dca94c5f..e01c22fd1485 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -144,8 +144,11 @@ struct nfsd_net {
 	unsigned int             drc_hashsize;
 
 	/*
-	 * Stats and other tracking of on the duplicate reply cache. All of these and
-	 * the "rc" fields in nfsdstats are protected by the cache_lock
+	 * Stats and other tracking of on the duplicate reply cache.
+	 * These fields and the "rc" fields in nfsdstats are modified
+	 * with only the per-bucket cache lock, which isn't really safe
+	 * and should be fixed if we want the statistics to be
+	 * completely accurate.
 	 */
 
 	/* total number of entries */
-- 
2.21.0

