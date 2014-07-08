Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:58361 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755402AbaGHSGc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:32 -0400
Received: by mail-qc0-f177.google.com with SMTP id r5so5509714qcx.8
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:32 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 087/100] nfsd: Remove nfs4_lock_state(): nfs4_preprocess_stateid_op()
Date: Tue,  8 Jul 2014 14:04:15 -0400
Message-Id: <1404842668-22521-88-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6342fb55ced4..5410b7ee2273 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4464,13 +4464,11 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(net, current_fh, stateid, flags);
 
-	nfs4_lock_state();
-
 	status = nfsd4_lookup_stateid(cstate, stateid,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				&s, nn);
 	if (status)
-		goto unlock_state;
+		return status;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
@@ -4520,8 +4518,6 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 		*filpp = file;
 out:
 	nfs4_put_stid(s);
-unlock_state:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

