Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:39826 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757509Ab3J1W5L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 18:57:11 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>, Bruce Fields <bfields@fieldses.org>
CC: <stable@vger.kernel.org>
Subject: [PATCH 1/2] SUNRPC: gss_alloc_msg - choose _either_ a v0 message or a v1 message
Date: Mon, 28 Oct 2013 18:57:06 -0400
Message-ID: <1383001027-62282-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the missing 'break' to ensure that we don't corrupt a legacy 'v0' type
message by appending the 'v1'.

Cc: Bruce Fields <bfields@fieldses.org>
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 084656671d6e..cc24323d3045 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -482,6 +482,7 @@ gss_alloc_msg(struct gss_auth *gss_auth,
 	switch (vers) {
 	case 0:
 		gss_encode_v0_msg(gss_msg);
+		break;
 	default:
 		gss_encode_v1_msg(gss_msg, service_name, gss_auth->target_name);
 	};
-- 
1.8.3.1

