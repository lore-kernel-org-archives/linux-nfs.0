Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:40003 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757917AbaFSOvw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:52 -0400
Received: by mail-qa0-f45.google.com with SMTP id v10so1999366qac.4
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:52 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 038/104] NFSd: nfsd4_process_open2() must reference the open stateid
Date: Thu, 19 Jun 2014 10:49:44 -0400
Message-Id: <1403189450-18729-39-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that nfsd4_process_open2() keeps a reference to the open
stateid until it is done working with it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4878faec4c68..7730a7581798 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2887,6 +2887,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
 	struct nfs4_openowner *oo = open->op_openowner;
 
+	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
 	stp->st_stateowner = &oo->oo_owner;
@@ -3223,6 +3224,7 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 {
 	struct nfs4_ol_stateid *local;
 	struct nfs4_openowner *oo = open->op_openowner;
+	struct nfs4_ol_stateid *ret = NULL;
 
 	spin_lock(&fp->fi_lock);
 	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
@@ -3231,13 +3233,17 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 			continue;
 		/* remember if we have seen this open owner */
 		if (local->st_stateowner == &oo->oo_owner)
-			*stpp = local;
+			ret = local;
 		/* check for conflicting share reservations */
 		if (!test_share(local, open)) {
 			spin_unlock(&fp->fi_lock);
 			return nfserr_share_denied;
 		}
 	}
+	if (ret) {
+		atomic_inc(&ret->st_stid.sc_count);
+		*stpp = ret;
+	}
 	spin_unlock(&fp->fi_lock);
 	return nfs_ok;
 }
@@ -3652,6 +3658,8 @@ out:
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 	if (dp)
 		nfs4_put_delegation(dp);
+	if (stp)
+		put_generic_stateid(stp);
 
 	return status;
 }
-- 
1.9.3

