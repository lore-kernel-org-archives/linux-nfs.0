Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:39919 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757917AbaFSOwY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:24 -0400
Received: by mail-qg0-f44.google.com with SMTP id j107so2191006qga.17
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:23 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 059/104] NFSd: Convert nfsd4_process_open1() to work with lookup_clientid()
Date: Thu, 19 Jun 2014 10:50:05 -0400
Message-Id: <1403189450-18729-60-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

...and have alloc_init_open_stateowner just use the cstate->clp pointer
instead of passing in a clp separately.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 428944aef83f..42c5f487a7a5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -75,6 +75,9 @@ static struct nfs4_openowner *find_openstateowner_str_locked(
 		unsigned int hashval, struct nfsd4_open *open,
 		bool sessions, struct nfsd_net *nn);
 static void nfs4_put_stateowner(struct nfs4_stateowner *sop);
+static __be32 lookup_clientid(clientid_t *clid,
+		struct nfsd4_compound_state *cstate,
+		struct nfsd_net *nn);
 
 /* Locking: */
 
@@ -2949,10 +2952,10 @@ static void nfs4_free_openowner(struct nfs4_stateowner *so)
 }
 
 static struct nfs4_openowner *
-alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp,
-			   struct nfsd4_open *open,
+alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 			   struct nfsd4_compound_state *cstate)
 {
+	struct nfs4_client *clp = cstate->clp;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct nfs4_openowner *oo, *ret;
 
@@ -3269,10 +3272,10 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	oo = find_openstateowner_str(strhashval, open, cstate->minorversion, nn);
 	open->op_openowner = oo;
 	if (!oo) {
-		clp = find_confirmed_client(clientid, cstate->minorversion,
-					    nn);
-		if (clp == NULL)
-			return nfserr_expired;
+		status = lookup_clientid(clientid, cstate, nn);
+		if (status)
+			return status;
+		clp = cstate->clp;
 		goto new_owner;
 	}
 	if (!(oo->oo_flags & NFS4_OO_CONFIRMED)) {
@@ -3288,7 +3291,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	clp = oo->oo_owner.so_client;
 	goto alloc_stateid;
 new_owner:
-	oo = alloc_init_open_stateowner(strhashval, clp, open, cstate);
+	oo = alloc_init_open_stateowner(strhashval, open, cstate);
 	if (oo == NULL)
 		return nfserr_jukebox;
 	open->op_openowner = oo;
-- 
1.9.3

