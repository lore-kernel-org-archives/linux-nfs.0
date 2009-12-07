From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 2/5] nfs41: Handle session errors during delegation return
Date: Mon,  7 Dec 2009 00:21:48 -0800
Message-ID: <1260174111-23160-3-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260174111-23160-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260174111-23160-2-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759082AbZLGI1o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 03:27:44 -0500
In-Reply-To: <1260174111-23160-2-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add session error handling to nfs4_open_delegation_recall()

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4proc.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fbae2c9..6a8861c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1179,6 +1179,14 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 			case -ENOENT:
 			case -ESTALE:
 				goto out;
+			case -NFS4ERR_BADSESSION:
+			case -NFS4ERR_BADSLOT:
+			case -NFS4ERR_BAD_HIGH_SLOT:
+			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+			case -NFS4ERR_DEADSESSION:
+				nfs4_schedule_state_recovery(
+					server->nfs_client);
+				goto out;
 			case -NFS4ERR_STALE_CLIENTID:
 			case -NFS4ERR_STALE_STATEID:
 			case -NFS4ERR_EXPIRED:
-- 
1.5.4.3

