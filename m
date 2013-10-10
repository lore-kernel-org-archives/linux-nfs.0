Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59337 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755459Ab3JJPPI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Oct 2013 11:15:08 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, Simo Sorce <simo@redhat.com>
Subject: [PATCH 2/4] svcrpc: fix error-handling on badd gssproxy downcall
Date: Thu, 10 Oct 2013 11:15:01 -0400
Message-Id: <1381418103-3852-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1381418103-3852-1-git-send-email-bfields@redhat.com>
References: <1381418103-3852-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

For every other problem here we bail out with an error, but here for
some reason we're setting a negative cache entry (with, note, an
undefined expiry).

It seems simplest just to bail out in the same way as we do in other
cases.

Cc: Simo Sorce <simo@redhat.com>
Reported-by: Andi Kleen <andi@firstfloor.org>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 09fb638..008cdad 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1167,8 +1167,8 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
 	if (!ud->found_creds) {
 		/* userspace seem buggy, we should always get at least a
 		 * mapping to nobody */
-		dprintk("RPC:       No creds found, marking Negative!\n");
-		set_bit(CACHE_NEGATIVE, &rsci.h.flags);
+		dprintk("RPC:       No creds found!\n");
+		goto out;
 	} else {
 
 		/* steal creds */
-- 
1.7.9.5

