From: andros@netapp.com
Subject: [PATCH 2/5] pnfsd: fix pnfs_export_operations layoutget valid errors
Date: Fri,  5 Feb 2010 12:10:10 -0500
Message-ID: <1265389813-6823-3-git-send-email-andros@netapp.com>
References: <1265389813-6823-1-git-send-email-andros@netapp.com>
 <1265389813-6823-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933480Ab0BERJg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 12:09:36 -0500
In-Reply-To: <1265389813-6823-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4pnfsd.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 816e2f0..3951e02 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -870,6 +870,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
 	if (status) {
 		switch (status) {
 		case -ETOOSMALL:
+		case -E2BIG:
 			status = nfserr_toosmall;
 			break;
 		case -ENOMEM:
@@ -878,10 +879,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
 			status = nfserr_layouttrylater;
 			break;
 		case -ENOENT:
-			status = nfserr_badlayout;
-			break;
-		case -E2BIG:
-			status = nfserr_toosmall;
+			status = nfserr_stale;
 			break;
 		default:
 			status = nfserr_layoutunavailable;
-- 
1.6.6

