From: andros@netapp.com
Subject: [PATCH 1/6] pnfsd: fix file system API layout_get error codes
Date: Tue,  9 Feb 2010 12:42:32 -0500
Message-ID: <1265737357-9405-2-git-send-email-andros@netapp.com>
References: <1265737357-9405-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24051 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755345Ab0BIRm7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 12:42:59 -0500
In-Reply-To: <1265737357-9405-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4pnfsd.c |   36 ++++++++++++++++++++++--------------
 1 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 816e2f0..75bddd8 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -868,23 +868,31 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
 		res.lg_seg.offset, res.lg_seg.length);
 
 	if (status) {
+		/*
+		 * The allowable error codes for the layout_get pNFS export
+		 * operations vector function (from the file system) can be
+		 * expanded as needed to include other errors defined for
+		 * the RFC 5561 LAYOUTGET operation.
+		 */
 		switch (status) {
-		case -ETOOSMALL:
-			status = nfserr_toosmall;
-			break;
-		case -ENOMEM:
-		case -EAGAIN:
-		case -EINTR:
-			status = nfserr_layouttrylater;
-			break;
-		case -ENOENT:
-			status = nfserr_badlayout;
-			break;
-		case -E2BIG:
-			status = nfserr_toosmall;
+		case nfserr_acces:
+		case nfserr_badiomode:
+			/* No support for LAYOUTIOMODE4_RW layouts */
+		case nfserr_badlayout:
+			/* No layout matching loga_minlength rules */
+		case nfserr_inval:
+		case nfserr_io:
+		case nfserr_layouttrylater:
+		case nfserr_layoutunavailable:
+		case nfserr_locked:
+		case nfserr_nospc:
+		case nfserr_recallconflict:
+		case nfserr_serverfault:
+		case nfserr_toosmall:
+			/* Requested layout to big for loga_maxcount */
 			break;
 		default:
-			status = nfserr_layoutunavailable;
+			BUG();
 		}
 		goto out_freelayout;
 	}
-- 
1.6.6

