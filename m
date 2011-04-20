Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57120 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab1DTR1E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:27:04 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 06/27] pnfs: encode_layoutreturn
Date: Wed, 20 Apr 2011 20:26:58 +0300
Message-Id: <1303320418-21181-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
[fixup layout header pointer for encode_layoutreturn]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    9 +++++++--
 fs/nfs/pnfs.h    |    4 ++++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 53ea3e5..6b64dd8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1927,8 +1927,13 @@ encode_layoutreturn(struct xdr_stream *xdr,
 		spin_unlock(&args->inode->i_lock);
 		p = xdr_encode_opaque_fixed(p, &stateid.data,
 					    NFS4_STATEID_SIZE);
-		p = reserve_space(xdr, 4);
-		*p = cpu_to_be32(0);
+		if (NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn) {
+			NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn(
+				NFS_I(args->inode)->layout, xdr, args);
+		} else {
+			p = reserve_space(xdr, 4);
+			*p = cpu_to_be32(0);
+		}
 	}
 	hdr->nops++;
 	hdr->replen += decode_layoutreturn_maxsz;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c315109..51dcbc1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -98,6 +98,10 @@ struct pnfs_layoutdriver_type {
 
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

