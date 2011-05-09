Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38044 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab1EIRKl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:10:41 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 22/29] pnfs: encode_layoutreturn
Date: Mon,  9 May 2011 20:10:34 +0300
Message-Id: <1304961034-4606-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DC81E8C.6040901@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
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
index 34fc994..75ad9e1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1921,8 +1921,13 @@ encode_layoutreturn(struct xdr_stream *xdr,
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

