Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:39365 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbeCTVDs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:03:48 -0400
Received: by mail-io0-f193.google.com with SMTP id v13so4068891iob.6
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 14:03:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] NFSv4: Don't ask for attributes when ACCESS is protected by a delegation
Date: Tue, 20 Mar 2018 17:03:11 -0400
Message-Id: <20180320210313.94429-8-trond.myklebust@primarydata.com>
In-Reply-To: <20180320210313.94429-7-trond.myklebust@primarydata.com>
References: <20180320210313.94429-1-trond.myklebust@primarydata.com>
 <20180320210313.94429-2-trond.myklebust@primarydata.com>
 <20180320210313.94429-3-trond.myklebust@primarydata.com>
 <20180320210313.94429-4-trond.myklebust@primarydata.com>
 <20180320210313.94429-5-trond.myklebust@primarydata.com>
 <20180320210313.94429-6-trond.myklebust@primarydata.com>
 <20180320210313.94429-7-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we hold a delegation, then the results of the ACCESS call are protected
anyway.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 13 ++++++++-----
 fs/nfs/nfs4xdr.c  |  6 ++++--
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index acb3350c7571..64dd0fa7afaa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4055,7 +4055,6 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_accessargs args = {
 		.fh = NFS_FH(inode),
-		.bitmask = server->cache_consistency_bitmask,
 		.access = entry->mask,
 	};
 	struct nfs4_accessres res = {
@@ -4069,14 +4068,18 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	};
 	int status = 0;
 
-	res.fattr = nfs_alloc_fattr();
-	if (res.fattr == NULL)
-		return -ENOMEM;
+	if (!nfs_have_delegated_attributes(inode)) {
+		res.fattr = nfs_alloc_fattr();
+		if (res.fattr == NULL)
+			return -ENOMEM;
+		args.bitmask = server->cache_consistency_bitmask;
+	}
 
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
 		nfs_access_set_mask(entry, res.access);
-		nfs_refresh_inode(inode, res.fattr);
+		if (res.fattr)
+			nfs_refresh_inode(inode, res.fattr);
 	}
 	nfs_free_fattr(res.fattr);
 	return status;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 79f1774b9d68..51264f5d9d2a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2102,7 +2102,8 @@ static void nfs4_xdr_enc_access(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_access(xdr, args->access, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
+	if (args->bitmask)
+		encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -6236,7 +6237,8 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_access(xdr, &res->supported, &res->access);
 	if (status != 0)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server);
+	if (res->fattr)
+		decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
-- 
2.14.3

