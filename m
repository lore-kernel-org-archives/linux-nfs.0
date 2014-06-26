Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:37059 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbaFZTON (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:13 -0400
Received: by mail-qg0-f51.google.com with SMTP id z60so3509582qgd.10
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:12 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 019/117] nfsd: declare v4.1+ openowners confirmed on creation
Date: Thu, 26 Jun 2014 15:11:59 -0400
Message-Id: <1403810017-16062-20-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's no need to confirm an openowner in v4.1 and above, so we can
go ahead and set NFS4_OO_CONFIRMED when we create openowners in
those versions. This will also be necessary when we remove the
client_mutex, as it'll be possible for two concurrent opens to race
in versions >4.0.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a5bb96b97f09..44e98e5fe44a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2773,7 +2773,10 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 }
 
 static struct nfs4_openowner *
-alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
+alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp,
+			   struct nfsd4_open *open,
+			   struct nfsd4_compound_state *cstate)
+{
 	struct nfs4_openowner *oo;
 
 	oo = alloc_stateowner(openowner_slab, &open->op_owner, clp);
@@ -2782,6 +2785,8 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	oo->oo_owner.so_is_open_owner = 1;
 	oo->oo_owner.so_seqid = open->op_seqid;
 	oo->oo_flags = NFS4_OO_NEW;
+	if (nfsd4_has_session(cstate))
+		oo->oo_flags |= NFS4_OO_CONFIRMED;
 	oo->oo_time = 0;
 	oo->oo_last_closed_stid = NULL;
 	INIT_LIST_HEAD(&oo->oo_close_lru);
@@ -3047,7 +3052,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	clp = oo->oo_owner.so_client;
 	goto alloc_stateid;
 new_owner:
-	oo = alloc_init_open_stateowner(strhashval, clp, open);
+	oo = alloc_init_open_stateowner(strhashval, clp, open, cstate);
 	if (oo == NULL)
 		return nfserr_jukebox;
 	open->op_openowner = oo;
@@ -3457,8 +3462,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	if (nfsd4_has_session(&resp->cstate)) {
-		open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
-
 		if (open->op_deleg_want & NFS4_SHARE_WANT_NO_DELEG) {
 			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
 			open->op_why_no_deleg = WND4_NOT_WANTED;
@@ -3852,8 +3855,9 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 
-	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
-				      &s, cstate->minorversion, nn);
+	status = nfsd4_lookup_stateid(stateid,
+				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
+				&s, cstate->minorversion, nn);
 	if (status)
 		goto out;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
-- 
1.9.3

