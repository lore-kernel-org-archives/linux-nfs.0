Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091Ab1HOWaf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 18:30:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] nfsd4: fix incorrect comment in nfsd4_set_nfs4_acl
Date: Mon, 15 Aug 2011 18:30:30 -0400
Message-Id: <1313447432-1537-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20110815222859.GD32181@fieldses.org>
References: <20110815222859.GD32181@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Zero means "I don't care what kind of file this is".  And that's
probably what we want--acls are also settable at least on directories,
and if the filesystem doesn't want them on other objects, leave it to it
to complain.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index fd0acca..556ca2b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -502,7 +502,7 @@ nfsd4_set_nfs4_acl(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	unsigned int flags = 0;
 
 	/* Get inode */
-	error = fh_verify(rqstp, fhp, 0 /* S_IFREG */, NFSD_MAY_SATTR);
+	error = fh_verify(rqstp, fhp, 0, NFSD_MAY_SATTR);
 	if (error)
 		return error;
 
-- 
1.7.4.1

