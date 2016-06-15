Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932130AbcFONkd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2016 09:40:33 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RESEND] sunrpc: add gss minor status to svcauth_gss_proxy_init
Date: Wed, 15 Jun 2016 09:40:31 -0400
Message-Id: <1465998031-53086-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

GSS-Proxy doesn't produce very much debug logging at all.  Printing out
the gss minor status will aid in troubleshooting if the
GSS_Accept_sec_context upcall fails.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index e085f5a..1d28181 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1230,8 +1230,9 @@ static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
 	if (status)
 		goto out;
 
-	dprintk("RPC:       svcauth_gss: gss major status = %d\n",
-			ud.major_status);
+	dprintk("RPC:       svcauth_gss: gss major status = %d "
+			"minor status = %d\n",
+			ud.major_status, ud.minor_status);
 
 	switch (ud.major_status) {
 	case GSS_S_CONTINUE_NEEDED:
-- 
2.4.11

