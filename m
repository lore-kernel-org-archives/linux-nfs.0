Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:46205 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932153AbaGUNfa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 09:35:30 -0400
Received: by mail-qc0-f177.google.com with SMTP id o8so5588436qcw.36
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 06:35:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: [PATCH v5 10/10] nfsd: give block_delegation and delegation_blocked its own spinlock
Date: Mon, 21 Jul 2014 09:35:06 -0400
Message-Id: <1405949706-27757-11-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
References: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The state lock can be fairly heavily contended, and there's no reason
that nfs4_file lookups and delegation_blocked should be mutually
exclusive.  Let's give the new block_delegation code its own spinlock.
It does mean that we'll need to take a different lock in the delegation
break code, but that's not generally as critical to performance.

Cc: Neil Brown <neilb@suse.de>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 18d1b60f506f..3946a5a9459c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -506,10 +506,11 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
  * Each filter is 256 bits.  We hash the filehandle to 32bit and use the
  * low 3 bytes as hash-table indices.
  *
- * 'state_lock', which is always held when block_delegations() is called,
+ * 'blocked_delegations_lock', which is always taken in block_delegations(),
  * is used to manage concurrent access.  Testing does not need the lock
  * except when swapping the two filters.
  */
+static DEFINE_SPINLOCK(blocked_delegations_lock);
 static struct bloom_pair {
 	int	entries, old_entries;
 	time_t	swap_time;
@@ -525,7 +526,7 @@ static int delegation_blocked(struct knfsd_fh *fh)
 	if (bd->entries == 0)
 		return 0;
 	if (seconds_since_boot() - bd->swap_time > 30) {
-		spin_lock(&state_lock);
+		spin_lock(&blocked_delegations_lock);
 		if (seconds_since_boot() - bd->swap_time > 30) {
 			bd->entries -= bd->old_entries;
 			bd->old_entries = bd->entries;
@@ -534,7 +535,7 @@ static int delegation_blocked(struct knfsd_fh *fh)
 			bd->new = 1-bd->new;
 			bd->swap_time = seconds_since_boot();
 		}
-		spin_unlock(&state_lock);
+		spin_unlock(&blocked_delegations_lock);
 	}
 	hash = arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
 	if (test_bit(hash&255, bd->set[0]) &&
@@ -555,16 +556,16 @@ static void block_delegations(struct knfsd_fh *fh)
 	u32 hash;
 	struct bloom_pair *bd = &blocked_delegations;
 
-	lockdep_assert_held(&state_lock);
-
 	hash = arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
 
+	spin_lock(&blocked_delegations_lock);
 	__set_bit(hash&255, bd->set[bd->new]);
 	__set_bit((hash>>8)&255, bd->set[bd->new]);
 	__set_bit((hash>>16)&255, bd->set[bd->new]);
 	if (bd->entries == 0)
 		bd->swap_time = seconds_since_boot();
 	bd->entries += 1;
+	spin_unlock(&blocked_delegations_lock);
 }
 
 static struct nfs4_delegation *
@@ -3091,16 +3092,16 @@ void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
-	/*
-	 * We can't do this in nfsd_break_deleg_cb because it is
-	 * already holding inode->i_lock
-	 */
-	spin_lock(&state_lock);
 	block_delegations(&dp->dl_fh);
+
 	/*
+	 * We can't do this in nfsd_break_deleg_cb because it is
+	 * already holding inode->i_lock.
+	 *
 	 * If the dl_time != 0, then we know that it has already been
 	 * queued for a lease break. Don't queue it again.
 	 */
+	spin_lock(&state_lock);
 	if (dp->dl_time == 0) {
 		dp->dl_time = get_seconds();
 		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
-- 
1.9.3

