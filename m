Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:42550 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbaF3Pu7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:50:59 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so2211822qgf.15
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:50:58 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 017/114] nfsd: Always use lookup_clientid() in nfsd4_process_open1
Date: Mon, 30 Jun 2014 11:48:46 -0400
Message-Id: <1404143423-24381-18-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

In later patches, we'll be moving the stateowner table into the
nfs4_client, and by doing this we ensure that we have a cached
nfs4_client pointer.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 199e9d5e23ac..a482fb97964f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3061,19 +3061,19 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
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
@@ -3081,7 +3081,6 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	status = nfsd4_check_seqid(cstate, &oo->oo_owner, open->op_seqid);
 	if (status)
 		return status;
-	clp = oo->oo_owner.so_client;
 	goto alloc_stateid;
 new_owner:
 	oo = alloc_init_open_stateowner(strhashval, open, cstate);
-- 
1.9.3

