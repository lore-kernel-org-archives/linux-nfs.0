Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60767 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756584Ab0LNAFr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 19:05:47 -0500
Date: Mon, 13 Dec 2010 19:05:46 -0500
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs4: fix units bug causing hang on recovery
Message-ID: <20101214000546.GF9394@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Note that cl_lease_time is in jiffies.  This can cause a very long wait
in the NFS4ERR_CLID_INUSE case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6a653ff..2123759 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3508,7 +3508,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		if (signalled())
 			break;
 		if (loop++ & 1)
-			ssleep(clp->cl_lease_time + 1);
+			ssleep(clp->cl_lease_time / HZ + 1);
 		else
 			if (++clp->cl_id_uniquifier == 0)
 				break;
-- 
1.7.1

