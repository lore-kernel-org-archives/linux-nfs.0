Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:8606 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756738AbcLWQGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:06:33 -0500
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 04/16] SUNRPC GSSv3: base definitions
Date: Fri, 23 Dec 2016 11:04:16 -0500
Message-ID: <1482509068-24516-5-git-send-email-andros@netapp.com>
In-Reply-To: <1482509068-24516-1-git-send-email-andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 36eebc4..4ab63a9 100644
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
@@ -66,6 +71,7 @@ struct rpc_gss_init_res {
 
 struct gss_cl_ctx {
 	atomic_t		count;
+	u32			gc_v;
 	enum rpc_gss_proc	gc_proc;
 	u32			gc_seq;
 	spinlock_t		gc_seq_lock;
-- 
1.8.3.1

