Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:48216 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756153AbdKCMAa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 08:00:30 -0400
Received: by mail-io0-f195.google.com with SMTP id d66so5711130ioe.5
        for <linux-nfs@vger.kernel.org>; Fri, 03 Nov 2017 05:00:30 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/7] nfsd: Ensure we check stateid validity in the seqid operation checks
Date: Fri,  3 Nov 2017 08:00:15 -0400
Message-Id: <20171103120016.6200-7-trond.myklebust@primarydata.com>
In-Reply-To: <20171103120016.6200-6-trond.myklebust@primarydata.com>
References: <20171103120016.6200-1-trond.myklebust@primarydata.com>
 <20171103120016.6200-2-trond.myklebust@primarydata.com>
 <20171103120016.6200-3-trond.myklebust@primarydata.com>
 <20171103120016.6200-4-trond.myklebust@primarydata.com>
 <20171103120016.6200-5-trond.myklebust@primarydata.com>
 <20171103120016.6200-6-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After taking the stateid st_mutex, we want to know that the stateid
still represents valid state before performing any non-idempotent
actions.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f13fba4f51ec..cbd6a10ddda2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5161,15 +5161,9 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
 	status = nfsd4_check_seqid(cstate, sop, seqid);
 	if (status)
 		return status;
-	if (stp->st_stid.sc_type == NFS4_CLOSED_STID
-		|| stp->st_stid.sc_type == NFS4_REVOKED_DELEG_STID)
-		/*
-		 * "Closed" stateid's exist *only* to return
-		 * nfserr_replay_me from the previous step, and
-		 * revoked delegations are kept only for free_stateid.
-		 */
-		return nfserr_bad_stateid;
-	mutex_lock(&stp->st_mutex);
+	status = nfsd4_lock_ol_stateid(stp);
+	if (status != nfs_ok)
+		return status;
 	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
 	if (status == nfs_ok)
 		status = nfs4_check_fh(current_fh, &stp->st_stid);
-- 
2.13.6

