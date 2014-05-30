Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:51906 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbaE3NJs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 09:09:48 -0400
Received: by mail-qg0-f49.google.com with SMTP id a108so5099728qge.36
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 06:09:48 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 3/9] nfsd4: use recall_lock for delegation hashing
Date: Fri, 30 May 2014 09:09:27 -0400
Message-Id: <1401455373-18207-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@primarydata.com>

This fixes a bug in the handling of the fi_delegations list.

nfs4_setlease does not hold the recall_lock when adding to it. The
client_mutex is held, which prevents against concurrent list changes,
but nfsd_break_deleg_cb does not hold while walking it. New delegations
could theoretically creep onto the list while we're walking it there.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index be6199cc8711..96bdd90b96b1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -433,12 +433,21 @@ static void unhash_stid(struct nfs4_stid *s)
 	s->sc_type = 0;
 }
 
+static void
+hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
+{
+	lockdep_assert_held(&recall_lock);
+
+	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
+}
+
 /* Called under the state lock. */
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
-	list_del_init(&dp->dl_perclnt);
 	spin_lock(&recall_lock);
+	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_recall_lru);
 	spin_unlock(&recall_lock);
@@ -3053,11 +3062,12 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
 	if (status)
 		goto out_free;
-	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	fp->fi_lease = fl;
 	fp->fi_deleg_file = get_file(fl->fl_file);
 	atomic_set(&fp->fi_delegees, 1);
-	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	spin_lock(&recall_lock);
+	hash_delegation_locked(dp, fp);
+	spin_unlock(&recall_lock);
 	return 0;
 out_free:
 	locks_free_lock(fl);
@@ -3078,9 +3088,8 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 		spin_unlock(&recall_lock);
 		return -EAGAIN;
 	}
-	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	hash_delegation_locked(dp, fp);
 	spin_unlock(&recall_lock);
-	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	return 0;
 }
 
@@ -4891,6 +4900,7 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 	struct nfs4_delegation *dp, *next;
 	u64 count = 0;
 
+	lockdep_assert_held(&recall_lock);
 	list_for_each_entry_safe(dp, next, &clp->cl_delegations, dl_perclnt) {
 		if (victims)
 			list_move(&dp->dl_recall_lru, victims);
-- 
1.9.3

