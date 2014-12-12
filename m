Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:21906 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541AbaLLWdH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2014 17:33:07 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] SUNRPC add rpc_gss_svc_t to gssd upcall
Date: Fri, 12 Dec 2014 17:33:00 -0500
Message-ID: <1418423580-1212-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Otherwise rpc.gssd will send a V4 NULL RPCSEC_GSS_INIT call with an RPCSEC_GSS
service of rpc_gss_svc_none for rpc_sec_gss_svc_integrity/privacy requests
from the kernel.

This change does not break current versions of rpc.gssd, and there is a
companion rpc.gssd patch: GSSD add rpc_gss_svc_t to the gssd upcall

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 53ed8d3..48054dc 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -449,8 +449,9 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 	size_t buflen = sizeof(gss_msg->databuf);
 	int len;
 
-	len = scnprintf(p, buflen, "mech=%s uid=%d ", mech->gm_name,
-			from_kuid(&init_user_ns, gss_msg->uid));
+	len = scnprintf(p, buflen, "mech=%s uid=%d svc=%d ", mech->gm_name,
+			from_kuid(&init_user_ns, gss_msg->uid),
+			gss_msg->auth->service);
 	buflen -= len;
 	p += len;
 	gss_msg->msg.len = len;
-- 
1.9.3 (Apple Git-50)

