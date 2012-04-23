Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070Ab2DWUya (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:54:30 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:54:30 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/20] NFS: Force server to drop NFSv4 state
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:54:28 -0400
Message-ID: <20120423205427.11446.1552.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A SETCLIENTID boot verifier is nothing more than a boot timestamp.
An NFSv4 server is obligated to wipe all NFSv4 state for an NFS client
when the client presents an updated SETCLIENTID boot verifier.  This
is how servers detect client reboots.

nfs4_reset_all_state() forces a boot verifier refresh to cause a
server to wipe state as part of recovering from a server reporting
that it has revoked some or all of a client's NFSv4 state.  This wipes
the slate for full state recovery.

Soon we want to get rid of the per-nfs_client cl_boot_time field,
however.  Without cl_boot_time, the NFS client will need to find a
different way to force the server to purge the client's NFSv4 state.

Because these verifiers are opaque (ie, the server doesn't know or
care that they are timestamps), we can do this by using the same
trick we use now, but then afterwards establish a fresh client ID
using the old boot verifier again.

Hopefully there are no extra paranoid server implementations that keep
track of the client's boot verifiers and prevent clients from reusing
a previous one.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |    9 +++++++--
 fs/nfs/nfs4state.c |    7 ++++++-
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index d8c2d39..2953f2c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -24,6 +24,7 @@ enum nfs4_client_state {
 	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_LEASE_CONFIRM,
 	NFS4CLNT_SERVER_SCOPE_MISMATCH,
+	NFS4CLNT_PURGE_STATE,
 };
 
 enum nfs4_session_state {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 84a26d9..b19cf81 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3878,8 +3878,13 @@ static void nfs4_construct_boot_verifier(struct nfs_client *clp,
 {
 	__be32 verf[2];
 
-	verf[0] = (__be32)clp->cl_boot_time.tv_sec;
-	verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
+	if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
+		verf[0] = (__be32)CURRENT_TIME.tv_sec;
+		verf[1] = (__be32)CURRENT_TIME.tv_nsec;
+	} else {
+		verf[0] = (__be32)clp->cl_boot_time.tv_sec;
+		verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
+	}
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cbef366..7f56502 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1612,7 +1612,7 @@ void nfs41_handle_recall_slot(struct nfs_client *clp)
 static void nfs4_reset_all_state(struct nfs_client *clp)
 {
 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
-		clp->cl_boot_time = CURRENT_TIME;
+		set_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
 		nfs4_state_start_reclaim_nograce(clp);
 		nfs4_schedule_state_manager(clp);
 	}
@@ -1759,6 +1759,11 @@ static void nfs4_state_manager(struct nfs_client *clp)
 
 	/* Ensure exclusive access to NFSv4 state */
 	do {
+		if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
+			nfs4_reclaim_lease(clp);
+			clear_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
+		}
+
 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
 			/* We're going to have to re-establish a clientid */
 			status = nfs4_reclaim_lease(clp);

