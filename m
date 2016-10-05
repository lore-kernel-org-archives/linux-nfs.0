Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Wed, 05 Oct 2016 17:15:31 +1100
Subject: [PATCH 3/3] NFSv4: enhance nfs4_copy_lock_stateid to use a flock
 stateid if there is one
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <147564813178.1201.12251250171642290143.stgit@noble>
In-Reply-To: <147564712849.1201.16474326551460993904.stgit@noble>
References: <147564712849.1201.16474326551460993904.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

A process can have two possible lock contexts for a given open file:
a per-process Posix lock context and a per-open-file flock lock context.
Use both of these when searching for a suitable stateid to use.

With this patch, READ/WRITE requests will use the correct stateid
if a flock lock is active.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/nfs4state.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 94a6631e7938..74cc32490c7a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -800,11 +800,13 @@ void nfs4_close_sync(struct nfs4_state *state, fmode_t fmode)
  * that is compatible with current->files
  */
 static struct nfs4_lock_state *
-__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
+__nfs4_find_lock_state(struct nfs4_state *state,
+		       fl_owner_t fl_owner, fl_owner_t fl_owner2)
 {
 	struct nfs4_lock_state *pos;
 	list_for_each_entry(pos, &state->lock_states, ls_locks) {
-		if (pos->ls_owner != fl_owner)
+		if (pos->ls_owner != fl_owner &&
+		    pos->ls_owner != fl_owner2)
 			continue;
 		atomic_inc(&pos->ls_count);
 		return pos;
@@ -857,7 +859,7 @@ static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_
 	
 	for(;;) {
 		spin_lock(&state->state_lock);
-		lsp = __nfs4_find_lock_state(state, owner);
+		lsp = __nfs4_find_lock_state(state, owner, 0);
 		if (lsp != NULL)
 			break;
 		if (new != NULL) {
@@ -946,18 +948,21 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 	 * and we can choose a lock context relevant for the current process
 	 */
 	struct nfs4_lock_state *lsp;
-	fl_owner_t fl_owner;
+	fl_owner_t fl_owner, fl_flock_owner;
 	int ret = -ENOENT;
 
 	if (test_bit(LK_STATE_IN_USE, &state->flags) == 0)
 		goto out;
 
-	if (l_ctx == NULL)
+	if (l_ctx == NULL) {
 		fl_owner = current->files;
-	else
+		fl_flock_owner = 0;
+	} else {
 		fl_owner = l_ctx->lockowner.l_owner;
+		fl_flock_owner = l_ctx->open_context->flock_context.lockowner.l_owner;
+	}
 	spin_lock(&state->state_lock);
-	lsp = __nfs4_find_lock_state(state, fl_owner);
+	lsp = __nfs4_find_lock_state(state, fl_owner, fl_flock_owner);
 	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
 		ret = -EIO;
 	else if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0) {
