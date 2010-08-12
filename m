Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35502 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281Ab0HLHGF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Aug 2010 03:06:05 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 12 Aug 2010 17:04:07 +1000
Subject: [PATCH 5/6] svcauth_gss: replace a trivial 'switch' with an 'if'
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100812070407.11459.92833.stgit@localhost.localdomain>
In-Reply-To: <20100812065722.11459.18978.stgit@localhost.localdomain>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Code like:

  switch(xxx) {
  case -error1:
  case -error2:
     ..
     return;
  case 0:
     stuff;
  }

  can more naturally be written:

  if (xxx < 0)
      return;

  stuff;

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/auth_gss/svcauth_gss.c |   41 +++++++++++++++++--------------------
 1 files changed, 19 insertions(+), 22 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index ed005af..dec2a6f 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1034,30 +1034,27 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
 	rsi_free(&rsikey);
 	if (!rsip)
 		return SVC_CLOSE;
-	switch (cache_check(&rsi_cache, &rsip->h, &rqstp->rq_chandle)) {
-	case -EAGAIN:
-	case -ETIMEDOUT:
-	case -ENOENT:
+	if (cache_check(&rsi_cache, &rsip->h, &rqstp->rq_chandle) < 0)
 		/* No upcall result: */
 		return SVC_CLOSE;
-	case 0:
-		ret = SVC_CLOSE;
-		/* Got an answer to the upcall; use it: */
-		if (gss_write_init_verf(rqstp, rsip))
-			goto out;
-		if (resv->iov_len + 4 > PAGE_SIZE)
-			goto out;
-		svc_putnl(resv, RPC_SUCCESS);
-		if (svc_safe_putnetobj(resv, &rsip->out_handle))
-			goto out;
-		if (resv->iov_len + 3 * 4 > PAGE_SIZE)
-			goto out;
-		svc_putnl(resv, rsip->major_status);
-		svc_putnl(resv, rsip->minor_status);
-		svc_putnl(resv, GSS_SEQ_WIN);
-		if (svc_safe_putnetobj(resv, &rsip->out_token))
-			goto out;
-	}
+
+	ret = SVC_CLOSE;
+	/* Got an answer to the upcall; use it: */
+	if (gss_write_init_verf(rqstp, rsip))
+		goto out;
+	if (resv->iov_len + 4 > PAGE_SIZE)
+		goto out;
+	svc_putnl(resv, RPC_SUCCESS);
+	if (svc_safe_putnetobj(resv, &rsip->out_handle))
+		goto out;
+	if (resv->iov_len + 3 * 4 > PAGE_SIZE)
+		goto out;
+	svc_putnl(resv, rsip->major_status);
+	svc_putnl(resv, rsip->minor_status);
+	svc_putnl(resv, GSS_SEQ_WIN);
+	if (svc_safe_putnetobj(resv, &rsip->out_token))
+		goto out;
+
 	ret = SVC_COMPLETE;
 out:
 	cache_put(&rsip->h, &rsi_cache);


