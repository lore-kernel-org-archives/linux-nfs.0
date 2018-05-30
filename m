Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:41358 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932069AbeE3SG2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:28 -0400
Received: by mail-io0-f194.google.com with SMTP id t5-v6so10115154ioa.8
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:28 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.26
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:27 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/19] pnfs: Add barrier to prevent lgopen using LAYOUTGET during recall
Date: Wed, 30 May 2018 14:05:47 -0400
Message-Id: <20180530180553.38769-14-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-13-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
 <20180530180553.38769-6-trond.myklebust@hammerspace.com>
 <20180530180553.38769-7-trond.myklebust@hammerspace.com>
 <20180530180553.38769-8-trond.myklebust@hammerspace.com>
 <20180530180553.38769-9-trond.myklebust@hammerspace.com>
 <20180530180553.38769-10-trond.myklebust@hammerspace.com>
 <20180530180553.38769-11-trond.myklebust@hammerspace.com>
 <20180530180553.38769-12-trond.myklebust@hammerspace.com>
 <20180530180553.38769-13-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

Since the LAYOUTGET on OPEN can be sent without prior inode information,
existing methods to prevent LAYOUTGET from being sent while processing
CB_LAYOUTRECALL don't work.  Track if a recall occurred while LAYOUTGET
was being sent, and if so ignore the results.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_proc.c    | 2 ++
 fs/nfs/pnfs.c             | 8 +++++++-
 include/linux/nfs_fs_sb.h | 1 +
 include/linux/nfs_xdr.h   | 1 +
 4 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a50d7813e3ea..d561161b7c3e 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -322,6 +322,8 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				    struct cb_layoutrecallargs *args)
 {
+	write_seqcount_begin(&clp->cl_callback_count);
+	write_seqcount_end(&clp->cl_callback_count);
 	if (args->cbl_recall_type == RETURN_FILE)
 		return initiate_file_draining(clp, args);
 	return initiate_bulk_draining(clp, args);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b2158e5bf7f7..5621b85a5c24 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -979,6 +979,7 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
 	nfs4_stateid_copy(&lgp->args.stateid, stateid);
 	lgp->gfp_flags = gfp_flags;
 	lgp->cred = get_rpccred(ctx->cred);
+	lgp->callback_count = raw_seqcount_begin(&server->nfs_client->cl_callback_count);
 	return lgp;
 }
 
@@ -2051,6 +2052,7 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 {
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg;
+	struct nfs_server *srv = NFS_SERVER(ino);
 	u32 iomode;
 
 	if (!lgp)
@@ -2066,7 +2068,7 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 			/* FIXME - Any error not listed above permanently
 			 * halts lgopen attempts.
 			 */
-			NFS_SERVER(ino)->caps &= ~NFS_CAP_LGOPEN;
+			srv->caps &= ~NFS_CAP_LGOPEN;
 		}
 		return;
 	}
@@ -2079,6 +2081,9 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 		lo = NFS_I(lgp->args.inode)->layout;
 	pnfs_get_layout_hdr(lo);
 
+	if (read_seqcount_retry(&srv->nfs_client->cl_callback_count,
+				lgp->callback_count))
+		goto out;
 	lseg = pnfs_layout_process(lgp);
 	atomic_dec(&lo->plh_outstanding);
 	if (IS_ERR(lseg)) {
@@ -2089,6 +2094,7 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 		pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
 		pnfs_put_lseg(lseg);
 	}
+out:
 	pnfs_clear_first_layoutget(lo);
 	pnfs_put_layout_hdr(lo);
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 2c18d618604e..74ae3e1d19a0 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -28,6 +28,7 @@ struct nfs41_impl_id;
 struct nfs_client {
 	refcount_t		cl_count;
 	atomic_t		cl_mds_count;
+	seqcount_t		cl_callback_count;
 	int			cl_cons_state;	/* current construction state (-ve: init error) */
 #define NFS_CS_READY		0		/* ready to be used */
 #define NFS_CS_INITING		1		/* busy initialising */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b36be7a703ea..b777eb7da15e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -271,6 +271,7 @@ struct nfs4_layoutget {
 	struct nfs4_layoutget_args args;
 	struct nfs4_layoutget_res res;
 	struct rpc_cred *cred;
+	unsigned callback_count;
 	gfp_t gfp_flags;
 };
 
-- 
2.17.0

