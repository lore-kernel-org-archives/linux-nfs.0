Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51119 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932415Ab2JBVt4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 17:49:56 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/2] NFSv4: don't check MAY_WRITE access bit in OPEN
Date: Tue,  2 Oct 2012 14:49:51 -0700
Message-Id: <1349214592-11717-2-git-send-email-dros@netapp.com>
In-Reply-To: <1349214592-11717-1-git-send-email-dros@netapp.com>
References: <1349214592-11717-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't check MAY_WRITE as a newly created file may not have write mode bits,
but POSIX allows the creating process to write regardless.
This is ok because NFSv4 OPEN ops handle write permissions correctly -
the ACCESS in the OPEN compound is to differentiate READ v EXEC permissions.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1e0faf9..ccada68 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1661,10 +1661,10 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 		return 0;
 
 	mask = 0;
+	/* don't check MAY_WRITE - a newly created file may not have
+	 * write mode bits, but POSIX allows the creating process to write */
 	if (fmode & FMODE_READ)
 		mask |= MAY_READ;
-	if (fmode & FMODE_WRITE)
-		mask |= MAY_WRITE;
 	if (fmode & FMODE_EXEC)
 		mask |= MAY_EXEC;
 
@@ -1673,7 +1673,7 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 	nfs_access_set_mask(&cache, opendata->o_res.access_result);
 	nfs_access_add_cache(state->inode, &cache);
 
-	if ((mask & ~cache.mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)
+	if ((mask & ~cache.mask & (MAY_READ | MAY_EXEC)) == 0)
 		return 0;
 
 	/* even though OPEN succeeded, access is denied. Close the file */
-- 
1.7.9.6 (Apple Git-31.1)

