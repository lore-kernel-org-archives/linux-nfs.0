Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50969 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755219Ab1E2S0h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:26:37 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Andy Adamson <andros@netapp.com>
Subject: [PATCH 24/32] pnfs: encode_layoutreturn
Date: Sun, 29 May 2011 21:26:25 +0300
Message-Id: <1306693585-8382-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Add a layout driver method to encode the layout type specific
opaque part of layout return in-line in the xdr stream.

Currently the pnfs-objects layout driver uses it to encode i/o error
information on LAYOUTRETURN.

Signed-off-by: Andy Adamson <andros@netapp.com>
[fixup layout header pointer for encode_layoutreturn]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    9 +++++++--
 fs/nfs/pnfs.h    |    4 ++++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f242120..d464bad 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1920,8 +1920,13 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	spin_lock(&args->inode->i_lock);
 	xdr_encode_opaque_fixed(p, &args->stateid.data, NFS4_STATEID_SIZE);
 	spin_unlock(&args->inode->i_lock);
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(0);
+	if (NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn) {
+		NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn(
+			NFS_I(args->inode)->layout, xdr, args);
+	} else {
+		p = reserve_space(xdr, 4);
+		*p = cpu_to_be32(0);
+	}
 	hdr->nops++;
 	hdr->replen += decode_layoutreturn_maxsz;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index af3967a..1b6b207 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -104,6 +104,10 @@ struct pnfs_layoutdriver_type {
 	enum pnfs_try_status (*write_pagelist) (struct nfs_write_data *nfs_data, int how);
 
 	void (*free_deviceid_node) (struct nfs4_deviceid_node *);
+
+	void (*encode_layoutreturn) (struct pnfs_layout_hdr *layoutid,
+				     struct xdr_stream *xdr,
+				     const struct nfs4_layoutreturn_args *args);
 };
 
 struct pnfs_layout_hdr {
-- 
1.7.2.3

