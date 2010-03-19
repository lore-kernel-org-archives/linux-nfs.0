From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] SUNRPC: Fix a potential memory leak in auth_gss
Date: Fri, 19 Mar 2010 15:27:59 -0400
Message-ID: <1269026879.10771.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Dr. J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11898 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710Ab0CST3G convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Mar 2010 15:29:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

The function alloc_enc_pages() currently fails to release the pointer
rqstp->rq_enc_pages in the error path.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)


diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 0cfccc2..c389ccf 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1280,9 +1280,8 @@ alloc_enc_pages(struct rpc_rqst *rqstp)
 	rqstp->rq_release_snd_buf = priv_release_snd_buf;
 	return 0;
 out_free:
-	for (i--; i >= 0; i--) {
-		__free_page(rqstp->rq_enc_pages[i]);
-	}
+	rqstp->rq_enc_pages_num = i;
+	priv_release_snd_buf(rqstp);
 out:
 	return -EAGAIN;
 }

