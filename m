Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:43164 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106Ab3KTSAZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 13:00:25 -0500
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] SUNRPC: do not fail gss proc NULL calls with EACCES
Date: Wed, 20 Nov 2013 13:00:17 -0500
Message-ID: <1384970417-6825-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Otherwise RPCSEC_GSS_DESTROY messages are not sent.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 97912b4..42fdfc6 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1517,7 +1517,7 @@ out:
 static int
 gss_refresh_null(struct rpc_task *task)
 {
-	return -EACCES;
+	return 0;
 }
 
 static __be32 *
-- 
1.8.3.1

