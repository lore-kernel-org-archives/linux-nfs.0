Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26986 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757424Ab1BKQzA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 11:55:00 -0500
Received: from localhost.localdomain (manjua-lxp.hq.netapp.com [10.58.49.248] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p1BGshZ6002533
	for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 08:54:45 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] wave4: remove GETATTR from ds write
Date: Fri, 11 Feb 2011 11:54:35 -0500
Message-Id: <1297443279-19813-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
References: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Any WRITE compounds directed to a data server need to have the
GETATTR calls suppressed.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |    6 +++++-
 fs/nfs/nfs4xdr.c        |    8 +++++---
 include/linux/nfs_xdr.h |    1 +
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f396853..a40a281 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3144,7 +3144,11 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
-	data->args.bitmask = server->cache_consistency_bitmask;
+	if (data->ds_clp) {
+		data->args.bitmask = NULL;
+		data->res.fattr = NULL;
+	} else
+		data->args.bitmask = server->cache_consistency_bitmask;
 	data->res.server = server;
 	data->timestamp   = jiffies;
 
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
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d60ec32..726ec2a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1039,6 +1039,7 @@ struct nfs_write_data {
 	struct nfs_writeargs	args;		/* argument struct */
 	struct nfs_writeres	res;		/* result struct */
 	struct pnfs_layout_segment *lseg;
+	struct nfs_client	*ds_clp;	/* pNFS data server */
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
-- 
1.7.2.1

