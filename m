Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:38430 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754386AbaG2Uey (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:54 -0400
Received: by mail-qg0-f47.google.com with SMTP id i50so308534qgf.6
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 16/38] nfsd: nfsd4_open_confirm() must reference the open stateid
Date: Tue, 29 Jul 2014 16:33:59 -0400
Message-Id: <1406666061-14175-17-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that nfsd4_open_confirm() keeps a reference to the open
stateid until it is done working with it.

Necessary step toward client_mutex removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 35548d470420..5e31bc6a03a6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4434,10 +4434,12 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					NFS4_OPEN_STID, &stp, nn);
 	if (status)
 		goto out;
+	/* FIXME: move into nfs4_preprocess_seqid_op */
+	atomic_inc(&stp->st_stid.sc_count);
 	oo = openowner(stp->st_stateowner);
 	status = nfserr_bad_stateid;
 	if (oo->oo_flags & NFS4_OO_CONFIRMED)
-		goto out;
+		goto put_stateid;
 	oo->oo_flags |= NFS4_OO_CONFIRMED;
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&oc->oc_resp_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
@@ -4446,6 +4448,8 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfsd4_client_record_create(oo->oo_owner.so_client);
 	status = nfs_ok;
+put_stateid:
+	nfs4_put_stid(&stp->st_stid);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
-- 
1.9.3

