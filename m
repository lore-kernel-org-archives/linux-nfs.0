Return-Path: <SRS0=lMqp=UF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0883BC04AB5
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Jun 2019 14:40:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CFE7220684
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Jun 2019 14:40:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728776AbfFFOkG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 6 Jun 2019 10:40:06 -0400
Received: from fieldses.org ([173.255.197.46]:36504 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728508AbfFFOkG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Jun 2019 10:40:06 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id D0A391E29; Thu,  6 Jun 2019 10:40:05 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd4: remove outdated nfsd4_decode_time comment
Date:   Thu,  6 Jun 2019 10:40:04 -0400
Message-Id: <1559832004-26631-2-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559832004-26631-1-git-send-email-bfields@redhat.com>
References: <1559832004-26631-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Commit bf8d909705e "nfsd: Decode and send 64bit time values" fixed the
code without updating the comment.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 73e6753fb213..548a5a843b67 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -269,10 +269,6 @@ static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
 	return ret;
 }
 
-/*
- * We require the high 32 bits of 'seconds' to be 0, and
- * we ignore all 32 bits of 'nseconds'.
- */
 static __be32
 nfsd4_decode_time(struct nfsd4_compoundargs *argp, struct timespec64 *tv)
 {
-- 
2.21.0

