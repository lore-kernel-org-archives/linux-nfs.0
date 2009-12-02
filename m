From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 5/7] nfsd: allow exports of symlinks
Date: Tue,  1 Dec 2009 19:39:41 -0500
Message-ID: <1259714383-32577-6-git-send-email-bfields@citi.umich.edu>
References: <1259714383-32577-1-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-2-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-3-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-4-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-5-git-send-email-bfields@citi.umich.edu>
Cc: Steve Dickson <steved@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46257 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754881AbZLBAim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Dec 2009 19:38:42 -0500
In-Reply-To: <1259714383-32577-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to allow exports of symlinks, to allow mountd to communicate to
the kernel which symlinks lead to exports, and hence which symlinks need
to be visible on the pseudofilesystem.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/export.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b9e4977..0bcd10a 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -372,10 +372,12 @@ static struct svc_export *svc_export_lookup(struct svc_export *);
 static int check_export(struct inode *inode, int flags, unsigned char *uuid)
 {
 
-	/* We currently export only dirs and regular files.
-	 * This is what umountd does.
+	/*
+	 * We currently export only dirs, regular files, and (for v4
+	 * pseudoroot) symlinks.
 	 */
 	if (!S_ISDIR(inode->i_mode) &&
+	    !S_ISLNK(inode->i_mode) &&
 	    !S_ISREG(inode->i_mode))
 		return -ENOTDIR;
 
-- 
1.6.3.3

