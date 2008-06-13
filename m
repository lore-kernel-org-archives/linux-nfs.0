From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/5] rpc: remove unnecessary assignment
Date: Fri, 13 Jun 2008 18:50:38 -0400
Message-ID: <1213397442-15611-2-git-send-email-bfields@citi.umich.edu>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43953 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755685AbYFMWun (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 18:50:43 -0400
In-Reply-To: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're just about to kfree() gss_auth, so there's no point to setting any
of its fields.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index cc12d5f..b42ec85 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -665,7 +665,6 @@ static void
 gss_free(struct gss_auth *gss_auth)
 {
 	rpc_unlink(gss_auth->dentry);
-	gss_auth->dentry = NULL;
 	gss_mech_put(gss_auth->mech);
 
 	kfree(gss_auth);
-- 
1.5.5.rc1

