Return-Path: <SRS0=k6XJ=VC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69054C0650E
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Jul 2019 00:06:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 447D221738
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Jul 2019 00:06:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727564AbfGEAGQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Jul 2019 20:06:16 -0400
Received: from smtprelay0217.hostedemail.com ([216.40.44.217]:38912 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1727313AbfGEAGQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jul 2019 20:06:16 -0400
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
        by smtpgrave07.hostedemail.com (Postfix) with ESMTP id 4CF6C18352282
        for <linux-nfs@vger.kernel.org>; Thu,  4 Jul 2019 23:58:06 +0000 (UTC)
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay05.hostedemail.com (Postfix) with ESMTP id BE6E11802A387;
        Thu,  4 Jul 2019 23:58:04 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: foot67_6385f1f675e2e
X-Filterd-Recvd-Size: 1388
Received: from joe-laptop.perches.com (cpe-23-242-196-136.socal.res.rr.com [23.242.196.136])
        (Authenticated sender: joe@perches.com)
        by omf14.hostedemail.com (Postfix) with ESMTPA;
        Thu,  4 Jul 2019 23:58:03 +0000 (UTC)
From:   Joe Perches <joe@perches.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 8/8] nfsd: Fix misuse of strlcpy
Date:   Thu,  4 Jul 2019 16:57:48 -0700
Message-Id: <b51141d12de77eb22101e81f9eb2c9cc44104d7a.1562283944.git.joe@perches.com>
X-Mailer: git-send-email 2.15.0
In-Reply-To: <cover.1562283944.git.joe@perches.com>
References: <cover.1562283944.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Probable cut&paste typo - use the correct field size.

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/nfsd/nfs4idmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 2961016097ac..d1f285245af8 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -83,7 +83,7 @@ ent_init(struct cache_head *cnew, struct cache_head *citm)
 	new->type = itm->type;
 
 	strlcpy(new->name, itm->name, sizeof(new->name));
-	strlcpy(new->authname, itm->authname, sizeof(new->name));
+	strlcpy(new->authname, itm->authname, sizeof(new->authname));
 }
 
 static void
-- 
2.15.0

