Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33451 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbbGMJfP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:35:15 -0400
Received: by pdbqm3 with SMTP id qm3so77498452pdb.0
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:35:15 -0700 (PDT)
Message-ID: <55A3864E.20206@gmail.com>
Date: Mon, 13 Jul 2015 17:35:10 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 13/14] nfsd: Use lk_new_xxx instead of v.new.xxx for nfs4_lockowner
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 13df582..2704270 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5322,9 +5322,9 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 	struct nfs4_lockowner *lo;
 	unsigned int strhashval;
 
-	lo = find_lockowner_str(&cl->cl_clientid, &lock->v.new.owner, cl);
+	lo = find_lockowner_str(&cl->cl_clientid, &lock->lk_new_owner, cl);
 	if (!lo) {
-		strhashval = ownerstr_hashval(&lock->v.new.owner);
+		strhashval = ownerstr_hashval(&lock->lk_new_owner);
 		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
 		if (lo == NULL)
 			return nfserr_jukebox;
@@ -5385,7 +5385,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (lock->lk_is_new) {
 		if (nfsd4_has_session(cstate))
 			/* See rfc 5661 18.10.3: given clientid is ignored: */
-			memcpy(&lock->v.new.clientid,
+			memcpy(&lock->lk_new_clientid,
 				&cstate->session->se_client->cl_clientid,
 				sizeof(clientid_t));
 
@@ -5403,7 +5403,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		open_sop = openowner(open_stp->st_stateowner);
 		status = nfserr_bad_stateid;
 		if (!same_clid(&open_sop->oo_owner.so_client->cl_clientid,
-						&lock->v.new.clientid))
+						&lock->lk_new_clientid))
 			goto out;
 		status = lookup_or_create_lock_state(cstate, open_stp, lock,
 							&lock_stp, &new);
-- 
2.4.3

