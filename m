Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:42150 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbaG2Uer (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:47 -0400
Received: by mail-qa0-f48.google.com with SMTP id m5so266773qaj.35
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:46 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 11/38] nfsd: nfsd4_locku() must reference the lock stateid
Date: Tue, 29 Jul 2014 16:33:54 -0400
Message-Id: <1406666061-14175-12-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
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
index 21963664fbb7..65e20c4bc257 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5147,10 +5147,12 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -5180,6 +5182,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 fput:
 	fput(filp);
+put_stateid:
+	nfs4_put_stid(&stp->st_stid);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
-- 
1.9.3

