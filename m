Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:64534 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSmh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:37 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so1045020qcz.14
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:37 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 40/49] pnfsd: add dlm file layout layout-type
Date: Thu, 26 Sep 2013 14:42:34 -0400
Message-Id: <1380220954-14530-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Export nfsd4_pnfs_dlm_layouttype for use by dlm cluster file systems.

Signed-off-by: Andy Adamson <andros@netapp.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
[pnfsd: dlm: fixup LAYOUT_NFSV4_1_FILES]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsdlm.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index acc1f91..de1af22 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -446,8 +446,15 @@ static enum nfsstat4 nfsd4_pnfs_dlm_layoutget(struct inode *inode,
 	goto exit;
 }
 
+static int
+nfsd4_pnfs_dlm_layouttype(struct super_block *sb)
+{
+	return LAYOUT_NFSV4_1_FILES;
+}
+
 /* For use by DLM cluster file systems exported by pNFSD */
 const struct pnfs_export_operations pnfs_dlm_export_ops = {
+	.layout_type = nfsd4_pnfs_dlm_layouttype,
 	.get_device_info = nfsd4_pnfs_dlm_getdevinfo,
 	.get_device_iter = nfsd4_pnfs_dlm_getdeviter,
 	.layout_get = nfsd4_pnfs_dlm_layoutget,
-- 
1.8.3.1

