From: NeilBrown <neilb@suse.de>
Subject: [PATCH 8/9] svcauth_gss: replace a trivial 'switch' with an 'if'
Date: Wed, 03 Feb 2010 17:31:31 +1100
Message-ID: <20100203063131.12945.21660.stgit@notabene.brown>
References: <20100203060657.12945.27293.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49553 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755623Ab0BCGjt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 01:39:49 -0500
In-Reply-To: <20100203060657.12945.27293.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
index 4db9562..2916f69 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1033,30 +1033,27 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
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


