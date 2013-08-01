Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49860 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754970Ab3HANR1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 09:17:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] svcrpc: set cr_gss_mech from gss-proxy as well as legacy upcall
Date: Thu,  1 Aug 2013 09:17:22 -0400
Message-Id: <1375363042-14440-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1375363042-14440-1-git-send-email-bfields@redhat.com>
References: <1375363042-14440-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The change made to rsc_parse() in
0dc1531aca7fd1440918bd55844a054e9c29acad "svcrpc: store gss mech in
svc_cred" should also have been propagated to the gss-proxy codepath.
This fixes a crash in the gss-proxy case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index d0347d1..09fb638 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1180,6 +1180,7 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
 		gm = gss_mech_get_by_OID(&ud->mech_oid);
 		if (!gm)
 			goto out;
+		rsci.cred.cr_gss_mech = gm;
 
 		status = -EINVAL;
 		/* mech-specific data: */
@@ -1195,7 +1196,6 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
 	rscp = rsc_update(cd, &rsci, rscp);
 	status = 0;
 out:
-	gss_mech_put(gm);
 	rsc_free(&rsci);
 	if (rscp)
 		cache_put(&rscp->h, cd);
-- 
1.7.9.5

