Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:52507 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728Ab3J2JjV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 05:39:21 -0400
Received: by mail-wg0-f46.google.com with SMTP id m15so7931660wgh.25
        for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2013 02:39:20 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 3/7] nfsd4: properly hash delegation in nfs4_setlease
Date: Tue, 29 Oct 2013 11:39:16 +0200
Message-Id: <1383039556-27257-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <526F81DE.6060704@primarydata.com>
References: <526F81DE.6060704@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

keep all accesses via dl_perclnt under the recall_lock.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a66b0ad..405649f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -432,6 +432,13 @@ static void unhash_stid(struct nfs4_stid *s)
 	s->sc_type = 0;
 }
 
+static void
+hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
+{
+	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
+}
+
 /* Called under the state lock. */
 static void
 unhash_delegation(struct nfs4_delegation *dp)
@@ -3035,17 +3042,17 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	if (!fl)
 		return -ENOMEM;
 	fl->fl_file = find_readable_file(fp);
-	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
 	if (status) {
-		list_del_init(&dp->dl_perclnt);
 		locks_free_lock(fl);
 		return status;
 	}
 	fp->fi_lease = fl;
 	fp->fi_deleg_file = get_file(fl->fl_file);
 	atomic_set(&fp->fi_delegees, 1);
-	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	spin_lock(&recall_lock);
+	hash_delegation_locked(dp, fp);
+	spin_unlock(&recall_lock);
 	return 0;
 }
 
@@ -3070,9 +3077,8 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 		goto out_free;
 	}
 	atomic_inc(&fp->fi_delegees);
-	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	hash_delegation_locked(dp, fp);
 	spin_unlock(&recall_lock);
-	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	return 0;
 out_free:
 	put_nfs4_file(fp);
@@ -4871,6 +4877,7 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 	struct nfs4_delegation *dp, *next;
 	u64 count = 0;
 
+	lockdep_assert_held(&recall_lock);
 	list_for_each_entry_safe(dp, next, &clp->cl_delegations, dl_perclnt) {
 		if (victims)
 			list_move(&dp->dl_recall_lru, victims);
-- 
1.8.3.1

