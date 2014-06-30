Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:35362 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbaF3Pu6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:50:58 -0400
Received: by mail-qg0-f43.google.com with SMTP id z60so2144484qgd.2
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:50:57 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 016/114] nfsd: Convert nfsd4_process_open1() to work with lookup_clientid()
Date: Mon, 30 Jun 2014 11:48:45 -0400
Message-Id: <1404143423-24381-17-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

...and have alloc_init_open_stateowner just use the cstate->clp pointer
instead of passing in a clp separately. This allows us to use the
cached nfs4_client pointer in the cstate instead of having to look it
up again.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4d162a0e4c6d..199e9d5e23ac 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2773,10 +2773,10 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
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
@@ -3065,10 +3065,10 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
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
@@ -3084,7 +3084,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
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

