Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:53078 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288AbaGHSFZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:05:25 -0400
Received: by mail-qa0-f51.google.com with SMTP id j7so5041117qaq.38
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:05:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 036/100] nfsd: nfsd4_locku() must reference the lock stateid
Date: Tue,  8 Jul 2014 14:03:24 -0400
Message-Id: <1404842668-22521-37-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
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
index 619dbec92b50..a3cff312d9c2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5128,10 +5128,12 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -5161,6 +5163,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 fput:
 	fput(filp);
+put_stateid:
+	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
-- 
1.9.3

