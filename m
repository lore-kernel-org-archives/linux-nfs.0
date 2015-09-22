Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:38734 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751591AbbIVOH5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Sep 2015 10:07:57 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH] nfsd: eliminate sending duplicate delegations
Date: Tue, 22 Sep 2015 10:07:18 -0400
Message-Id: <1442930838-45895-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've observed the nfsd server in a state where there are
multiple delegations on the same nfs4_file for the same client.
The nfs client does attempt to DELEGRETURN these when they are presented to
it - but apparently under some (unknown) circumstances the client does not
manage to return all of them. This leads to the eventual
attempt to CB_RECALL more than one delegation with the same nfs
filehandle to the same client. The first recall will succeed, but the
next recall will fail with NFS4ERR_BADHANDLE. This leads to the server
having delegations on cl_revoked that the client has no way to FREE
or DELEGRETURN, with resulting inability to recover. The state manager
on the server will continually assert SEQ4_STATUS_RECALLABLE_STATE_REVOKED,
and the state manager on the client will be looping unable to satisfy
the server.

So, let's not hand out duplicate delegations in the first place.

RFC 5561:

9.1.1:
"Delegations and layouts, on the other hand, are not associated with a
specific owner but are associated with the client as a whole
(identified by a client ID)."

10.2:
"...the stateid for a delegation is associated with a client ID and may be
used on behalf of all the open-owners for the given client.  A
delegation is made to the client as a whole and not to any specific
process or thread of control within it."

Reported-by: Eric Meddaugh <etmsys@rit.edu>
Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/nfs4state.c | 26 ++++++++++++++++++++++++--
 fs/nfsd/state.h     |  1 +
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ff108d2f777d..b0e2fba58271 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3180,6 +3180,7 @@ static void nfsd4_init_file(struct knfsd_fh *fh, unsigned int hashval,
 	fp->fi_deleg_file = NULL;
 	fp->fi_had_conflict = false;
 	fp->fi_share_deny = 0;
+	mutex_init(&fp->fi_deleg_mutex);
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
 #ifdef CONFIG_NFSD_PNFS
@@ -4104,7 +4105,7 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
  */
 static void
 nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
-			struct nfs4_ol_stateid *stp)
+		     struct nfs4_ol_stateid *stp, struct nfs4_file *fp)
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_openowner *oo = openowner(stp->st_stateowner);
@@ -4146,10 +4147,31 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
 		default:
 			goto out_no_deleg;
 	}
+
+	mutex_lock(&fp->fi_deleg_mutex);
+	spin_lock(&state_lock);
+	spin_lock(&fp->fi_lock);
+	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile) {
+	  if(same_clid(&clp->cl_clientid,&dp->dl_stid.sc_client->cl_clientid)) {
+	    atomic_inc(&dp->dl_stid.sc_count);
+	    spin_unlock(&fp->fi_lock);
+	    spin_unlock(&state_lock);
+	    mutex_unlock(&fp->fi_deleg_mutex);
+	    goto out_with_existing_deleg;
+	  }
+	}
+	spin_unlock(&fp->fi_lock);
+	spin_unlock(&state_lock);
+
 	dp = nfs4_set_delegation(clp, fh, stp->st_stid.sc_file, stp->st_clnt_odstate);
+
+	mutex_unlock(&fp->fi_deleg_mutex);
+
 	if (IS_ERR(dp))
 		goto out_no_deleg;
 
+out_with_existing_deleg:
+
 	memcpy(&open->op_delegate_stateid, &dp->dl_stid.sc_stateid, sizeof(dp->dl_stid.sc_stateid));
 
 	dprintk("NFSD: delegation stateid=" STATEID_FMT "\n",
@@ -4262,7 +4284,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	* Attempt to hand out a delegation. No error return, because the
 	* OPEN succeeds even if we fail.
 	*/
-	nfs4_open_delegation(current_fh, open, stp);
+	nfs4_open_delegation(current_fh, open, stp, fp);
 nodeleg:
 	status = nfs_ok;
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 67685b6cfef3..06a22efba408 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -512,6 +512,7 @@ struct nfs4_file {
 	int			fi_delegees;
 	struct knfsd_fh		fi_fhandle;
 	bool			fi_had_conflict;
+	struct mutex		fi_deleg_mutex;
 #ifdef CONFIG_NFSD_PNFS
 	struct list_head	fi_lo_states;
 	atomic_t		fi_lo_recalls;
-- 
2.4.6

