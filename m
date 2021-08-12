Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E85AC432BE
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Aug 2021 20:41:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 54DD9610A3
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Aug 2021 20:41:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235486AbhHLUmM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 12 Aug 2021 16:42:12 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50128 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237853AbhHLUmK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Aug 2021 16:42:10 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0BCB2C0617AE
        for <linux-nfs@vger.kernel.org>; Thu, 12 Aug 2021 13:41:45 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 92A601BE2; Thu, 12 Aug 2021 16:41:44 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 92A601BE2
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd4: Fix forced-expiry locking
Date:   Thu, 12 Aug 2021 16:41:43 -0400
Message-Id: <1628800903-10760-3-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1628800903-10760-1-git-send-email-bfields@redhat.com>
References: <1628800903-10760-1-git-send-email-bfields@redhat.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

This should use the network-namespace-wide client_lock, not the
per-client cl_lock.

You shouldn't see any bugs unless you're actually using the
forced-expiry interface introduced by 89c905beccbb.

Fixes: 89c905beccbb "nfsd: allow forced expiration of NFSv4 clients"
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 212f43fa5cba..1b6a7f48982e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2687,9 +2687,9 @@ static void force_expire_client(struct nfs4_client *clp)
 
 	trace_nfsd_clid_admin_expired(&clp->cl_clientid);
 
-	spin_lock(&clp->cl_lock);
+	spin_lock(&nn->client_lock);
 	clp->cl_time = 0;
-	spin_unlock(&clp->cl_lock);
+	spin_unlock(&nn->client_lock);
 
 	wait_event(expiry_wq, atomic_read(&clp->cl_rpc_users) == 0);
 	spin_lock(&nn->client_lock);
-- 
2.31.1

