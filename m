Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:15583 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670Ab3FYXDO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 19:03:14 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/3] NFSv4.1 Fix gdia_maxcount calculation to fit in ca_maxresponsesize
Date: Tue, 25 Jun 2013 19:02:53 -0400
Message-Id: <1372201375-6686-2-git-send-email-andros@netapp.com>
In-Reply-To: <1372201375-6686-1-git-send-email-andros@netapp.com>
References: <1372201375-6686-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The GETDEVICEINFO gdia_maxcount represents all of the data being returned
within the GETDEVICEINFO4resok structure and includes the XDR overhead.

The CREATE_SESSION ca_maxresponsesize is the maximum reply and includes the RPC
headers (including security flavor credentials and verifiers).

Split out the struct pnfs_device field maxcount which is the gdia_maxcount
from the pglen field which is the reply (the total) buffer length.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h          | 1 +
 fs/nfs/nfs4filelayoutdev.c | 1 +
 fs/nfs/nfs4xdr.c           | 8 +++++++-
 fs/nfs/pnfs.h              | 3 ++-
 4 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 97ec2ef..3c8373f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -255,6 +255,7 @@ extern int nfs4_decode_dirent(struct xdr_stream *,
 #ifdef CONFIG_NFS_V4_1
 extern const u32 nfs41_maxread_overhead;
 extern const u32 nfs41_maxwrite_overhead;
+extern const u32 nfs41_maxgetdevinfo_overhead;
 #endif
 
 /* nfs4proc.c */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 0493dbd..95604f6 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -711,6 +711,7 @@ filelayout_get_device_info(struct inode *inode,
 	pdev->pgbase = 0;
 	pdev->pglen = max_resp_sz;
 	pdev->mincount = 0;
+	pdev->maxcount = max_resp_sz - nfs41_maxgetdevinfo_overhead;
 
 	rc = nfs4_proc_getdeviceinfo(server, pdev, cred);
 	dprintk("%s getdevice info returns %d\n", __func__, rc);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2a3f77e1..0abfb846 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -867,6 +867,12 @@ const u32 nfs41_maxread_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				     decode_sequence_maxsz +
 				     decode_putfh_maxsz) *
 				    XDR_UNIT);
+
+const u32 nfs41_maxgetdevinfo_overhead = ((RPC_MAX_REPHEADER_WITH_AUTH +
+					   compound_decode_hdr_maxsz +
+					   decode_sequence_maxsz) *
+					  XDR_UNIT);
+EXPORT_SYMBOL_GPL(nfs41_maxgetdevinfo_overhead);
 #endif /* CONFIG_NFS_V4_1 */
 
 static const umode_t nfs_type2fmt[] = {
@@ -1924,7 +1930,7 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
 	p = xdr_encode_opaque_fixed(p, args->pdev->dev_id.data,
 				    NFS4_DEVICEID4_SIZE);
 	*p++ = cpu_to_be32(args->pdev->layout_type);
-	*p++ = cpu_to_be32(args->pdev->pglen);		/* gdia_maxcount */
+	*p++ = cpu_to_be32(args->pdev->maxcount);	/* gdia_maxcount */
 	*p++ = cpu_to_be32(0);				/* bitmap length 0 */
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1441dff..a4f4181 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -149,9 +149,10 @@ struct pnfs_device {
 	struct nfs4_deviceid dev_id;
 	unsigned int  layout_type;
 	unsigned int  mincount;
+	unsigned int  maxcount;	/* gdia_maxcount */
 	struct page **pages;
 	unsigned int  pgbase;
-	unsigned int  pglen;
+	unsigned int  pglen;	/* reply buffer length */
 };
 
 #define NFS4_PNFS_GETDEVLIST_MAXNUM 16
-- 
1.7.11.7

