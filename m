Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:46240 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755123AbaGUPDW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:22 -0400
Received: by mail-qc0-f180.google.com with SMTP id l6so5627847qcy.39
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 16/40] nfsd: nfsd4_process_open2() must reference the open stateid
Date: Mon, 21 Jul 2014 11:02:28 -0400
Message-Id: <1405954972-28904-17-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
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
index 2eaaceef11e8..1022d11031f0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3011,6 +3011,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
 	struct nfs4_openowner *oo = open->op_openowner;
 
+	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
 	stp->st_stateowner = &oo->oo_owner;
@@ -3394,6 +3395,7 @@ nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
 			continue;
 		if (local->st_stateowner == &oo->oo_owner) {
 			ret = local;
+			atomic_inc(&ret->st_stid.sc_count);
 			break;
 		}
 	}
@@ -3854,6 +3856,8 @@ out:
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 	if (dp)
 		nfs4_put_delegation(dp);
+	if (stp)
+		put_generic_stateid(stp);
 
 	return status;
 }
-- 
1.9.3

