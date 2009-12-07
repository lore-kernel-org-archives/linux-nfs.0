From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 5/5] nfs41: Handle NFSv4.1 session errors in the delegation recall code
Date: Mon,  7 Dec 2009 00:21:51 -0800
Message-ID: <1260174111-23160-6-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260174111-23160-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260174111-23160-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260174111-23160-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260174111-23160-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260174111-23160-5-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7715 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759055AbZLGI1p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 03:27:45 -0500
In-Reply-To: <1260174111-23160-5-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4proc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 53b0a7d..a286d70 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4191,6 +4191,11 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
 			case -NFS4ERR_EXPIRED:
 			case -NFS4ERR_STALE_CLIENTID:
 			case -NFS4ERR_STALE_STATEID:
+			case -NFS4ERR_BADSESSION:
+			case -NFS4ERR_BADSLOT:
+			case -NFS4ERR_BAD_HIGH_SLOT:
+			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+			case -NFS4ERR_DEADSESSION:
 				nfs4_schedule_state_recovery(server->nfs_client);
 				goto out;
 			case -ERESTARTSYS:
-- 
1.5.4.3

