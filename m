Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:36415 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbcHHNTT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2016 09:19:19 -0400
Received: by mail-qk0-f179.google.com with SMTP id v123so188300073qkh.3
        for <linux-nfs@vger.kernel.org>; Mon, 08 Aug 2016 06:19:18 -0700 (PDT)
Message-ID: <1470662355.844.10.camel@redhat.com>
Subject: Re: [PATCH v2] nfsd: Fix race between FREE_STATEID and LOCK
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date: Mon, 08 Aug 2016 09:19:15 -0400
In-Reply-To: <1470608556.2975.8.camel@redhat.com>
References: <20160807185024.11705.10864.stgit@klimt.1015granger.net>
	 <1470608556.2975.8.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2016-08-07 at 18:22 -0400, Jeff Layton wrote:
> On Sun, 2016-08-07 at 14:53 -0400, Chuck Lever wrote:
> > 
> > When running LTP's nfslock01 test, the Linux client can send a LOCK
> > and a FREE_STATEID request at the same time. The LOCK uses the same
> > lockowner as the stateid sent in the FREE_STATEID request.
> > 
> > The outcome is:
> > 
> > Frame 115025 C FREE_STATEID stateid 2/A
> > Frame 115026 C LOCK offset 672128 len 64
> > Frame 115029 R FREE_STATEID NFS4_OK
> > Frame 115030 R LOCK stateid 3/A

Oh, to be clear here -- I assume this a lk_is_new lock (with an open
stateid in it). Right?

> > Frame 115034 C WRITE stateid 0/A offset 672128 len 64
> > Frame 115038 R WRITE NFS4ERR_BAD_STATEID
> > 
> > In other words, the server returns stateid A in a successful LOCK
> > reply, but it has already released it. Subsequent uses of the
> > stateid fail.
> > 
> > To address this, protect the generation check in nfsd4_free_stateid
> > with the st_mutex. This should guarantee that only one of two
> > outcomes occurs: either LOCK returns a fresh valid stateid, or
> > FREE_STATEID returns NFS4ERR_LOCKS_HELD.
> > 
> > Reported-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> > Fix-suggested-by: Jeff Layton <jlayton@redhat.com>
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > ---
> >  fs/nfsd/nfs4state.c |   19 ++++++++++++-------
> >  1 file changed, 12 insertions(+), 7 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index b921123..07dc1aa 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -4911,19 +4911,20 @@ nfsd4_free_stateid(struct svc_rqst *rqstp,
> > struct nfsd4_compound_state *cstate,
> >  		ret = nfserr_locks_held;
> >  		break;
> >  	case NFS4_LOCK_STID:
> > +		atomic_inc(&s->sc_count);
> > +		spin_unlock(&cl->cl_lock);
> > +		stp = openlockstateid(s);
> > +		mutex_lock(&stp->st_mutex);
> >  		ret = check_stateid_generation(stateid, &s-
> > > 
> > > sc_stateid, 1);
> >  		if (ret)
> > -			break;
> > -		stp = openlockstateid(s);
> > +			goto out_mutex_unlock;
> >  		ret = nfserr_locks_held;
> >  		if (check_for_locks(stp->st_stid.sc_file,
> >  				    lockowner(stp-
> > >st_stateowner)))
> > -			break;
> > -		WARN_ON(!unhash_lock_stateid(stp));
> > -		spin_unlock(&cl->cl_lock);
> > -		nfs4_put_stid(s);
> > +			goto out_mutex_unlock;
> > +		release_lock_stateid(stp);
> >  		ret = nfs_ok;
> > -		goto out;
> > +		goto out_mutex_unlock;
> >  	case NFS4_REVOKED_DELEG_STID:
> >  		dp = delegstateid(s);
> >  		list_del_init(&dp->dl_recall_lru);
> > @@ -4937,6 +4938,10 @@ out_unlock:
> >  	spin_unlock(&cl->cl_lock);
> >  out:
> >  	return ret;
> > +out_mutex_unlock:
> > +	mutex_unlock(&stp->st_mutex);
> > +	nfs4_put_stid(s);
> > +	goto out;
> >  }
> >  
> >  static inline int
> > 
> >  
> 
> Looks good to me.
> 
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Hmm...I think this is not a complete fix though. We also need something
like this patch:

--------------[snip]---------------

[PATCH] nfsd: don't return an already-unhashed lock stateid after
 taking mutex

nfsd4_lock will take the st_mutex before working with the stateid it
gets, but between the time when we drop the cl_lock and take the mutex,
the stateid could become unhashed (a'la FREE_STATEID). If that happens
the lock stateid returned to the client will be forgotten.

Fix this by first moving the st_mutex acquisition into
lookup_or_create_lock_state. Then, have it check to see if the lock
stateid is still hashed after taking the mutex. If it's not, then put
the stateid and try the find/create again.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5d6a28af0f42..1235b1661703 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5653,7 +5653,7 @@ static __be32
 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 			    struct nfs4_ol_stateid *ost,
 			    struct nfsd4_lock *lock,
-			    struct nfs4_ol_stateid **lst, bool *new)
+			    struct nfs4_ol_stateid **plst, bool *new)
 {
 	__be32 status;
 	struct nfs4_file *fi = ost->st_stid.sc_file;
@@ -5661,7 +5661,9 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 	struct nfs4_client *cl = oo->oo_owner.so_client;
 	struct inode *inode = d_inode(cstate->current_fh.fh_dentry);
 	struct nfs4_lockowner *lo;
+	struct nfs4_ol_stateid *lst;
 	unsigned int strhashval;
+	bool hashed;
 
 	lo = find_lockowner_str(cl, &lock->lk_new_owner);
 	if (!lo) {
@@ -5677,12 +5679,27 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 			goto out;
 	}
 
-	*lst = find_or_create_lock_stateid(lo, fi, inode, ost, new);
-	if (*lst == NULL) {
+retry:
+	lst = find_or_create_lock_stateid(lo, fi, inode, ost, new);
+	if (lst == NULL) {
 		status = nfserr_jukebox;
 		goto out;
 	}
+
+	mutex_lock(&lst->st_mutex);
+
+	/* See if it's still hashed to avoid race with FREE_STATEID */
+	spin_lock(&cl->cl_lock);
+	hashed = list_empty(&lst->st_perfile);
+	spin_unlock(&cl->cl_lock);
+
+	if (!hashed) {
+		mutex_unlock(&lst->st_mutex);
+		nfs4_put_stid(&lst->st_stid);
+		goto retry;
+	}
 	status = nfs_ok;
+	*plst = lst;
 out:
 	nfs4_put_stateowner(&lo->lo_owner);
 	return status;
@@ -5752,8 +5769,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		status = lookup_or_create_lock_state(cstate, open_stp, lock,
 							&lock_stp, &new);
-		if (status == nfs_ok)
-			mutex_lock(&lock_stp->st_mutex);
 	} else {
 		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid,
-- 
2.7.4
-- 
Jeff Layton <jlayton@redhat.com>
