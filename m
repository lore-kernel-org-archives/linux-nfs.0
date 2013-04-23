Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61376 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756631Ab3DWS6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 14:58:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] NFSv4: Ensure that we clear the NFS_OPEN_STATE flag when appropriate
Date: Tue, 23 Apr 2013 14:58:00 -0400
Message-Id: <1366743483-59247-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should always clear it before initiating file recovery.
Also ensure that we clear it after a CLOSE and/or after TEST_STATEID fails.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ed01a66..c131449 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1290,6 +1290,7 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
 
 	/* memory barrier prior to reading state->n_* */
 	clear_bit(NFS_DELEGATED_STATE, &state->flags);
+	clear_bit(NFS_OPEN_STATE, &state->flags);
 	smp_rmb();
 	if (state->n_rdwr != 0) {
 		clear_bit(NFS_O_RDWR_STATE, &state->flags);
@@ -1893,6 +1894,7 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 		clear_bit(NFS_O_RDWR_STATE, &state->flags);
+		clear_bit(NFS_OPEN_STATE, &state->flags);
 	}
 	return status;
 }
@@ -2208,11 +2210,19 @@ static void nfs4_close_clear_stateid_flags(struct nfs4_state *state,
 		fmode_t fmode)
 {
 	spin_lock(&state->owner->so_lock);
-	if (!(fmode & FMODE_READ))
+	clear_bit(NFS_O_RDWR_STATE, &state->flags);
+	switch (fmode & (FMODE_READ|FMODE_WRITE)) {
+	case FMODE_WRITE:
 		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
-	if (!(fmode & FMODE_WRITE))
+		break;
+	case FMODE_READ:
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
-	clear_bit(NFS_O_RDWR_STATE, &state->flags);
+		break;
+	case 0:
+		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
+		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
+		clear_bit(NFS_OPEN_STATE, &state->flags);
+	}
 	spin_unlock(&state->owner->so_lock);
 }
 
-- 
1.8.1.4

