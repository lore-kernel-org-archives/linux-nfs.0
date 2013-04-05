Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35281 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161777Ab3DEOUm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 10:20:42 -0400
Date: Fri, 5 Apr 2013 10:20:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Yanchuan Nian <ycnian@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: fix bug on nfs4 stateid deallocation
Message-ID: <20130405142042.GB2335@fieldses.org>
References: <1362962774-5141-1-git-send-email-ycnian@gmail.com>
 <20130311150208.GB16309@fieldses.org>
 <CAC5OsZPyuOj_3OUJZFu1Haqg=q6GCyyqDL=n+Y5Wr48D1-SkSg@mail.gmail.com>
 <20130402015044.GA12158@fieldses.org>
 <20130403105843.GA22704@mail.example.com>
 <20130403185508.GE6044@fieldses.org>
 <20130404140403.GA2134@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130404140403.GA2134@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 04, 2013 at 10:04:03PM +0800, Yanchuan Nian wrote:
> On Wed, Apr 03, 2013 at 02:55:08PM -0400, J. Bruce Fields wrote:
> > On Wed, Apr 03, 2013 at 06:58:43PM +0800, Yanchuan Nian wrote:
> > > On Mon, Apr 01, 2013 at 09:50:44PM -0400, J. Bruce Fields wrote:
> > > > On Wed, Mar 13, 2013 at 11:04:54PM +0800, Yanchuan Nian wrote:
> > > > > 2013/3/11 J. Bruce Fields <bfields@fieldses.org>
> > > > > 
> > > > > > On Mon, Mar 11, 2013 at 08:46:14AM +0800, ycnian@gmail.com wrote:
> > > > > > > NFS4_OO_PURGE_CLOSE is not handled properly. To avoid memory leak, nfs4
> > > > > > > stateid which is pointed by oo_last_closed_stid is freed in
> > > > > > nfsd4_close(),
> > > > > > > but NFS4_OO_PURGE_CLOSE isn't cleared meanwhile. So the stateid released
> > > > > > in
> > > > > > > THIS close procedure may be freed immediately in the coming encoding
> > > > > > function.
> > > > > >
> > > > > > OK, makes sense.  This code is confusing, I wonder if there's some way
> > > > > > we could make it simpler.
> > > > > >
> > > > > 
> > > > > The only purpose of NFS4_OO_PURGE_CLOSE is to decide whether the stateid
> > > > > pointed by last-closed-stateid should be freed or not. I wonder if this
> > > > > flag is necessary. oo_last_closed_stid is set only in CLOSE, so in other
> > > > > procedures, if the pointer is not NULL, it must be set in previous
> > > > > procedure, we can free it directly. In CLOSE procedure, we also free it
> > > > > directly before asigning the new released stateid to it in nfsd4_close(),
> > > > > and then we can ignore it in nfsd4_encode_close(). What do you think?
> > > > 
> > > > Yeah, something like that would be simpler, I think.  Maybe the
> > > > following?  (On top of your patch.)
> > > 
> > 
> > > This patch may cause memory leak in NFSv4.1. If the stateid released
> > > is the last one in nfs4_openowner, nfs4_openowner will be deallocated
> > > immediately, and NULL will be assigned to cstate->replay_owner at the
> > > same time. In this situation encode_seqid_op_tail() cannot be called.
> > > To avoid this problem, we can free the stateid just before or after
> > > nfs4_opwnowner deallocation.
> > 
> > Yes, thanks for catching that!:
> > 
> >  	nfsd4_close_open_stateid(stp);
> > -	close->cl_closed_stateid = stp;
> > +	if (cstate->minorversion) {
> > +		unhash_stid(&stp->st_stid);
> > +		free_generic_stateid(stp);
> > +	} else
> > +		close->cl_closed_stateid = stp;
> >  
> >  	if (list_empty(&oo->oo_owner.so_stateids)) {
> >  		if (cstate->minorversion) {
> > 
> > > Another question, cl_stateid in struct nfsd4_close will be returned to
> > > the client, so original comment is right even though applying this
> > > patch. Can this struct be commented like this.
> > > 
> > > struct nfsd4_close {
> > >         u32             cl_seqid;           /* request */
> > >         stateid_t       cl_stateid;         /* request+response */
> > >         struct nfs4_ol_stateid *cl_closed_stateid; /* used during processing */
> > 
> > Agreed; done.  The result is the following (untested).
> 
> Yes, it works on my machine. Just the comment of cl_stateid in struct
> nfsd4_close is still a little misleading.

Whoops, fixed.

Actually, I find encode_seqid_op_tail completely confusing, and I don't
see why it's necessary--it would seem more straightforward to do the
seqid bump in the procedure itself.  How about the following?

--b.

commit e58235072acd52ecab71d498b2b06633a2a0c376
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Apr 1 16:37:12 2013 -0400

    nfsd4: cleanup handling of nfsv4.0 closed stateid's
    
    Closed stateid's are kept around a little while to handle close replays
    in the 4.0 case.  So we stash them in the last-used stateid in the
    oo_last_closed_stateid field of the open owner.  We can free that in
    encode_seqid_op_tail once the seqid on the open owner is next
    incremented.  But we don't want to do that on the close itself; so we
    set NFS4_OO_PURGE_CLOSE flag set on the open owner, skip freeing it the
    first time through encode_seqid_op_tail, then when we see that flag set
    next time we free it.
    
    This is unnecessarily baroque.
    
    Instead, just move the logic that increments the seqid out of the xdr
    code and into the operation code itself.
    
    The justification given for the current placement is that we need to
    wait till the last minute to be sure we know whether the status is a
    sequence-id-mutating error or not, but examination of the code shows
    that can't actually happen.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a9b707b..609e1e2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -415,7 +415,8 @@ out:
 	nfsd4_cleanup_open_state(open, status);
 	if (open->op_openowner)
 		cstate->replay_owner = &open->op_openowner->oo_owner;
-	else
+	nfsd4_bump_seqid(cstate, status);
+	if (!cstate->replay_owner)
 		nfs4_unlock_state();
 	return status;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 795b24d..bcd2339 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -720,6 +720,28 @@ dump_sessionid(const char *fn, struct nfs4_sessionid *sessionid)
 }
 #endif
 
+/*
+ * Bump the seqid on cstate->replay_owner, and clear replay_owner if it
+ * won't be used for replay.
+ */
+void nfsd4_bump_seqid(struct nfsd4_compound_state *cstate, __be32 nfserr)
+{
+	struct nfs4_stateowner *so = cstate->replay_owner;
+
+	if (nfserr == nfserr_replay_me)
+		return;
+
+	if (!seqid_mutating_err(ntohl(nfserr))) {
+		cstate->replay_owner = NULL;
+		return;
+	}
+	if (!so)
+		return;
+	if (so->so_is_open_owner)
+		release_last_closed_stateid(openowner(so));
+	so->so_seqid++;
+	return;
+}
 
 static void
 gen_sessionid(struct nfsd4_session *ses)
@@ -3702,6 +3724,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_client_record_create(oo->oo_owner.so_client);
 	status = nfs_ok;
 out:
+	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
 	return status;
@@ -3785,31 +3808,12 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	memcpy(&od->od_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 	status = nfs_ok;
 out:
+	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
 	return status;
 }
 
-void nfsd4_purge_closed_stateid(struct nfs4_stateowner *so)
-{
-	struct nfs4_openowner *oo;
-	struct nfs4_ol_stateid *s;
-
-	if (!so->so_is_open_owner)
-		return;
-	oo = openowner(so);
-	s = oo->oo_last_closed_stid;
-	if (!s)
-		return;
-	if (!(oo->oo_flags & NFS4_OO_PURGE_CLOSE)) {
-		/* Release the last_closed_stid on the next seqid bump: */
-		oo->oo_flags |= NFS4_OO_PURGE_CLOSE;
-		return;
-	}
-	oo->oo_flags &= ~NFS4_OO_PURGE_CLOSE;
-	release_last_closed_stateid(oo);
-}
-
 static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 {
 	unhash_open_stateid(s);
@@ -3838,17 +3842,20 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&close->cl_stateid,
 					NFS4_OPEN_STID|NFS4_CLOSED_STID,
 					&stp, nn);
+	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
 	oo = openowner(stp->st_stateowner);
-	status = nfs_ok;
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	nfsd4_close_open_stateid(stp);
-	release_last_closed_stateid(oo);
-	oo->oo_flags &= ~NFS4_OO_PURGE_CLOSE;
-	oo->oo_last_closed_stid = stp;
+
+	if (cstate->minorversion) {
+		unhash_stid(&stp->st_stid);
+		free_generic_stateid(stp);
+	} else
+		oo->oo_last_closed_stid = stp;
 
 	if (list_empty(&oo->oo_owner.so_stateids)) {
 		if (cstate->minorversion) {
@@ -4270,6 +4277,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out:
 	if (status && new_state)
 		release_lockowner(lock_sop);
+	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
 	if (file_lock)
@@ -4439,6 +4447,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 out:
+	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
 	if (file_lock)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 700de01..a5e8a64 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1701,28 +1701,6 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 								\
 	save = resp->p;
 
-/*
- * Routine for encoding the result of a "seqid-mutating" NFSv4 operation.  This
- * is where sequence id's are incremented, and the replay cache is filled.
- * Note that we increment sequence id's here, at the last moment, so we're sure
- * we know whether the error to be returned is a sequence id mutating error.
- */
-
-static void encode_seqid_op_tail(struct nfsd4_compoundres *resp, __be32 *save, __be32 nfserr)
-{
-	struct nfs4_stateowner *stateowner = resp->cstate.replay_owner;
-
-	if (seqid_mutating_err(ntohl(nfserr)) && stateowner) {
-		stateowner->so_seqid++;
-		stateowner->so_replay.rp_status = nfserr;
-		stateowner->so_replay.rp_buflen =
-			  (char *)resp->p - (char *)save;
-		memcpy(stateowner->so_replay.rp_buf, save,
-			stateowner->so_replay.rp_buflen);
-		nfsd4_purge_closed_stateid(stateowner);
-	}
-}
-
 /* Encode as an array of strings the string given with components
  * separated @sep, escaped with esc_enter and esc_exit.
  */
@@ -2667,7 +2645,6 @@ nfsd4_encode_close(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_c
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &close->cl_stateid);
 
-	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -2770,7 +2747,6 @@ nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lo
 	else if (nfserr == nfserr_denied)
 		nfsd4_encode_lock_denied(resp, &lock->lk_denied);
 
-	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -2790,7 +2766,6 @@ nfsd4_encode_locku(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_l
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &locku->lu_stateid);
 
-	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -2885,7 +2860,6 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	}
 	/* XXX save filehandle here */
 out:
-	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -2897,7 +2871,6 @@ nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, __be32 nfserr, struct
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &oc->oc_resp_stateid);
 
-	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -2909,7 +2882,6 @@ nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struc
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &od->od_stateid);
 
-	encode_seqid_op_tail(resp, save, nfserr);
 	return nfserr;
 }
 
