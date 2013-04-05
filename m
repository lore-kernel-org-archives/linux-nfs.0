Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24935 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162912Ab3DEWhR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 18:37:17 -0400
From: Simo Sorce <simo@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Cc: Steve Dickson <steved@redhat.com>
Subject: [PATCH 1/1] Fix private data giveaway
Date: Fri,  5 Apr 2013 18:37:04 -0400
Message-Id: <1365201425-21702-2-git-send-email-simo@redhat.com>
In-Reply-To: <1365201425-21702-1-git-send-email-simo@redhat.com>
References: <1365201425-21702-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the private data is given away the gss context also needs to go,
because the caller may destroy it, such as when the context is exported
into a lucid context to hand it to the kernel.
---
 src/auth_gss.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/src/auth_gss.c b/src/auth_gss.c
index 81ae8aee316c6f42f317f81cd1438369fb2102c5..703bc3f7b42236b0d4cc3ddbd8935df2aaccf85a 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -269,6 +269,7 @@ authgss_get_private_data(AUTH *auth, struct authgss_private_data *pd)
 	 * send an RPCSEC_GSS_DESTROY request which might inappropriately
 	 * destroy the context.
 	 */
+        gd->ctx = GSS_C_NO_CONTEXT;
 	gd->gc.gc_ctx.length = 0;
 	gd->gc.gc_ctx.value = NULL;
 
@@ -284,7 +285,8 @@ authgss_free_private_data(struct authgss_private_data *pd)
 	if (!pd)
 		return (FALSE);
 
-	pd->pd_ctx = NULL;
+	if (pd->pd_ctx != GSS_C_NO_CONTEXT)
+		gss_delete_sec_context(&min_stat, &pd->pd_ctx, NULL);
 	gss_release_buffer(&min_stat, &pd->pd_ctx_hndl);
 	memset(&pd->pd_ctx_hndl, 0, sizeof(pd->pd_ctx_hndl));
 	pd->pd_seq_win = 0;
-- 
1.8.1.4

