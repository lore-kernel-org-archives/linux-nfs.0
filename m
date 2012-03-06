Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22848 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757893Ab2CFOqx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 09:46:53 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        stable@vger.kernel.org
Subject: [PATCH 1/3] NFSv4.1: Fix the checking of the stateid when returning a delegation
Date: Tue,  6 Mar 2012 09:46:43 -0500
Message-Id: <1331045205-3031-2-git-send-email-andros@netapp.com>
In-Reply-To: <1331045205-3031-1-git-send-email-andros@netapp.com>
References: <1331045205-3031-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

nfs41_validate_delegation_stateid is broken if we supply a stateid with
a non-zero sequence id. Instead of trying to match the sequence id,
the function assumes that we always want to error. While this is
true for a delegation callback, it is not true in general.

Also fix a typo in nfs4_callback_recall.

Reported-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/callback_proc.c |    6 +++---
 fs/nfs/delegation.c    |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f71978d..63190c1 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -86,8 +86,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 		res = 0;
 		break;
 	case -ENOENT:
-		if (res != 0)
-			res = htonl(NFS4ERR_BAD_STATEID);
+		res = htonl(NFS4ERR_BAD_STATEID);
 		break;
 	default:
 		res = htonl(NFS4ERR_RESOURCE);
@@ -328,7 +327,8 @@ int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const n
 	if (delegation == NULL)
 		return 0;
 
-	if (stateid->stateid.seqid != 0)
+	if (stateid->stateid.seqid != 0 &&
+	    stateid->stateid.seqid != delegation->stateid.stateid.seqid)
 		return 0;
 	if (memcmp(&delegation->stateid.stateid.other,
 		   &stateid->stateid.other,
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 7f26540..1596098 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -531,7 +531,7 @@ void nfs_expire_unreferenced_delegations(struct nfs_client *clp)
 /**
  * nfs_async_inode_return_delegation - asynchronously return a delegation
  * @inode: inode to process
- * @stateid: state ID information from CB_RECALL arguments
+ * @stateid: state ID information
  *
  * Returns zero on success, or a negative errno value.
  */
-- 
1.7.6.4

