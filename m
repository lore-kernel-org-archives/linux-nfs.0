Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:62292 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753363AbcLWQGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:06:31 -0500
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 01/16] SUNRPC handle unsupported RPC_GSS_SVC_CHANNEL_PROT
Date: Fri, 23 Dec 2016 11:04:13 -0500
Message-ID: <1482509068-24516-2-git-send-email-andros@netapp.com>
In-Reply-To: <1482509068-24516-1-git-send-email-andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 16cea00..96135da 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1869,6 +1869,11 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 	case RPC_GSS_SVC_PRIVACY:
 		status = gss_wrap_req_priv(cred, ctx, encode, rqstp, p, obj);
 		break;
+	case RPC_GSS_SVC_CHANNEL_PROT:
+		status = -EIO;
+		pr_warn("RPC    Unsupported service level %d\n",
+			gss_cred->gc_service);
+		break;
 	}
 out:
 	gss_put_ctx(ctx);
@@ -1979,6 +1984,11 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 		if (status)
 			goto out;
 		break;
+	case RPC_GSS_SVC_CHANNEL_PROT:
+		status = -EIO;
+		pr_warn("RPC    Unsupported service level %d\n",
+			gss_cred->gc_service);
+		goto out;
 	}
 	/* take into account extra slack for integrity and privacy cases: */
 	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + (p - savedp)
-- 
1.8.3.1

