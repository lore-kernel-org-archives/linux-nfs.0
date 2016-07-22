Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40086 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752445AbcGVRtG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2016 13:49:06 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/7] nfsd: drop unnecessary MAY_EXEC check from create
Date: Fri, 22 Jul 2016 13:48:56 -0400
Message-Id: <1469209736-6490-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1469209736-6490-1-git-send-email-bfields@redhat.com>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We need an fh_verify to make sure we at least have a dentry, but actual
permission checks happen later.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 7 +------
 fs/nfsd/vfs.c      | 6 +-----
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9d7e1edf0cca..1fb222752b2b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -605,12 +605,7 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	fh_init(&resfh, NFS4_FHSIZE);
 
-	/*
-	 * We just check that parent is accessible here, nfsd_* do their
-	 * own access permission checks
-	 */
-	status = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
-			   NFSD_MAY_EXEC);
+	status = fh_verify(rqstp, &cstate->current_fh, S_IFDIR, NFSD_MAY_NOP);
 	if (status)
 		return status;
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index cd06c6511cfc..c844fd601381 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1236,11 +1236,7 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (isdotent(fname, flen))
 		return nfserr_exist;
 
-	/*
-	 * Even though it is a create, first let's see if we are even allowed
-	 * to peek inside the parent
-	 */
-	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
+	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_NOP);
 	if (err)
 		return err;
 
-- 
2.7.4

