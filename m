Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:36492 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758066AbaFSOwN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:13 -0400
Received: by mail-qc0-f180.google.com with SMTP id r5so2260306qcx.39
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:13 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 052/104] nfsd: declare v4.1+ openowners confirmed on creation
Date: Thu, 19 Jun 2014 10:49:58 -0400
Message-Id: <1403189450-18729-53-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a80ba729e8b3..28bfffbafb0c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2902,7 +2902,10 @@ static void nfs4_free_openowner(struct nfs4_stateowner *so)
 }
 
 static struct nfs4_openowner *
-alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
+alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp,
+			   struct nfsd4_open *open,
+			   struct nfsd4_compound_state *cstate)
+{
 	struct nfs4_openowner *oo;
 
 	oo = alloc_stateowner(openowner_slab, &open->op_owner, clp);
@@ -2913,6 +2916,8 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	oo->oo_owner.so_is_open_owner = 1;
 	oo->oo_owner.so_seqid = open->op_seqid;
 	oo->oo_flags = NFS4_OO_NEW;
+	if (nfsd4_has_session(cstate))
+		oo->oo_flags |= NFS4_OO_CONFIRMED;
 	oo->oo_time = 0;
 	oo->oo_last_closed_stid = NULL;
 	INIT_LIST_HEAD(&oo->oo_close_lru);
@@ -3185,7 +3190,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	clp = oo->oo_owner.so_client;
 	goto alloc_stateid;
 new_owner:
-	oo = alloc_init_open_stateowner(strhashval, clp, open);
+	oo = alloc_init_open_stateowner(strhashval, clp, open, cstate);
 	if (oo == NULL)
 		return nfserr_jukebox;
 	open->op_openowner = oo;
@@ -3654,8 +3659,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	if (nfsd4_has_session(&resp->cstate)) {
-		open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
-
 		if (open->op_deleg_want & NFS4_SHARE_WANT_NO_DELEG) {
 			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
 			open->op_why_no_deleg = WND4_NOT_WANTED;
-- 
1.9.3

