From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] SUNRPC: IS_ERR/PTR_ERR confusion
Date: Mon, 07 Dec 2009 12:34:28 +0100
Message-ID: <4B1CE844.1040108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:44462 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933740AbZLGLdX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 06:33:23 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

IS_ERR returns 1 or 0, PTR_ERR returns the error value.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index fc6a43c..129d75e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -485,7 +485,7 @@ gss_refresh_upcall(struct rpc_task *task)
 	dprintk("RPC: %5u gss_refresh_upcall for uid %u\n", task->tk_pid,
 								cred->cr_uid);
 	gss_msg = gss_setup_upcall(task->tk_client, gss_auth, cred);
-	if (IS_ERR(gss_msg) == -EAGAIN) {
+	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		/* XXX: warning on the first, under the assumption we
 		 * shouldn't normally hit this case on a refresh. */
 		warn_gssd();
