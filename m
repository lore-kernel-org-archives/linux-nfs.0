From: andros@netapp.com
Subject: [PATCH 1/1] nfs41 fix NFS4ERR_CLID_INUSE for exchange id
Date: Tue,  2 Mar 2010 13:19:36 -0500
Message-ID: <1267553976-17964-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35225 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753689Ab0CBST4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 13:19:56 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 84b53d3..287462a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4506,7 +4506,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 
 		status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
 
-		if (status != NFS4ERR_CLID_INUSE)
+		if (status != -NFS4ERR_CLID_INUSE)
 			break;
 
 		if (signalled())
-- 
1.6.2.5

