Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4164 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941Ab2EYWDm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 May 2012 18:03:42 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/8] NFSv4.1: Handle NFS4ERR_SEQ_MISORDERED when confirming the lease
Date: Fri, 25 May 2012 18:03:18 -0400
Message-Id: <1337983402-24677-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1337983402-24677-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1337983402-24677-1-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-2-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apparently the patch "NFS: Always use the same SETCLIENTID boot verifier"
is tickling a Linux nfs server bug, and causing a regression: the server
can get into a situation where it keeps replying NFS4ERR_SEQ_MISORDERED
to our CREATE_SESSION request even when we are sending the correct
sequence ID.

Fix this by purging the lease and then retrying.

Reported-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4state.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 604c600..419f8c4 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1580,6 +1580,11 @@ out:
 static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 {
 	switch (status) {
+	case -NFS4ERR_SEQ_MISORDERED:
+		if (test_and_set_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state))
+			return -ESERVERFAULT;
+		/* Lease confirmation error: retry after purging the lease */
+		ssleep(1);
 	case -NFS4ERR_CLID_INUSE:
 	case -NFS4ERR_STALE_CLIENTID:
 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
-- 
1.7.7.6

