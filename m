From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/4] nfsd4: cross mountpoints when looking up parents
Date: Mon, 28 Sep 2009 12:22:30 -0400
Message-ID: <1254154952-13083-3-git-send-email-bfields@citi.umich.edu>
References: <1254154952-13083-1-git-send-email-bfields@citi.umich.edu>
 <1254154952-13083-2-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Steve Dickson <SteveD@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48557 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397AbZI1QWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 12:22:13 -0400
In-Reply-To: <1254154952-13083-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

3c394ddaa7ea4205f933fd9b481166b2669368a9 "nfsd4: nfsv4 clients should
cross mountpoints" forgot to handle lookups of parents directories.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Steve Dickson <SteveD@redhat.com>
---
 fs/nfsd/vfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a293f02..b8ed58b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -169,7 +169,7 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			dentry = dget(dparent);
 		else if (dparent != exp->ex_path.dentry)
 			dentry = dget_parent(dparent);
-		else if (!EX_NOHIDE(exp))
+		else if (!EX_NOHIDE(exp) && !nfsd_v4client(rqstp))
 			dentry = dget(dparent); /* .. == . just like at / */
 		else {
 			/* checking mountpoint crossing is very different when stepping up */
-- 
1.6.0.4

