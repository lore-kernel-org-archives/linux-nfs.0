Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:38840 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755740Ab2GXPsr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2012 11:48:47 -0400
From: Vivek Trivedi <vtrivedi018@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Vivek Trivedi <vtrivedi018@gmail.com>, Namjae Jeon <linkinjeon@gmail.com>
Subject: [PATCH] nfsd4: fix cr_principal comparison check in same_creds
Date: Tue, 24 Jul 2012 21:18:20 +0530
Message-Id: <1343144900-4522-1-git-send-email-vtrivedi018@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a wrong check for same cr_principal in same_creds

Signed-off-by: Vivek Trivedi <vtrivedi018@gmail.com>
Signed-off-by: Namjae Jeon <linkinjeon@gmail.com>
---
 fs/nfsd/nfs4state.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 94effd5..e8ead04 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1215,7 +1215,7 @@ static bool groups_equal(struct group_info *g1, struct group_info *g2)
 	return true;
 }
 
-static int
+static bool
 same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
 {
 	if ((cr1->cr_flavor != cr2->cr_flavor)
@@ -1227,7 +1227,7 @@ same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
 		return true;
 	if (!cr1->cr_principal || !cr2->cr_principal)
 		return false;
-	return 0 == strcmp(cr1->cr_principal, cr1->cr_principal);
+	return 0 == strcmp(cr1->cr_principal, cr2->cr_principal);
 }
 
 static void gen_clid(struct nfs4_client *clp)
-- 
1.7.1

