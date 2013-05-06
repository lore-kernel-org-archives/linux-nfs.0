Return-Path: linux-nfs-owner@vger.kernel.org
Received: from jacques.telenet-ops.be ([195.130.132.50]:44685 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106Ab3EFHVI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 03:21:08 -0400
From: Geert Uytterhoeven <geert@linux-m68k.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] SUNRPC: Refactor gssx_dec_option_array() to kill uninitialized warning
Date: Mon,  6 May 2013 09:21:03 +0200
Message-Id: <1367824863-1857-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

net/sunrpc/auth_gss/gss_rpc_xdr.c: In function ‘gssx_dec_option_array’:
net/sunrpc/auth_gss/gss_rpc_xdr.c:258: warning: ‘creds’ may be used uninitialized in this function

Return early if count is zero, to make it clearer to the compiler (and the
casual reviewer) that no more processing is done.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/sunrpc/auth_gss/gss_rpc_xdr.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index 5c4c61d..a1e1b1a 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -264,25 +264,27 @@ static int gssx_dec_option_array(struct xdr_stream *xdr,
 	if (unlikely(p == NULL))
 		return -ENOSPC;
 	count = be32_to_cpup(p++);
-	if (count != 0) {
-		/* we recognize only 1 currently: CREDS_VALUE */
-		oa->count = 1;
+	if (!count)
+		return 0;
 
-		oa->data = kmalloc(sizeof(struct gssx_option), GFP_KERNEL);
-		if (!oa->data)
-			return -ENOMEM;
+	/* we recognize only 1 currently: CREDS_VALUE */
+	oa->count = 1;
 
-		creds = kmalloc(sizeof(struct svc_cred), GFP_KERNEL);
-		if (!creds) {
-			kfree(oa->data);
-			return -ENOMEM;
-		}
+	oa->data = kmalloc(sizeof(struct gssx_option), GFP_KERNEL);
+	if (!oa->data)
+		return -ENOMEM;
 
-		oa->data[0].option.data = CREDS_VALUE;
-		oa->data[0].option.len = sizeof(CREDS_VALUE);
-		oa->data[0].value.data = (void *)creds;
-		oa->data[0].value.len = 0;
+	creds = kmalloc(sizeof(struct svc_cred), GFP_KERNEL);
+	if (!creds) {
+		kfree(oa->data);
+		return -ENOMEM;
 	}
+
+	oa->data[0].option.data = CREDS_VALUE;
+	oa->data[0].option.len = sizeof(CREDS_VALUE);
+	oa->data[0].value.data = (void *)creds;
+	oa->data[0].value.len = 0;
+
 	for (i = 0; i < count; i++) {
 		gssx_buffer dummy = { 0, NULL };
 		u32 length;
-- 
1.7.0.4