@@ -3567,6 +3539,7 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
 void
 nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
+	struct nfs4_stateowner *so = resp->cstate.replay_owner;
 	__be32 *statp;
 	__be32 *p;
 
@@ -3583,6 +3556,11 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	/* nfsd4_check_drc_limit guarantees enough room for error status */
 	if (!op->status)
 		op->status = nfsd4_check_resp_size(resp, 0);
+	if (so) {
+		so->so_replay.rp_status = op->status;
+		so->so_replay.rp_buflen = (char *)resp->p - (char *)(statp+1);
+		memcpy(so->so_replay.rp_buf, statp+1, so->so_replay.rp_buflen);
+	}
 status:
 	/*
 	 * Note: We write the status directly, instead of using WRITE32(),
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 7674bc8..13ec485 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -355,7 +355,6 @@ struct nfs4_openowner {
 	struct nfs4_ol_stateid *oo_last_closed_stid;
 	time_t			oo_time; /* time of placement on so_close_lru */
 #define NFS4_OO_CONFIRMED   1
-#define NFS4_OO_PURGE_CLOSE 2
 #define NFS4_OO_NEW         4
 	unsigned char		oo_flags;
 };
@@ -363,7 +362,7 @@ struct nfs4_openowner {
 struct nfs4_lockowner {
 	struct nfs4_stateowner	lo_owner; /* must be first element */
 	struct list_head	lo_owner_ino_hash; /* hash by owner,file */
-	struct list_head        lo_perstateid; /* for lockowners only */
+	struct list_head        lo_perstateid;
 	struct list_head	lo_list; /* for temporary uses */
 };
 
@@ -477,7 +476,6 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
 extern void put_client_renew(struct nfs4_client *clp);
-extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
 
 /* nfs4recover operations */
 extern int nfsd4_client_tracking_init(struct net *net);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 40e05e6..3b271d2 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -623,6 +623,7 @@ extern __be32 nfsd4_test_stateid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_test_stateid *test_stateid);
 extern __be32 nfsd4_free_stateid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_free_stateid *free_stateid);
+extern void nfsd4_bump_seqid(struct nfsd4_compound_state *, __be32 nfserr);
 #endif
 
 /*
