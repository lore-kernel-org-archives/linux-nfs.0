Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:45559 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757917AbaFSOw0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:26 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so2231776qcv.26
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:25 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 060/104] NFSd: Always use lookup_clientid() in nfsd4_process_open1
Date: Thu, 19 Jun 2014 10:50:06 -0400
Message-Id: <1403189450-18729-61-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Preparation for moving the stateowner table into the nfs4_client

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 42c5f487a7a5..4b668d0430b8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3268,19 +3268,19 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
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
@@ -3288,7 +3288,6 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	status = nfsd4_check_seqid(cstate, &oo->oo_owner, open->op_seqid);
 	if (status)
 		return status;
-	clp = oo->oo_owner.so_client;
 	goto alloc_stateid;
 new_owner:
 	oo = alloc_init_open_stateowner(strhashval, open, cstate);
-- 
1.9.3

