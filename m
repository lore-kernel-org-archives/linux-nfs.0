Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:58768 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbaGUPDS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:18 -0400
Received: by mail-qg0-f47.google.com with SMTP id i50so5461840qgf.6
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:17 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 13/40] nfsd: nfsd4_locku() must reference the lock stateid
Date: Mon, 21 Jul 2014 11:02:25 -0400
Message-Id: <1405954972-28904-14-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that nfsd4_locku() keeps a reference to the lock stateid
until it is done working with it. Necessary step toward client_mutex
removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9a2f1ccb7502..0720e0888753 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5156,10 +5156,12 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&stp, nn);
 	if (status)
 		goto out;
+	/* FIXME: move into nfs4_preprocess_seqid_op */
+	atomic_inc(&stp->st_stid.sc_count);
 	filp = find_any_file(stp->st_stid.sc_file);
 	if (!filp) {
 		status = nfserr_lock_range;
-		goto out;
+		goto put_stateid;
 	}
 	file_lock = locks_alloc_lock();
 	if (!file_lock) {
@@ -5189,6 +5191,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 fput:
 	fput(filp);
+put_stateid:
+	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
-- 
1.9.3

