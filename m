Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61793 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162690Ab3DEVQl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 17:16:41 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/3] NFSv4: Fix issues in nfs4_discover_server_trunking
Date: Fri,  5 Apr 2013 17:16:35 -0400
Message-Id: <1365196596-25439-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365196596-25439-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1365196596-25439-1-git-send-email-Trond.Myklebust@netapp.com>
 <1365196596-25439-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

- Ensure that we exit with ENOENT if the call to ops->get_clid_cred()
  fails.
- Handle the case where ops->detect_trunking() exits with an
  unexpected error, and return EIO.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4state.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a30f51e..209df69 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1876,8 +1876,8 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 	i = 0;
 
 	mutex_lock(&nfs_clid_init_mutex);
-	status  = -ENOENT;
 again:
+	status  = -ENOENT;
 	cred = ops->get_clid_cred(clp);
 	if (cred == NULL)
 		goto out_unlock;
@@ -1916,6 +1916,11 @@ again:
 	case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
 				 * in nfs4_exchange_id */
 		status = -EKEYEXPIRED;
+		break;
+	default:
+		pr_warn("NFS: %s unhandled error %d. Exiting with error EIO\n",
+				__func__, status);
+		status = -EIO;
 	}
 
 out_unlock:
-- 
1.8.1.4

