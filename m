From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/24] SUNRPC: Address potential buffer length overflow in
	svc_sendto
Date: Mon, 14 Apr 2008 12:27:08 -0400
Message-ID: <20080414162708.12741.71691.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:48932 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761441AbYDNQ1d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:27:33 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paranoia: Ensure a negative error value return from kernel_sendpage never
matches a large buffer length.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 6d4162b..a8ae279 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -200,7 +200,7 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 		flags = 0;
 	len = kernel_sendpage(sock, rqstp->rq_respages[0], 0,
 				  xdr->head[0].iov_len, flags);
-	if (len != xdr->head[0].iov_len)
+	if (len < 0 || len != xdr->head[0].iov_len)
 		goto out;
 	slen -= xdr->head[0].iov_len;
 	if (slen == 0)

