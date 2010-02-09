From: andros@netapp.com
Subject: [PATCH 2/6] pnfsd: fix NFS4ERR_BADIOMODE in layoutget
Date: Tue,  9 Feb 2010 12:42:33 -0500
Message-ID: <1265737357-9405-3-git-send-email-andros@netapp.com>
References: <1265737357-9405-1-git-send-email-andros@netapp.com>
 <1265737357-9405-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57062 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755374Ab0BIRm7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 12:42:59 -0500
In-Reply-To: <1265737357-9405-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

If an invalid iomode, or an iomode of LAYOUTIOMODE4_ANY is specified, the
metadata server MUST return NFS4ERR_BADIOMODE.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 769628f..575e1b6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1114,21 +1114,14 @@ nfsd4_layoutget(struct svc_rqst *rqstp,
 	if (status)
 		goto out;
 
-	status = nfserr_inval;
+	status = nfserr_badiomode;
 	if (lgp->lg_seg.iomode != IOMODE_READ &&
-	    lgp->lg_seg.iomode != IOMODE_RW &&
-	    lgp->lg_seg.iomode != IOMODE_ANY) {
+	    lgp->lg_seg.iomode != IOMODE_RW) {
 		dprintk("pNFS %s: invalid iomode %d\n", __func__,
 			lgp->lg_seg.iomode);
 		goto out;
 	}
 
-	status = nfserr_badiomode;
-	if (lgp->lg_seg.iomode == IOMODE_ANY) {
-		dprintk("pNFS %s: IOMODE_ANY is not allowed\n", __func__);
-		goto out;
-	}
-
 	/* Set up arguments so layout can be retrieved at encode time */
 	lgp->lg_fhp = current_fh;
 	copy_clientid((clientid_t *)&lgp->lg_seg.clientid, cstate->session);
-- 
1.6.6

