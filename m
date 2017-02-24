Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52563 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751268AbdBXWUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:04 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 01/17] SUNRPC handle unsupported RPCSEC_GSS security service
Date: Fri, 24 Feb 2017 17:19:37 -0500
Message-ID: <20170224221953.5502-2-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
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
index cdeb1d8..d8395ce 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1869,6 +1869,11 @@ gss_wrap_req(struct rpc_task *task,
 	case RPC_GSS_SVC_PRIVACY:
 		status = gss_wrap_req_priv(cred, ctx, encode, rqstp, p, obj);
 		break;
+	default:
+		status = -EIO;
+		pr_warn("RPC    Unsupported service level %d\n",
+			gss_cred->gc_service);
+		break;
 	}
 out:
 	gss_put_ctx(ctx);
@@ -1979,6 +1984,11 @@ gss_unwrap_resp(struct rpc_task *task,
 		if (status)
 			goto out;
 		break;
+	default:
+		status = -EIO;
+		pr_warn("RPC    Unsupported service level %d\n",
+			gss_cred->gc_service);
+		goto out;
 	}
 	/* take into account extra slack for integrity and privacy cases: */
 	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + (p - savedp)
-- 
2.9.3

