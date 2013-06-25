Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51809 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab3FYShn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 14:37:43 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/3] NFSv4.1 Fix gdia_maxcount calculation to fit in ca_maxresponsesize
Date: Tue, 25 Jun 2013 14:37:34 -0400
Message-Id: <1372185454-1888-3-git-send-email-andros@netapp.com>
In-Reply-To: <1372185454-1888-1-git-send-email-andros@netapp.com>
References: <1372185454-1888-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The GETDEVICEINFO gdia_maxcount represents all of the data being returned
within the GETDEVICEINFO4resok structure and includes the XDR overhead.

The CREATE_SESSION ca_maxresponsesize is the maximum reply and includes the RPC
headers (including security flavor credentials and verifiers).

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h          | 1 +
 fs/nfs/nfs4filelayoutdev.c | 2 +-
 fs/nfs/nfs4xdr.c           | 6 ++++++
 3 files changed, 8 insertions(+), 1 deletion(-)

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
index 0493dbd..749ca61 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -709,7 +709,7 @@ filelayout_get_device_info(struct inode *inode,
 	pdev->layout_type = LAYOUT_NFSV4_1_FILES;
 	pdev->pages = pages;
 	pdev->pgbase = 0;
-	pdev->pglen = max_resp_sz;
+	pdev->pglen = max_resp_sz - nfs41_maxgetdevinfo_overhead;
 	pdev->mincount = 0;
 
 	rc = nfs4_proc_getdeviceinfo(server, pdev, cred);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2a3f77e1..dde8e17 100644
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
-- 
1.7.11.7

