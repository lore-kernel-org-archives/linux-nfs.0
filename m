From: andros@netapp.com
Subject: [PATCH 3/6] pnfsd: DLM file layout only support read iomode layouts
Date: Tue,  9 Feb 2010 12:42:34 -0500
Message-ID: <1265737357-9405-4-git-send-email-andros@netapp.com>
References: <1265737357-9405-1-git-send-email-andros@netapp.com>
 <1265737357-9405-2-git-send-email-andros@netapp.com>
 <1265737357-9405-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24051 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755124Ab0BIRm7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 12:42:59 -0500
In-Reply-To: <1265737357-9405-3-git-send-email-andros@netapp.com>
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
---
 fs/nfsd/nfs4pnfsdlm.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 293bf95..8cc7c84 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -28,6 +28,7 @@
 #include <linux/nfsd/nfs4layoutxdr.h>
 
 #include "nfsfh.h"
+#include "nfsd.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -331,6 +332,10 @@ static int nfsd4_pnfs_dlm_layoutget(struct inode *inode,
 
 	dprintk("%s: LAYOUT_GET\n", __func__);
 
+	/* DLM exported file systems only support layouts for READ */
+	if (res->lg_seg.iomode == IOMODE_RW)
+		return nfserr_badiomode;
+
 	index = dlm_ino_hash(inode);
 	dprintk("%s first stripe index %d i_ino %lu\n", __func__, index,
 		inode->i_ino);
-- 
1.6.6

