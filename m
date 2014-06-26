Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:56138 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbaFZTPD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:15:03 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so3659548qcy.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:15:02 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 056/117] nfsd: nfsd4_process_open2() must reference the open stateid
Date: Thu, 26 Jun 2014 15:12:36 -0400
Message-Id: <1403810017-16062-57-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
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
index 5b88cb314b99..bb0676051b6b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3001,6 +3001,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
 	struct nfs4_openowner *oo = open->op_openowner;
 
+	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
 	stp->st_stateowner = &oo->oo_owner;
@@ -3340,6 +3341,7 @@ nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
 		/* remember if we have seen this open owner */
 		if (local->st_stateowner == &oo->oo_owner) {
 			ret = local;
+			atomic_inc(&ret->st_stid.sc_count);
 			break;
 		}
 	}
@@ -3776,6 +3778,8 @@ out:
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 	if (dp)
 		nfs4_put_delegation(dp);
+	if (stp)
+		put_generic_stateid(stp);
 
 	return status;
 }
-- 
1.9.3

