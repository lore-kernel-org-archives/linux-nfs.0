From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/3] SQUASHME: pnfsd: always set both MDS and DS exchangeid capability flags
Date: Wed,  9 Dec 2009 12:27:20 +0200
Message-ID: <1260354440-12073-1-git-send-email-bhalevy@panasas.com>
References: <4B1F7AF6.2080305@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13167 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754056AbZLIK1P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 05:27:15 -0500
In-Reply-To: <4B1F7AF6.2080305@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We always support both modes when CONFIG_PNFSD is enabled.
The client needs to remember what the session is used for
if it cares to distiguish between DSs and MDSs.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   15 ++-------------
 1 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 108cb3e..aa2e9c2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1103,20 +1103,9 @@ static void
 nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
 {
 #if defined(CONFIG_PNFSD)
-	int mds_and_ds = EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_PNFS_DS;
-	int mds_or_ds = 0;
-
-	/* Save the client's MDS or DS flags, or set them both.
-	 * XXX We currently do not have a method of determining
-	 * what a server supports prior to receiving a filehandle
-	 * e.g. at exchange id time. */
-	mds_or_ds = clid->flags & mds_and_ds;
-	if (mds_or_ds)
-		new->cl_exchange_flags |= mds_or_ds;
-	else
-		new->cl_exchange_flags |= mds_and_ds;
+	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_PNFS_MDS |
+				  EXCHGID4_FLAG_USE_PNFS_DS;
 #else  /* CONFIG_PNFSD */
-	/* pNFS is not supported */
 	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_NON_PNFS;
 #endif /* CONFIG_PNFSD */
 
-- 
1.6.5.1

