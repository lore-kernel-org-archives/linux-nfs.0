Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:51931 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932706AbaFSOxP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:15 -0400
Received: by mail-qg0-f54.google.com with SMTP id q107so2218512qgd.13
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:15 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 096/104] NFSd: Remove nfs4_lock_state(): nfsd4_delegreturn()
Date: Thu, 19 Jun 2014 10:50:42 -0400
Message-Id: <1403189450-18729-97-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 48c01cdb152d..e19a5961bf62 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4722,7 +4722,6 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
 		return status;
 
-	nfs4_lock_state();
 	status = nfsd4_lookup_stateid(cstate, stateid, NFS4_DELEG_STID, &s, nn);
 	if (status)
 		goto out;
@@ -4735,8 +4734,6 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 put_stateid:
 	nfs4_put_delegation(dp);
 out:
-	nfs4_unlock_state();
-
 	return status;
 }
 
-- 
1.9.3

