From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/27] NSM: Add xdr_stream-based XDR encoders
Date: Fri, 05 Dec 2008 19:02:22 -0500
Message-ID: <20081206000222.24075.45214.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:37158 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754813AbYLFAE5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:57 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce xdr_stream-based XDR decoder functions.  These are more
careful about preventing RPC buffer overflows.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index cf85c0f..0f8e029 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -377,6 +377,23 @@ xdr_decode_stat_res(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
 	return 0;
 }
 
+static int xdr_dec_stat_res(struct rpc_rqst *rqstp, __be32 *p,
+			    struct nsm_res *resp)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	p = xdr_inline_decode(&xdr, 2 * sizeof(u32));
+	if (unlikely(p == NULL))
+		return -EIO;
+	resp->status = ntohl(*p++);
+	resp->state = ntohl(*p);
+
+	dprintk("lockd: xdr_dec_stat_res status %d state %d\n",
+			resp->status, resp->state);
+	return 0;
+}
+
 static int
 xdr_decode_stat(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
 {
@@ -384,6 +401,21 @@ xdr_decode_stat(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
 	return 0;
 }
 
+static int xdr_dec_stat(struct rpc_rqst *rqstp, __be32 *p,
+			struct nsm_res *resp)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	p = xdr_inline_decode(&xdr, sizeof(u32));
+	if (unlikely(p == NULL))
+		return -EIO;
+	resp->state = ntohl(*p);
+
+	dprintk("lockd: xdr_dec_stat state %d\n", resp->state);
+	return 0;
+}
+
 #define SM_my_name_sz	(1+XDR_QUADLEN(SM_MAXSTRLEN))
 #define SM_my_id_sz	(SM_my_name_sz+3)
 #define SM_mon_name_sz	(1+XDR_QUADLEN(SM_MAXSTRLEN))

