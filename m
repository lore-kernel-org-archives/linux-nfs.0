Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-20.5 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 875D0C4338F
	for <linux-nfs@archiver.kernel.org>; Fri, 23 Jul 2021 12:57:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6F5AB60E95
	for <linux-nfs@archiver.kernel.org>; Fri, 23 Jul 2021 12:57:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234976AbhGWMQu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 23 Jul 2021 08:16:50 -0400
Received: from mail.kernel.org ([198.145.29.99]:40856 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S234914AbhGWMQt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Jul 2021 08:16:49 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 06E3760E8C
        for <linux-nfs@vger.kernel.org>; Fri, 23 Jul 2021 12:57:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1627045043;
        bh=Em1nHkBe4tGlc3m1BNIL3y8x/WtGs8f8xmFk+heJMvA=;
        h=From:To:Subject:Date:From;
        b=ZZntLvRwNg57Ac/+KzrjE6upLw4tpvQvKyhdHKfSL2JqtJN6cUUhmIxkLhdcV6KT2
         Ga50Ck08c9LqF/WI7fhO2ZOO7yHzHWw8iJRkMeVzZZG5Y/ddxwkn/78ntJCsHW7RrM
         +OFgQcYDZI5AMBeYsOtgyoK8C0KUmhGYwNpnYFN5yreHD5AlMOe4qk4F/5op4bHGSX
         WULilCWuvJm4OqbGuSOczeAT9yIKPIrUbHsIGe2++LlJw6BooTTIhUn4bHh6vDWTod
         zRT2t55ruBRF9kSkI32UosZhrDZDX26JdTxp7Qy/DKQhOe7IqFKqtdIrKtHdiM2+d4
         CXfOohFeclxvA==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4/pNFS: Always allow update of a zero valued layout barrier
Date:   Fri, 23 Jul 2021 08:57:20 -0400
Message-Id: <20210723125721.22572-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

A zero value for the layout barrier indicates that it has been cleared
(since seqid '0' is an illegal value), so we should always allow it to
be updated.

Fixes: d29b468da4f9 ("pNFS/NFSv4: Improve rejection of out-of-order layouts")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ef14ea0b6ab8..4e69e4e6c416 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -335,7 +335,7 @@ static bool pnfs_seqid_is_newer(u32 s1, u32 s2)
 
 static void pnfs_barrier_update(struct pnfs_layout_hdr *lo, u32 newseq)
 {
-	if (pnfs_seqid_is_newer(newseq, lo->plh_barrier))
+	if (pnfs_seqid_is_newer(newseq, lo->plh_barrier) || !lo->plh_barrier)
 		lo->plh_barrier = newseq;
 }
 
-- 
2.31.1

