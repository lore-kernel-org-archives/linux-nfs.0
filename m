From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 2/3] nfs41: Handle session errors during delegation return
Date: Sat,  5 Dec 2009 12:11:23 -0800
Message-ID: <1260043884-16267-3-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260043884-16267-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260043884-16267-2-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12341 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757936AbZLEURG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 15:17:06 -0500
In-Reply-To: <1260043884-16267-2-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add session error handling to nfs4_open_delegation_recall()

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4proc.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fb94ed0..97d4a82 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1169,6 +1169,18 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 			case -ENOENT:
 			case -ESTALE:
 				goto out;
+			case -NFS4ERR_BADSESSION:
+			case -NFS4ERR_BADSLOT:
+			case -NFS4ERR_BAD_HIGH_SLOT:
+			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+			case -NFS4ERR_DEADSESSION:
+			case -NFS4ERR_SEQ_FALSE_RETRY:
+			case -NFS4ERR_SEQ_MISORDERED:
+				dprintk("%s ERROR: %d Reset session\n",
+					__func__, err);
+				set_bit(NFS4CLNT_SESSION_SETUP,
+					&server->nfs_client->cl_state);
+				goto out;
 			case -NFS4ERR_STALE_CLIENTID:
 			case -NFS4ERR_STALE_STATEID:
 			case -NFS4ERR_EXPIRED:
-- 
1.5.4.3

