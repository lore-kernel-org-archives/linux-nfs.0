Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35117 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbaDRSpS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:18 -0400
Received: by mail-ie0-f172.google.com with SMTP id as1so1902658iec.31
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:17 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 08/70] nfsd4: use state_lock for delegation hashing
Date: Fri, 18 Apr 2014 14:44:02 -0400
Message-Id: <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@primarydata.com>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fe8e1bc9578b..45c4b692e30d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -437,12 +437,20 @@ static void unhash_stid(struct nfs4_stid *s)
 	s->sc_type = 0;
 }
 
+static void
+hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
+{
+	dp->dl_stid.sc_type = NFS4_DELEG_STID;
+	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
+}
+
 /* Called under the state lock. */
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
-	list_del_init(&dp->dl_perclnt);
 	spin_lock(&state_lock);
+	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_recall_lru);
 	spin_unlock(&state_lock);
@@ -3058,12 +3066,12 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
 	if (status)
 		goto out_free;
-	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	fp->fi_lease = fl;
 	fp->fi_deleg_file = get_file(fl->fl_file);
 	atomic_set(&fp->fi_delegees, 1);
-	dp->dl_stid.sc_type = NFS4_DELEG_STID;
-	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	spin_lock(&state_lock);
+	hash_delegation_locked(dp, fp);
+	spin_unlock(&state_lock);
 	return 0;
 out_free:
 	locks_free_lock(fl);
@@ -3091,10 +3099,8 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 		goto out_free;
 	}
 	atomic_inc(&fp->fi_delegees);
-	dp->dl_stid.sc_type = NFS4_DELEG_STID;
-	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	hash_delegation_locked(dp, fp);
 	spin_unlock(&state_lock);
-	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	return 0;
 out_free:
 	put_nfs4_file(fp);
@@ -4898,6 +4904,7 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 	struct nfs4_delegation *dp, *next;
 	u64 count = 0;
 
+	lockdep_assert_held(&state_lock);
 	list_for_each_entry_safe(dp, next, &clp->cl_delegations, dl_perclnt) {
 		if (victims)
 			list_move(&dp->dl_recall_lru, victims);
-- 
1.9.0

