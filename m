Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32592 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886Ab1CCPOq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 10:14:46 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 6/9] NFSv4.1: remove GETATTR from ds writes
Date: Thu,  3 Mar 2011 10:13:46 -0500
Message-Id: <1299165229-3148-7-git-send-email-iisaman@netapp.com>
In-Reply-To: <1299165229-3148-1-git-send-email-iisaman@netapp.com>
References: <1299165229-3148-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Any WRITE compound directed to a data server needs to have the
GETATTR calls suppressed.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |    6 +++++-
 fs/nfs/nfs4xdr.c  |    8 +++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e79131b..e9f8a41 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3150,7 +3150,11 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
-	data->args.bitmask = server->cache_consistency_bitmask;
+	if (data->lseg) {
+		data->args.bitmask = NULL;
+		data->res.fattr = NULL;
+	} else
+		data->args.bitmask = server->cache_consistency_bitmask;
 	if (!data->write_done_cb)
 		data->write_done_cb = nfs4_write_done_cb;
 	data->res.server = server;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2380c45..c35880c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2275,7 +2275,8 @@ static void nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_write(xdr, args, &hdr);
 	req->rq_snd_buf.flags |= XDRBUF_WRITE;
-	encode_getfattr(xdr, args->bitmask, &hdr);
+	if (args->bitmask)
+		encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -5694,8 +5695,9 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_write(xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	if (res->fattr)
+		decode_getfattr(xdr, res->fattr, res->server,
+				!RPC_IS_ASYNC(rqstp->rq_task));
 	if (!status)
 		status = res->count;
 out:
-- 
1.7.2.1

