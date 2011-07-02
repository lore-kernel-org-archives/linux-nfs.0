Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50637 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752661Ab1GBI6h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Jul 2011 04:58:37 -0400
Message-ID: <4E0EDE78.1060208@cn.fujitsu.com>
Date: Sat, 02 Jul 2011 17:01:44 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2 v2] nfsd41: error out when client sets maxreq_sz or, maxresp_sz
 too small
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

According to RFC5661, 18.36.3, 

 "if the client selects a value for ca_maxresponsesize such that
  a replier on a channel could never send a response,the server
  SHOULD return NFS4ERR_TOOSMALL in the CREATE_SESSION reply."

This patch let server error out when client sets maxreq_sz less than
SEQUENCE request size, and maxresp_sz less than a SEQUENCE reply size.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4xdr.c |   26 +++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9901811..bece272 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1135,11 +1135,25 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
 {
 	DECODE_HEAD;
 
-	u32 dummy;
+	struct xdr_buf *xb = &argp->rqstp->rq_arg;
+	u32 dummy, minreqlen = 0, minresplen = 0;
 	char *machine_name;
 	int i;
 	int nr_secflavs;
 
+	/* RPC header length and tag, minorversion, Opt count*/
+	minreqlen = (char *)argp->p - ((char *)argp->end - xb->len);
+	/* length with a SEQUENCE operation */
+	minreqlen = minreqlen + sizeof(struct nfs4_sessionid)
+		    + 4 * sizeof(__be32);
+
+	/* RPC header, status, tag len */
+	minresplen = argp->rqstp->rq_res.head[0].iov_len + 2 * sizeof(__be32)
+		     /* tag, opt count, opcode, op status */
+		     + ALIGN(argp->taglen, 4) + 3 * sizeof(__be32)
+		     /* sessionid, seqid, 3 * slotid, status*/
+		     + sizeof(struct nfs4_sessionid) + 5 * sizeof(__be32);
+
 	READ_BUF(16);
 	COPYMEM(&sess->clientid, 8);
 	READ32(sess->seqid);
@@ -1149,7 +1163,17 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
 	READ_BUF(28);
 	READ32(dummy); /* headerpadsz is always 0 */
 	READ32(sess->fore_channel.maxreq_sz);
+	if (sess->fore_channel.maxreq_sz < minreqlen) {
+		status = nfserr_toosmall;
+		goto out;
+	}
+
 	READ32(sess->fore_channel.maxresp_sz);
+	if (sess->fore_channel.maxresp_sz < minresplen) {
+		status = nfserr_toosmall;
+		goto out;
+	}
+
 	READ32(sess->fore_channel.maxresp_cached);
 	READ32(sess->fore_channel.maxops);
 	READ32(sess->fore_channel.maxreqs);
-- 
1.7.5.4



