Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:42950 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385AbaF3Pvs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:48 -0400
Received: by mail-qc0-f176.google.com with SMTP id w7so7300257qcr.35
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:47 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 053/114] nfsd: Prepare nfsd4_close() for open stateid referencing
Date: Mon, 30 Jun 2014 11:49:22 -0400
Message-Id: <1404143423-24381-54-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
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
index 9bf706f4b82b..08e3ab9c82f0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4528,10 +4528,15 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
+	put_generic_stateid(stp);
 out:
 	nfs4_unlock_state();
 	return status;
-- 
1.9.3

