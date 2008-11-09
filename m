From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/9] rpc: remove unnecessary assignment
Date: Sun,  9 Nov 2008 16:04:35 -0500
Message-ID: <1226264683-28650-2-git-send-email-bfields@citi.umich.edu>
References: <20081109204621.GD27376@fieldses.org>
 <1226264683-28650-1-git-send-email-bfields@citi.umich.edu>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34893 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755842AbYKIVEp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2008 16:04:45 -0500
In-Reply-To: <1226264683-28650-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're just about to kfree() gss_auth, so there's no point to setting any
of its fields.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 853a414..07bb395 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -650,7 +650,6 @@ static void
 gss_free(struct gss_auth *gss_auth)
 {
 	rpc_unlink(gss_auth->dentry);
-	gss_auth->dentry = NULL;
 	gss_mech_put(gss_auth->mech);
 
 	kfree(gss_auth);
-- 
1.5.5.rc1

