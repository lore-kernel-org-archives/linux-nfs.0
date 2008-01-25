From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 041/100] nfsd: fix rsi_cache reference count leak
Date: Fri, 25 Jan 2008 18:16:21 -0500
Message-ID: <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47397 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762066AbYAYXRi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:38 -0500
In-Reply-To: <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For some reason we haven't been put()'ing the reference count here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/svcauth_gss.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index aa790bb..688cc31 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -975,6 +975,7 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 	struct kvec *resv = &rqstp->rq_res.head[0];
 	struct xdr_netobj tmpobj;
 	struct rsi *rsip, rsikey;
+	int ret;
 
 	/* Read the verifier; should be NULL: */
 	*authp = rpc_autherr_badverf;
@@ -1014,23 +1015,27 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 		/* No upcall result: */
 		return SVC_DROP;
 	case 0:
+		ret = SVC_DROP;
 		/* Got an answer to the upcall; use it: */
 		if (gss_write_init_verf(rqstp, rsip))
-			return SVC_DROP;
+			goto out;
 		if (resv->iov_len + 4 > PAGE_SIZE)
-			return SVC_DROP;
+			goto out;
 		svc_putnl(resv, RPC_SUCCESS);
 		if (svc_safe_putnetobj(resv, &rsip->out_handle))
-			return SVC_DROP;
+			goto out;
 		if (resv->iov_len + 3 * 4 > PAGE_SIZE)
-			return SVC_DROP;
+			goto out;
 		svc_putnl(resv, rsip->major_status);
 		svc_putnl(resv, rsip->minor_status);
 		svc_putnl(resv, GSS_SEQ_WIN);
 		if (svc_safe_putnetobj(resv, &rsip->out_token))
-			return SVC_DROP;
+			goto out;
 	}
-	return SVC_COMPLETE;
+	ret = SVC_COMPLETE;
+out:
+	cache_put(&rsip->h, &rsi_cache);
+	return ret;
 }
 
 /*
-- 
1.5.4.rc2.60.gb2e62

