Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34789 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab1EPQXm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 12:23:42 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com
Subject: [PATCH v3 22/29] pnfs: encode_layoutreturn
Date: Mon, 16 May 2011 09:23:38 -0700
Message-Id: <1305563018-8100-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD14D8E.1070701@panasas.com>
References: <4DD14D8E.1070701@panasas.com>
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
index e53d7d8..29d33b3 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1920,8 +1920,13 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	spin_lock(&args->inode->i_lock);
 	xdr_encode_opaque_fixed(p, &NFS_I(args->inode)->layout->plh_stateid.data, NFS4_STATEID_SIZE);
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
index a54e715..798861c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -106,6 +106,10 @@ struct pnfs_layoutdriver_type {
 
 	/* device notification methods */
 	void (*delete_deviceid)(struct nfs4_deviceid *);
+
+	void (*encode_layoutreturn) (struct pnfs_layout_hdr *layoutid,
+				     struct xdr_stream *xdr,
+				     const struct nfs4_layoutreturn_args *args);
 };
 
 struct pnfs_layout_hdr {
-- 
1.7.3.4

