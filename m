Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:60348 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381AbaGHLDX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 07:03:23 -0400
Received: by mail-qg0-f41.google.com with SMTP id i50so5041009qgf.28
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 04:03:22 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 8 Jul 2014 07:03:20 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 2/4] NFSD: Rervert "knfsd: locks: flag NFSv4-owned
 locks"
Message-ID: <20140708070320.1d5646f0@tlielax.poochiereds.net>
In-Reply-To: <53BB6445.3060508@gmail.com>
References: <53BAAAC5.9000106@gmail.com>
	<20140707132633.5eb59753@tlielax.poochiereds.net>
	<53BB6445.3060508@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 08 Jul 2014 11:23:49 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> On 7/8/2014 01:26, Jeff Layton wrote:
> > On Mon, 07 Jul 2014 22:12:21 +0800
> > Kinglong Mee <kinglongmee@gmail.com> wrote:
> > 
> >> Commit d5b9026a67 ([PATCH] knfsd: locks: flag NFSv4-owned locks) using
> >> fl_lmops field in file_lock for checking nfsd4 lockowner.
> >>
> >> But, commit 1a747ee0cc (locks: don't call ->copy_lock methods on return of conflicting locks) causes the fl_lmops of conflock for nfsd4_lock always be NULL.
> >>
> >> Also, commit 0996905f93 (lockd: posix_test_lock() should not call locks_copy_lock()) caused the fl_lmops of conflock for nfsd4_lockt always be NULL too.
> >>
> >> So that, using fl_lmops cannot checking nfsd4 lockowner for it always be NULL.
> >>
> >> This patch save the strhashval in nfs4_lockowner for searching lockownerlike before.
> >>
> >> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >> ---
> >>  fs/nfsd/nfs4state.c | 35 +++++++++++++++++++++++------------
> >>  fs/nfsd/state.h     |  1 +
> >>  2 files changed, 24 insertions(+), 12 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index 9b9474c..1b5afc1 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -4282,18 +4282,30 @@ nfs4_transform_lock_offset(struct file_lock *lock)
> >>  		lock->fl_end = OFFSET_MAX;
> >>  }
> >>  
> >> -/* Hack!: For now, we're defining this just so we can use a pointer to it
> >> - * as a unique cookie to identify our (NFSv4's) posix locks. */
> >> -static const struct lock_manager_operations nfsd_posix_mng_ops  = {
> >> -};
> >> +static bool
> >> +nfs4_verify_lock_stateowner(struct nfs4_lockowner *lo, struct nfsd_net *nn)
> >> +{
> >> +	struct nfs4_stateowner *local = NULL;
> >> +	unsigned hashval = lo->lo_hashval;
> >> +
> >> +	if (hashval >= OWNER_HASH_SIZE)
> >> +		return false;
> >> +
> >> +	list_for_each_entry(local, &nn->ownerstr_hashtbl[hashval], so_strhash) {
> >> +		if (local == &lo->lo_owner)
> >> +			return true;
> >> +	}
> >> +
> >> +	return false;
> >> +}
> >>  
> >>  static inline void
> >> -nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
> >> +nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny,
> >> +			struct nfsd_net *nn)
> >>  {
> >> -	struct nfs4_lockowner *lo;
> >> +	struct nfs4_lockowner *lo = (struct nfs4_lockowner *) fl->fl_owner;
> >>  
> >> -	if (fl->fl_lmops == &nfsd_posix_mng_ops) {
> >> -		lo = (struct nfs4_lockowner *) fl->fl_owner;
> >> +	if (nfs4_verify_lock_stateowner(lo, nn)) {
> >>  		deny->ld_owner.data = kmemdup(lo->lo_owner.so_owner.data,
> >>  					lo->lo_owner.so_owner.len, GFP_KERNEL);
> >>  		if (!deny->ld_owner.data)
> >> @@ -4350,6 +4362,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
> >>  	if (!lo)
> >>  		return NULL;
> >>  	INIT_LIST_HEAD(&lo->lo_owner.so_stateids);
> >> +	lo->lo_hashval = strhashval;
> >>  	lo->lo_owner.so_is_open_owner = 0;
> >>  	/* It is the openowner seqid that will be incremented in encode in the
> >>  	 * case of new lockowners; so increment the lock seqid manually: */
> >> @@ -4564,7 +4577,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>  	file_lock->fl_pid = current->tgid;
> >>  	file_lock->fl_file = filp;
> >>  	file_lock->fl_flags = FL_POSIX;
> >> -	file_lock->fl_lmops = &nfsd_posix_mng_ops;
> >>  	file_lock->fl_start = lock->lk_offset;
> >>  	file_lock->fl_end = last_byte_offset(lock->lk_offset, lock->lk_length);
> >>  	nfs4_transform_lock_offset(file_lock);
> >> @@ -4587,7 +4599,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>  	case (EAGAIN):		/* conflock holds conflicting lock */
> >>  		status = nfserr_denied;
> >>  		dprintk("NFSD: nfsd4_lock: conflicting lock found!\n");
> >> -		nfs4_set_lock_denied(conflock, &lock->lk_denied);
> >> +		nfs4_set_lock_denied(conflock, &lock->lk_denied, nn);
> >>  		break;
> >>  	case (EDEADLK):
> >>  		status = nfserr_deadlock;
> >> @@ -4695,7 +4707,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>  
> >>  	if (file_lock->fl_type != F_UNLCK) {
> >>  		status = nfserr_denied;
> >> -		nfs4_set_lock_denied(file_lock, &lockt->lt_denied);
> >> +		nfs4_set_lock_denied(file_lock, &lockt->lt_denied, nn);
> >>  	}
> >>  out:
> >>  	nfs4_unlock_state();
> >> @@ -4746,7 +4758,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>  	file_lock->fl_pid = current->tgid;
> >>  	file_lock->fl_file = filp;
> >>  	file_lock->fl_flags = FL_POSIX;
> >> -	file_lock->fl_lmops = &nfsd_posix_mng_ops;
> >>  	file_lock->fl_start = locku->lu_offset;
> >>  
> >>  	file_lock->fl_end = last_byte_offset(locku->lu_offset,
> >> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> >> index 1848fed..9ecae58 100644
> >> --- a/fs/nfsd/state.h
> >> +++ b/fs/nfsd/state.h
> >> @@ -362,6 +362,7 @@ struct nfs4_openowner {
> >>  
> >>  struct nfs4_lockowner {
> >>  	struct nfs4_stateowner	lo_owner; /* must be first element */
> >> +	unsigned int		lo_hashval;
> > 
> > Actually, I have another comment here too. I'm not sure there's a lot
> > of value in tracking the lo_hashval here. Why not just recompute it in
> > nfs4_verify_lock_stateowner?
> 
> No, ownerstr_hashval() needs a client which holds the conflicting lock,
> in nfsd4_lock/nfsd4_lockt cannot know the client from vfs_lock_file()
>  or vfs_test_lock().
> 

Right, that was why I mentioned that you'd need to pass down the
nfs4_client pointer to these functions, and then use that to derive the
"nn".

> > 
> > You'd need to pass down a pointer to the nfs4_client in order to do
> > so, but you could do that instead of passing down 'nn' and then
> > just call net_generic on clp->net where you needed it.
> 
> I find patch "[PATCH v3 069/114] nfsd: Move the open owner hash table
> into struct nfs4_client" have remove the client argument from
> ownerstr_hashval().
> 
> So, the lo_hashval isn't needed after that patch.
> After Bruce merging that patch, I will resend a new patch recomputing
> the hash value instead recording in lo_hashval.
> 

Ok. I guess the only question is whether this is a bugfix that needs to
go in before those patches. If so, then we may want to do something
closer to this patch.

It's untested, but it should be OK now that we cache the clp in the
cstate. If this needs to go into 3.16 then we'll need to get that
pointer elsewhere, but that's doable.

-------------------------[snip]------------------------------

[PATCH] NFSD: Rervert "knfsd: locks: flag NFSv4-owned locks"

Commit d5b9026a67 ([PATCH] knfsd: locks: flag NFSv4-owned locks) using
fl_lmops field in file_lock for checking nfsd4 lockowner.

But, commit 1a747ee0cc (locks: don't call ->copy_lock methods on return of conflicting locks) causes the fl_lmops of conflock for nfsd4_lock always be NULL.

Also, commit 0996905f93 (lockd: posix_test_lock() should not call locks_copy_lock()) caused the fl_lmops of conflock for nfsd4_lockt always be NULL too.

So that, using fl_lmops cannot checking nfsd4 lockowner for it always be NULL.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c400ec17915e..00cd7fd17b0f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4312,18 +4312,29 @@ nfs4_transform_lock_offset(struct file_lock *lock)
 		lock->fl_end = OFFSET_MAX;
 }
 
-/* Hack!: For now, we're defining this just so we can use a pointer to it
- * as a unique cookie to identify our (NFSv4's) posix locks. */
-static const struct lock_manager_operations nfsd_posix_mng_ops  = {
-};
+static bool
+nfs4_verify_lock_stateowner(struct nfs4_lockowner *lo, struct nfs4_client *clp)
+{
+	struct nfs4_stateowner *local = NULL;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	unsigned int hashval = ownerstr_hashval(clp->cl_clientid.cl_id,
+						&lo->lo_owner.so_owner);
+
+	list_for_each_entry(local, &nn->ownerstr_hashtbl[hashval], so_strhash) {
+		if (local == &lo->lo_owner)
+			return true;
+	}
+
+	return false;
+}
 
 static inline void
-nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
+nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny,
+			struct nfs4_client *clp)
 {
-	struct nfs4_lockowner *lo;
+	struct nfs4_lockowner *lo = (struct nfs4_lockowner *)fl->fl_owner;
 
-	if (fl->fl_lmops == &nfsd_posix_mng_ops) {
-		lo = (struct nfs4_lockowner *) fl->fl_owner;
+	if (nfs4_verify_lock_stateowner(lo, clp)) {
 		deny->ld_owner.data = kmemdup(lo->lo_owner.so_owner.data,
 					lo->lo_owner.so_owner.len, GFP_KERNEL);
 		if (!deny->ld_owner.data)
@@ -4594,7 +4605,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX;
-	file_lock->fl_lmops = &nfsd_posix_mng_ops;
 	file_lock->fl_start = lock->lk_offset;
 	file_lock->fl_end = last_byte_offset(lock->lk_offset, lock->lk_length);
 	nfs4_transform_lock_offset(file_lock);
@@ -4617,7 +4627,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	case (EAGAIN):		/* conflock holds conflicting lock */
 		status = nfserr_denied;
 		dprintk("NFSD: nfsd4_lock: conflicting lock found!\n");
-		nfs4_set_lock_denied(conflock, &lock->lk_denied);
+		nfs4_set_lock_denied(conflock, &lock->lk_denied,
+					cstate->clp);
 		break;
 	case (EDEADLK):
 		status = nfserr_deadlock;
@@ -4725,7 +4736,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (file_lock->fl_type != F_UNLCK) {
 		status = nfserr_denied;
-		nfs4_set_lock_denied(file_lock, &lockt->lt_denied);
+		nfs4_set_lock_denied(file_lock, &lockt->lt_denied, cstate->clp);
 	}
 out:
 	nfs4_unlock_state();
@@ -4776,7 +4787,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX;
-	file_lock->fl_lmops = &nfsd_posix_mng_ops;
 	file_lock->fl_start = locku->lu_offset;
 
 	file_lock->fl_end = last_byte_offset(locku->lu_offset,
-- 
1.9.3


