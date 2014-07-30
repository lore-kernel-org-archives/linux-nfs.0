Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:53430 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbaG3BfN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:13 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so638480qgf.21
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:12 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 15/38] nfsd: Prepare nfsd4_close() for open stateid referencing
Date: Tue, 29 Jul 2014 21:34:20 -0400
Message-Id: <1406684083-19736-16-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Prepare nfsd4_close for a future where nfs4_preprocess_seqid_op()
hands it a fully referenced open stateid. Necessary step toward
client_mutex removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f3018cb26769..4e50f14f5bc1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4579,10 +4579,15 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
+	/* FIXME: move into nfs4_preprocess_seqid_op */
+	atomic_inc(&stp->st_stid.sc_count);
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	nfsd4_close_open_stateid(stp);
+
+	/* put reference from nfs4_preprocess_seqid_op */
+	nfs4_put_stid(&stp->st_stid);
 out:
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
-- 
1.9.3

