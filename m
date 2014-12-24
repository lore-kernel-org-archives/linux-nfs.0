Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:44408 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbaLXHN7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:13:59 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so6651655igd.7
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:13:58 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 23/49] nfs41: pass iomode through layoutreturn args
Date: Tue, 23 Dec 2014 23:13:02 -0800
Message-Id: <1419405208-25975-24-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

So that it is possible to return a specific iomode layouts.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/nfs4xdr.c        | 2 +-
 fs/nfs/pnfs.c           | 1 +
 include/linux/nfs_xdr.h | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7d8d7a4..3c3ff63 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2012,7 +2012,7 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	p = reserve_space(xdr, 16);
 	*p++ = cpu_to_be32(0);		/* reclaim. always 0 for now */
 	*p++ = cpu_to_be32(args->layout_type);
-	*p++ = cpu_to_be32(IOMODE_ANY);
+	*p++ = cpu_to_be32(args->iomode);
 	*p = cpu_to_be32(RETURN_FILE);
 	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, 0);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7e1bac1..1b544c1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -914,6 +914,7 @@ _pnfs_return_layout(struct inode *ino)
 	lrp->args.stateid = stateid;
 	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
 	lrp->args.inode = ino;
+	lrp->args.iomode = IOMODE_ANY;
 	lrp->args.layout = lo;
 	lrp->clp = NFS_SERVER(ino)->nfs_client;
 	lrp->cred = lo->plh_lc_cred;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 962f461..4fd7793 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -293,6 +293,7 @@ struct nfs4_layoutreturn_args {
 	struct nfs4_sequence_args seq_args;
 	struct pnfs_layout_hdr *layout;
 	struct inode *inode;
+	enum pnfs_iomode iomode;
 	nfs4_stateid stateid;
 	__u32   layout_type;
 };
-- 
1.9.3

