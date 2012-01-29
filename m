Return-Path: linux-nfs-owner@vger.kernel.org
Received: from swampdragon.chaosbits.net ([90.184.90.115]:21075 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973Ab2A2V3K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jan 2012 16:29:10 -0500
Date: Sun, 29 Jan 2012 22:29:24 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-nfs@vger.kernel.org
cc: linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Kendrick Smith <kmsmith@umich.edu>, Andy Adamson <kandros@umich.edu>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS4: Fix NULL deref in nfsd4_lock() by makeing unhash_lockowner()
 safe to call with NULL arg
Message-ID: <alpine.LNX.2.00.1201292226380.27749@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Coverity checker noticed a path through nfsd4_lock() where we call
release_lockowner(lock_sop); (at the 'out:' label) where 'lock_sop' is
NULL.
That goes bad since release_lockowner() calls unhash_lockowner() which
dereferences its argument.
release_lockowner() also calls nfs4_free_lockowner(), but that's not a
problem since that function just calls kfree() and kmem_cache_free(),
both of which are safe to call with NULL as argument.

There are several ways to fix the bug.
 - rework nfsd4_lock() so the call to release_lockowner(NULL) will never happen.
 - let release_lockowner() test for NULL and return if given one.
 - let unhash_lockowner() test for NULL and return if given one (which makes both it and release_lockowner() safe).

I chose the last option for this patch.

For information, the path Coverity spotted (in defect report 201504) is this:

3950nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
3951           struct nfsd4_lock *lock)
3952{
3953        struct nfs4_openowner *open_sop = NULL;
CID 201504: Explicit null dereferenced (FORWARD_NULL)
Assigning: "lock_sop" = 0.
3954        struct nfs4_lockowner *lock_sop = NULL;
[...]
3964
At conditional (1): "nfsd_debug & 0x10U" taking the true branch.
3965        dprintk("NFSD: nfsd4_lock: start=%Ld length=%Ld\n",
3966                (long long) lock->lk_offset,
3967                (long long) lock->lk_length);
3968
At conditional (2): "check_lock_length(lock->lk_offset, lock->lk_length)" taking the false branch.
3969        if (check_lock_length(lock->lk_offset, lock->lk_length))
[...]
At conditional (3): "status = fh_verify(rqstp, &cstate->current_fh, 32768/*unsigned short*/, 32)" taking the false branch.
3972        if ((status = fh_verify(rqstp, &cstate->current_fh,
[...]
3976        }
3977
3978        nfs4_lock_state();
3979
At conditional (4): "lock->lk_is_new" taking the true branch.
3980        if (lock->lk_is_new) {
[...]
At conditional (5): "nfsd4_has_session(cstate)" taking the true branch.
3988                if (nfsd4_has_session(cstate))
[...]
At conditional (6): "1" taking the true branch.
3994                status = nfserr_stale_clientid;
At conditional (7): "STALE_CLIENTID(&lock->v.new.clientid)" taking the false branch.
3995                if (STALE_CLIENTID(&lock->lk_new_clientid))
3996                        goto out;
[...]
At conditional (8): "status" taking the false branch.
4003                if (status)
4004                        goto out;
4005                open_sop = openowner(open_stp->st_stateowner);
At conditional (9): "1" taking the true branch.
4006                status = nfserr_bad_stateid;
At conditional (10): "!same_clid(&open_sop->oo_owner.so_client->cl_clientid, &lock->v.new.clientid)" taking the false branch.
4007                if (!same_clid(&open_sop->oo_owner.so_client->cl_clientid,
4008                                                &lock->v.new.clientid))
4009                        goto out;
4010                status = lookup_or_create_lock_state(cstate, open_stp, lock,
4011                                                        &lock_stp, &new_state);
At conditional (11): "status" taking the true branch.
4012                if (status)
4013                        goto out;
[...]
4098out:
At conditional (12): "status" taking the true branch.
At conditional (13): "new_state" taking the true branch.
4099        if (status && new_state)
Passing null variable "lock_sop" to function "release_lockowner", which dereferences it. [show details]
4100                release_lockowner(lock_sop);
4101        if (!cstate->replay_owner)
4102                nfs4_unlock_state();
4103        return status;
4104}

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 fs/nfsd/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

 Patch is compile tested only.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e8c98f0..730a73b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -520,6 +520,8 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 {
 	struct nfs4_ol_stateid *stp;
 
+	if (!lo)
+		return;
 	list_del(&lo->lo_owner.so_strhash);
 	list_del(&lo->lo_perstateid);
 	list_del(&lo->lo_owner_ino_hash);
-- 
1.7.8.4


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

