Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f173.google.com ([209.85.192.173]:49601 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753870AbbANQqO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 11:46:14 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so10726814pdb.4
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 08:46:13 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 42/50] nfs41: add range to layoutreturn args
Date: Wed, 14 Jan 2015 08:44:48 -0800
Message-Id: <1421253896-73106-43-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
References: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

So that callers can specify which range to return.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/nfs4xdr.c        | 6 +++---
 fs/nfs/pnfs.c           | 4 +++-
 include/linux/nfs_xdr.h | 2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3c3ff63..56d4c91 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2012,11 +2012,11 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	p = reserve_space(xdr, 16);
 	*p++ = cpu_to_be32(0);		/* reclaim. always 0 for now */
 	*p++ = cpu_to_be32(args->layout_type);
-	*p++ = cpu_to_be32(args->iomode);
+	*p++ = cpu_to_be32(args->range.iomode);
 	*p = cpu_to_be32(RETURN_FILE);
 	p = reserve_space(xdr, 16);
-	p = xdr_encode_hyper(p, 0);
-	p = xdr_encode_hyper(p, NFS4_MAX_UINT64);
+	p = xdr_encode_hyper(p, args->range.offset);
+	p = xdr_encode_hyper(p, args->range.length);
 	spin_lock(&args->inode->i_lock);
 	encode_nfs4_stateid(xdr, &args->stateid);
 	spin_unlock(&args->inode->i_lock);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 685af4f..9549b89 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -916,7 +916,9 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 	lrp->args.stateid = stateid;
 	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
 	lrp->args.inode = ino;
-	lrp->args.iomode = iomode;
+	lrp->args.range.iomode = iomode;
+	lrp->args.range.offset = 0;
+	lrp->args.range.length = NFS4_MAX_UINT64;
 	lrp->args.layout = lo;
 	lrp->clp = NFS_SERVER(ino)->nfs_client;
 	lrp->cred = lo->plh_lc_cred;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6400a1e..3637923 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -293,7 +293,7 @@ struct nfs4_layoutreturn_args {
 	struct nfs4_sequence_args seq_args;
 	struct pnfs_layout_hdr *layout;
 	struct inode *inode;
-	enum pnfs_iomode iomode;
+	struct pnfs_layout_range range;
 	nfs4_stateid stateid;
 	__u32   layout_type;
 };
-- 
1.9.3

