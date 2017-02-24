Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52563 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751163AbdBXWUF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:05 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 04/17] SUNRPC GSSv3: base definitions
Date: Fri, 24 Feb 2017 17:19:40 -0500
Message-ID: <20170224221953.5502-5-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 36eebc4..8939db4 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -18,6 +18,7 @@
 #include <linux/sunrpc/gss_api.h>
 
 #define RPC_GSS_VERSION		1
+#define RPC_GSS3_VERSION	3
 
 #define MAXSEQ 0x80000000 /* maximum legal sequence number, from rfc 2203 */
 
@@ -25,13 +26,17 @@ enum rpc_gss_proc {
 	RPC_GSS_PROC_DATA = 0,
 	RPC_GSS_PROC_INIT = 1,
 	RPC_GSS_PROC_CONTINUE_INIT = 2,
-	RPC_GSS_PROC_DESTROY = 3
+	RPC_GSS_PROC_DESTROY = 3,
+	RPC_GSS_PROC_BIND_CHANNEL = 4,	/* GSS2, not used */
+	RPC_GSS_PROC_CREATE = 5,	/* GSS3 */
+	RPC_GSS_PROC_LIST = 6		/* GSS3 */
 };
 
 enum rpc_gss_svc {
 	RPC_GSS_SVC_NONE = 1,
 	RPC_GSS_SVC_INTEGRITY = 2,
-	RPC_GSS_SVC_PRIVACY = 3
+	RPC_GSS_SVC_PRIVACY = 3,
+	RPC_GSS_SVC_CHANNEL_PROT = 4	/* GSS2, not used */
 };
 
 /* on-the-wire gss cred: */
-- 
2.9.3

