Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay107.isp.belgacom.be ([195.238.20.134]:48291 "EHLO
	mailrelay107.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753645AbbC3VNs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 17:13:48 -0400
From: Fabian Frederick <fabf@skynet.be>
To: linux-kernel@vger.kernel.org
Cc: Fabian Frederick <fabf@skynet.be>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH 7/9 net-next] sunrpc: replace if/BUG by BUG_ON
Date: Mon, 30 Mar 2015 23:13:15 +0200
Message-Id: <1427749998-28464-7-git-send-email-fabf@skynet.be>
In-Reply-To: <1427749998-28464-1-git-send-email-fabf@skynet.be>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 9 +++------
 net/sunrpc/svc_xprt.c             | 3 +--
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 1095be9..09f8a1c6 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -840,11 +840,9 @@ unwrap_integ_data(struct svc_rqst *rqstp, struct xdr_buf *buf, u32 seq, struct g
 		return stat;
 	if (integ_len > buf->len)
 		return stat;
-	if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_len))
-		BUG();
+	BUG_ON(xdr_buf_subsegment(buf, &integ_buf, 0, integ_len));
 	/* copy out mic... */
-	if (read_u32_from_xdr_buf(buf, integ_len, &mic.len))
-		BUG();
+	BUG_ON(read_u32_from_xdr_buf(buf, integ_len, &mic.len));
 	if (mic.len > RPC_MAX_AUTH_SIZE)
 		return stat;
 	mic.data = kmalloc(mic.len, GFP_KERNEL);
@@ -1595,8 +1593,7 @@ svcauth_gss_wrap_resp_integ(struct svc_rqst *rqstp)
 	BUG_ON(integ_len % 4);
 	*p++ = htonl(integ_len);
 	*p++ = htonl(gc->gc_seq);
-	if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len))
-		BUG();
+	BUG_ON(xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len));
 	if (resbuf->tail[0].iov_base == NULL) {
 		if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE > PAGE_SIZE)
 			goto out_err;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 163ac45..2f82e8b 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -960,8 +960,7 @@ static void svc_delete_xprt(struct svc_xprt *xprt)
 	struct svc_deferred_req *dr;
 
 	/* Only do this once */
-	if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))
-		BUG();
+	BUG_ON(test_and_set_bit(XPT_DEAD, &xprt->xpt_flags));
 
 	dprintk("svc: svc_delete_xprt(%p)\n", xprt);
 	xprt->xpt_ops->xpo_detach(xprt);
-- 
1.9.1

