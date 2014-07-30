Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:32775 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225AbaG3M2T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:19 -0400
Received: by mail-qg0-f44.google.com with SMTP id e89so1304120qgf.17
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:18 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 24/37] nfsd: Remove nfs4_lock_state(): nfs4_preprocess_stateid_op()
Date: Wed, 30 Jul 2014 08:27:25 -0400
Message-Id: <1406723258-8512-25-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index baf83cf96b26..9013a30874e3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4461,13 +4461,11 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
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
@@ -4517,8 +4515,6 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 		*filpp = file;
 out:
 	nfs4_put_stid(s);
-unlock_state:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

