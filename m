Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx61.netapp.com ([216.240.31.181]:5252 "EHLO mx61.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752596AbdG1Ubf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:31:35 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <bfields@redhat.com>,
        <olga.kornievskaia@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 6 02/12] SUNRPC GSSv3: base definitions
Date: Fri, 28 Jul 2017 16:21:48 -0400
Message-ID: <1501273318-14200-3-git-send-email-andros@netapp.com>
In-Reply-To: <1501273318-14200-1-git-send-email-andros@netapp.com>
References: <1501273318-14200-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 36eebc4..cf5e694 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -18,6 +18,7 @@
 #include <linux/sunrpc/gss_api.h>
 
 #define RPC_GSS_VERSION		1
+#define RPC_GSS3_VERSION	3
 
 #define MAXSEQ 0x80000000 /* maximum legal sequence number, from rfc 2203 */
 
@@ -25,7 +26,10 @@ enum rpc_gss_proc {
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
-- 
1.8.3.1

