Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:40037 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385AbaF3Pvq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:46 -0400
Received: by mail-qa0-f47.google.com with SMTP id hw13so6494943qab.20
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:46 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 052/114] nfsd: nfsd4_process_open2() must reference the open stateid
Date: Mon, 30 Jun 2014 11:49:21 -0400
Message-Id: <1404143423-24381-53-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that nfsd4_process_open2() keeps a reference to the open
stateid until it is done working with it. Necessary step toward
client_mutex removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 96ae19a0597d..9bf706f4b82b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2979,6 +2979,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
 	struct nfs4_openowner *oo = open->op_openowner;
 
+	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
 	stp->st_stateowner = &oo->oo_owner;
@@ -3349,6 +3350,7 @@ nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
 		/* remember if we have seen this open owner */
 		if (local->st_stateowner == &oo->oo_owner) {
 			ret = local;
+			atomic_inc(&ret->st_stid.sc_count);
 			break;
 		}
 	}
@@ -3792,6 +3794,8 @@ out:
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 	if (dp)
 		nfs4_put_delegation(dp);
+	if (stp)
+		put_generic_stateid(stp);
 
 	return status;
 }
-- 
1.9.3

