Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40024 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751621AbcGVRtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2016 13:49:05 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/7] nfsd: remove redundant zero-length check from create
Date: Fri, 22 Jul 2016 13:48:51 -0400
Message-Id: <1469209736-6490-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1469209736-6490-1-git-send-email-bfields@redhat.com>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

lookup_one_len already has this check.

The only effect of this patch is to return access instead of perm in the
0-length-filename case.  I actually prefer nfserr_perm (or _inval?), but
I doubt anyone cares.

The isdotent check seems redundant too, but I worry that some client
might actually care about that strange nfserr_exist error.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsproc.c | 3 ---
 fs/nfsd/vfs.c     | 3 ---
 2 files changed, 6 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 409fdde8e95d..c30b12388bf6 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -250,9 +250,6 @@ nfsd_proc_create(struct svc_rqst *rqstp, struct nfsd_createargs *argp,
 
 	/* Check for NFSD_MAY_WRITE in nfsd_create if necessary */
 
-	nfserr = nfserr_acces;
-	if (!argp->len)
-		goto done;
 	nfserr = nfserr_exist;
 	if (isdotent(argp->name, argp->len))
 		goto done;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index fda4f86161f8..fba8e7e521e0 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1154,9 +1154,6 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	__be32		err2;
 	int		host_err;
 
-	err = nfserr_perm;
-	if (!flen)
-		goto out;
 	err = nfserr_exist;
 	if (isdotent(fname, flen))
 		goto out;
-- 
2.7.4

