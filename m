Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:51556 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbaFZTOT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:19 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so3173483qab.17
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:19 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 024/117] nfsd: Always use lookup_clientid() in nfsd4_process_open1
Date: Thu, 26 Jun 2014 15:12:04 -0400
Message-Id: <1403810017-16062-25-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

In later patches, we'll be moving the stateowner table into the
nfs4_client, and by doing this we ensure that we have a cached
nfs4_client pointer.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ab45350fbd5a..6b9dbdc52b47 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3032,19 +3032,19 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	if (open->op_file == NULL)
 		return nfserr_jukebox;
 
+	status = lookup_clientid(clientid, cstate, nn);
+	if (status)
+		return status;
+	clp = cstate->clp;
+
 	strhashval = ownerstr_hashval(clientid->cl_id, &open->op_owner);
 	oo = find_openstateowner_str(strhashval, open, cstate->minorversion, nn);
 	open->op_openowner = oo;
 	if (!oo) {
-		status = lookup_clientid(clientid, cstate, nn);
-		if (status)
-			return status;
-		clp = cstate->clp;
 		goto new_owner;
 	}
 	if (!(oo->oo_flags & NFS4_OO_CONFIRMED)) {
 		/* Replace unconfirmed owners without checking for replay. */
-		clp = oo->oo_owner.so_client;
 		release_openowner(oo);
 		open->op_openowner = NULL;
 		goto new_owner;
@@ -3052,7 +3052,6 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	status = nfsd4_check_seqid(cstate, &oo->oo_owner, open->op_seqid);
 	if (status)
 		return status;
-	clp = oo->oo_owner.so_client;
 	goto alloc_stateid;
 new_owner:
 	oo = alloc_init_open_stateowner(strhashval, open, cstate);
-- 
1.9.3

