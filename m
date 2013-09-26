Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:56319 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSmd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:33 -0400
Received: by mail-qc0-f171.google.com with SMTP id x19so1050723qcw.30
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:33 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 39/49] pnfsd: DLM file layout only support read iomode layouts
Date: Thu, 26 Sep 2013 14:42:30 -0400
Message-Id: <1380220950-14484-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In a DLM cluster, writing to a node other than the node where the open call
occurred (where meta data is cached) will have performance implications when
the write causes meta data changes that need to be propagated to the open call
node.

DlM clusters support only LAYOUTIOMODE4_READ layouts. Writes will go through
the MDS.

Return NFS4ERR_BADIOMODE for LAYOUTGET requests with LAYOUTIOMODE4_RW iomode.

Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: fixup DLM layout_get return type to u32]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsdlm.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 7ed8156..acc1f91 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -390,6 +390,10 @@ static enum nfsstat4 nfsd4_pnfs_dlm_layoutget(struct inode *inode,
 
 	dprintk("%s: LAYOUT_GET\n", __func__);
 
+	/* DLM exported file systems only support layouts for READ */
+	if (res->lg_seg.iomode == IOMODE_RW)
+		return NFS4ERR_BADIOMODE;
+
 	index = dlm_ino_hash(inode);
 	dprintk("%s first stripe index %d i_ino %lu\n", __func__, index,
 		inode->i_ino);
-- 
1.8.3.1

