Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:19356 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751701AbbJTOWU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 10:22:20 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH RFC v2] nfsd: don't revoke delegations that a client has stated it doesn't have
Date: Tue, 20 Oct 2015 10:21:51 -0400
Message-Id: <1445350911-63530-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Assuming a client has lost a delegation: If the server goes to recall
the delegation, an attempt is made to recall it twice separated by
a delay of 2 seconds. Both times, the client will state that it
doesn't have the delegation via -EBADHANDLE or -NFS4ERR_BAD_STATEID.

1.) Any race between a delegation grant and a recall has been
    presumably avoided by the delay and second attempt.
2.) The client doesn't have the delegation.
3.) The backchannel is responsive.

After these two attempts fail, the laundromat will eventually revoke
them and add these delegations to cl_revoked. This results in another
attempt to get the client to return the delegation via
TEST/FREE STATEID. This will also fail with no means
of resolution, and will cause the server and client to loop
indefinitely, as the client has nothing to give the server to satisfy it.

The changes here are to establish a safe way to recover by:

If the client has responded with -EBADHANDLE or -NFS4ERR_BAD_STATEID:
1.) Not failing the backchannel after two attempts at a recall.
2.) At the time revocation would normally occur: destroying the
    delegation on the server side.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/nfs4state.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index da21df673ed9..340ff365df4d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3578,7 +3578,7 @@ static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
 			rpc_delay(task, 2 * HZ);
 			return 0;
 		}
-		/*FALLTHRU*/
+		return 1;
 	default:
 		return -1;
 	}
@@ -4451,7 +4451,17 @@ nfs4_laundromat(struct nfsd_net *nn)
 		dp = list_first_entry(&reaplist, struct nfs4_delegation,
 					dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-		revoke_delegation(dp);
+		if ((dp->dl_recall.cb_status != -EBADHANDLE) &&
+			(dp->dl_recall.cb_status != -NFS4ERR_BAD_STATEID)) {
+			revoke_delegation(dp);
+		} else {
+			dprintk("nfsd: client: %.*s is losing delegations",
+				(int)dp->dl_recall.cb_clp->cl_name.len,
+				dp->dl_recall.cb_clp->cl_name.data);
+			put_clnt_odstate(dp->dl_clnt_odstate);
+			nfs4_put_deleg_lease(dp->dl_stid.sc_file);
+			nfs4_put_stid(&dp->dl_stid);
+		}
 	}
 
 	spin_lock(&nn->client_lock);
-- 
2.4.6

