Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:39534 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726444AbeGLSgE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jul 2018 14:36:04 -0400
Received: by mail-io0-f194.google.com with SMTP id e13-v6so29063706iof.6
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jul 2018 11:25:21 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id u15-v6sm9730818iog.62.2018.07.12.11.25.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 11:25:19 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: Parse the results of layoutget on open even if permissions checks fail
Date: Thu, 12 Jul 2018 14:24:56 -0400
Message-Id: <20180712182456.8701-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180712182456.8701-1-trond.myklebust@hammerspace.com>
References: <20180712182456.8701-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Even if the results of the permissions checks failed, we should parse
the results of the layout on open call so that we can return the
layout if required.
Note that we also want to ignore the sequence counter for whether or not
a layout recall occurred. If the recall pertained to our OPEN, then the
callback will know, and will attempt to wait for us to finih processing
anyway.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_proc.c    | 2 --
 fs/nfs/nfs4proc.c         | 5 +++--
 fs/nfs/pnfs.c             | 4 ----
 include/linux/nfs_fs_sb.h | 1 -
 include/linux/nfs_xdr.h   | 1 -
 5 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index efca3d6c89f2..43ba390bb653 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -331,8 +331,6 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				    struct cb_layoutrecallargs *args)
 {
-	write_seqcount_begin(&clp->cl_callback_count);
-	write_seqcount_end(&clp->cl_callback_count);
 	if (args->cbl_recall_type == RETURN_FILE)
 		return initiate_file_draining(clp, args);
 	return initiate_bulk_draining(clp, args);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0a95f0a76343..2da29bc1f5d9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2834,6 +2834,9 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 				nfs_save_change_attribute(d_inode(opendata->dir)));
 	}
 
+	/* Parse layoutget results before we check for access */
+	pnfs_parse_lgopen(state->inode, opendata->lgp, ctx);
+
 	ret = nfs4_opendata_access(sp->so_cred, opendata, state, fmode, flags);
 	if (ret != 0)
 		goto out;
@@ -2842,8 +2845,6 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 		nfs_inode_attach_open_context(ctx);
 		if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
 			nfs4_schedule_stateid_recovery(server, state);
-		else
-			pnfs_parse_lgopen(state->inode, opendata->lgp, ctx);
 	}
 
 out:
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 030c39c107c2..7fdac8b504dd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1018,7 +1018,6 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
 	nfs4_stateid_copy(&lgp->args.stateid, stateid);
 	lgp->gfp_flags = gfp_flags;
 	lgp->cred = get_rpccred(ctx->cred);
-	lgp->callback_count = raw_seqcount_begin(&server->nfs_client->cl_callback_count);
 	return lgp;
 }
 
@@ -2181,9 +2180,6 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 	} else
 		lo = NFS_I(lgp->args.inode)->layout;
 
-	if (read_seqcount_retry(&srv->nfs_client->cl_callback_count,
-				lgp->callback_count))
-		return;
 	lseg = pnfs_layout_process(lgp);
 	if (!IS_ERR(lseg)) {
 		iomode = lgp->args.range.iomode;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 74ae3e1d19a0..2c18d618604e 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -28,7 +28,6 @@ struct nfs41_impl_id;
 struct nfs_client {
 	refcount_t		cl_count;
 	atomic_t		cl_mds_count;
-	seqcount_t		cl_callback_count;
 	int			cl_cons_state;	/* current construction state (-ve: init error) */
 #define NFS_CS_READY		0		/* ready to be used */
 #define NFS_CS_INITING		1		/* busy initialising */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 712eed156d09..3b7325cfb291 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -271,7 +271,6 @@ struct nfs4_layoutget {
 	struct nfs4_layoutget_args args;
 	struct nfs4_layoutget_res res;
 	struct rpc_cred *cred;
-	unsigned callback_count;
 	gfp_t gfp_flags;
 };
 
-- 
2.17.1

