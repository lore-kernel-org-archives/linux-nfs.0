Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:59177 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbaFZTPF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:15:05 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so3196646qab.3
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:15:04 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 058/117] nfsd: nfsd4_open_confirm() must reference the open stateid
Date: Thu, 26 Jun 2014 15:12:38 -0400
Message-Id: <1403810017-16062-59-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
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
index 828205fabd3e..32d0238cb0bf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4397,10 +4397,12 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -4409,6 +4411,8 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfsd4_client_record_create(oo->oo_owner.so_client);
 	status = nfs_ok;
+put_stateid:
+	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
-- 
1.9.3

