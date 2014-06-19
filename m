Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:39422 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932706AbaFSOxI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:08 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so2255609qgf.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:08 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 091/104] NFSd: Remove nfs4_lock_state(): nfs4_preprocess_stateid_op()
Date: Thu, 19 Jun 2014 10:50:37 -0400
Message-Id: <1403189450-18729-92-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b9b5f9fee7fc..c585730071a0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4294,13 +4294,11 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
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
@@ -4348,8 +4346,6 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 		*filpp = file;
 out:
 	nfs4_put_stid(s);
-unlock_state:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

