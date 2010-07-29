Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53257 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754888Ab0G2WWj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Jul 2010 18:22:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] nfsd4: fix openmode checking on IO using lock stateid
Date: Thu, 29 Jul 2010 18:21:23 -0400
Message-Id: <1280442084-17867-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1280442084-17867-1-git-send-email-bfields@redhat.com>
References: <1280442084-17867-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

It is legal to perform a write using the lock stateid that was
originally associated with a read lock, or with a file that was
originally opened for read, but has since been upgraded.

So, when checking the openmode, check the mode associated with the
open stateid from which the lock was derived.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d9c8232..b996a4b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2779,6 +2779,9 @@ __be32 nfs4_check_openmode(struct nfs4_stateid *stp, int flags)
 {
         __be32 status = nfserr_openmode;
 
+	/* For lock stateid's, we test the parent open, not the lock: */
+	if (stp->st_openstp)
+		stp = stp->st_openstp;
 	if ((flags & WR_STATE) && (!access_permit_write(stp->st_access_bmap)))
                 goto out;
 	if ((flags & RD_STATE) && (!access_permit_read(stp->st_access_bmap)))
@@ -3466,7 +3469,6 @@ alloc_init_lock_stateid(struct nfs4_stateowner *sop, struct nfs4_file *fp, struc
 	stp->st_stateid.si_fileid = fp->fi_id;
 	stp->st_stateid.si_generation = 0;
 	stp->st_vfs_file = open_stp->st_vfs_file; /* FIXME refcount?? */
-	stp->st_access_bmap = open_stp->st_access_bmap;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
 
-- 
1.7.0.4

