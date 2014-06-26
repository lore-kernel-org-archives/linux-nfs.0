Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:65445 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbaFZTOS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:18 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so3508650qgf.15
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:17 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 023/117] nfsd: Convert nfsd4_process_open1() to work with lookup_clientid()
Date: Thu, 26 Jun 2014 15:12:03 -0400
Message-Id: <1403810017-16062-24-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

...and have alloc_init_open_stateowner just use the cstate->clp pointer
instead of passing in a clp separately. This allows us to use the
cached nfs4_client pointer in the cstate instead of having to look it
up again.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fb78d1ab2655..ab45350fbd5a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -71,6 +71,9 @@ static u64 current_sessionid = 1;
 
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
+static __be32 lookup_clientid(clientid_t *clid,
+		struct nfsd4_compound_state *cstate,
+		struct nfsd_net *nn);
 
 /* Locking: */
 
@@ -2773,10 +2776,10 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 }
 
 static struct nfs4_openowner *
-alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp,
-			   struct nfsd4_open *open,
+alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 			   struct nfsd4_compound_state *cstate)
 {
+	struct nfs4_client *clp = cstate->clp;
 	struct nfs4_openowner *oo;
 
 	oo = alloc_stateowner(openowner_slab, &open->op_owner, clp);
@@ -3033,10 +3036,10 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
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
@@ -3052,7 +3055,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
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

