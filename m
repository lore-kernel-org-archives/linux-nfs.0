Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41287 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760886Ab3DCSzJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 14:55:09 -0400
Date: Wed, 3 Apr 2013 14:55:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Yanchuan Nian <ycnian@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: fix bug on nfs4 stateid deallocation
Message-ID: <20130403185508.GE6044@fieldses.org>
References: <1362962774-5141-1-git-send-email-ycnian@gmail.com>
 <20130311150208.GB16309@fieldses.org>
 <CAC5OsZPyuOj_3OUJZFu1Haqg=q6GCyyqDL=n+Y5Wr48D1-SkSg@mail.gmail.com>
 <20130402015044.GA12158@fieldses.org>
 <20130403105843.GA22704@mail.example.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130403105843.GA22704@mail.example.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 03, 2013 at 06:58:43PM +0800, Yanchuan Nian wrote:
> On Mon, Apr 01, 2013 at 09:50:44PM -0400, J. Bruce Fields wrote:
> > On Wed, Mar 13, 2013 at 11:04:54PM +0800, Yanchuan Nian wrote:
> > > 2013/3/11 J. Bruce Fields <bfields@fieldses.org>
> > > 
> > > > On Mon, Mar 11, 2013 at 08:46:14AM +0800, ycnian@gmail.com wrote:
> > > > > NFS4_OO_PURGE_CLOSE is not handled properly. To avoid memory leak, nfs4
> > > > > stateid which is pointed by oo_last_closed_stid is freed in
> > > > nfsd4_close(),
> > > > > but NFS4_OO_PURGE_CLOSE isn't cleared meanwhile. So the stateid released
> > > > in
> > > > > THIS close procedure may be freed immediately in the coming encoding
> > > > function.
> > > >
> > > > OK, makes sense.  This code is confusing, I wonder if there's some way
> > > > we could make it simpler.
> > > >
> > > 
> > > The only purpose of NFS4_OO_PURGE_CLOSE is to decide whether the stateid
> > > pointed by last-closed-stateid should be freed or not. I wonder if this
> > > flag is necessary. oo_last_closed_stid is set only in CLOSE, so in other
> > > procedures, if the pointer is not NULL, it must be set in previous
> > > procedure, we can free it directly. In CLOSE procedure, we also free it
> > > directly before asigning the new released stateid to it in nfsd4_close(),
> > > and then we can ignore it in nfsd4_encode_close(). What do you think?
> > 
> > Yeah, something like that would be simpler, I think.  Maybe the
> > following?  (On top of your patch.)
> 

> This patch may cause memory leak in NFSv4.1. If the stateid released
> is the last one in nfs4_openowner, nfs4_openowner will be deallocated
> immediately, and NULL will be assigned to cstate->replay_owner at the
> same time. In this situation encode_seqid_op_tail() cannot be called.
> To avoid this problem, we can free the stateid just before or after
> nfs4_opwnowner deallocation.

Yes, thanks for catching that!:

 	nfsd4_close_open_stateid(stp);
-	close->cl_closed_stateid = stp;
+	if (cstate->minorversion) {
+		unhash_stid(&stp->st_stid);
+		free_generic_stateid(stp);
+	} else
+		close->cl_closed_stateid = stp;
 
 	if (list_empty(&oo->oo_owner.so_stateids)) {
 		if (cstate->minorversion) {

> Another question, cl_stateid in struct nfsd4_close will be returned to
> the client, so original comment is right even though applying this
> patch. Can this struct be commented like this.
> 
> struct nfsd4_close {
>         u32             cl_seqid;           /* request */
>         stateid_t       cl_stateid;         /* request+response */
>         struct nfs4_ol_stateid *cl_closed_stateid; /* used during processing */

Agreed; done.  The result is the following (untested).

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3e1101a..9bd6653 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -674,7 +674,7 @@ static void unhash_openowner(struct nfs4_openowner *oo)
 	}
 }
 
-static void release_last_closed_stateid(struct nfs4_openowner *oo)
+void release_last_closed_stateid(struct nfs4_openowner *oo)
 {
 	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
 
@@ -3783,26 +3783,6 @@ out:
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
@@ -3839,9 +3819,11 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	nfsd4_close_open_stateid(stp);
-	release_last_closed_stateid(oo);
-	oo->oo_flags &= ~NFS4_OO_PURGE_CLOSE;
-	oo->oo_last_closed_stid = stp;
+	if (cstate->minorversion) {
+		unhash_stid(&stp->st_stid);
+		free_generic_stateid(stp);
+	} else
+		close->cl_closed_stateid = stp;
 
 	if (list_empty(&oo->oo_owner.so_stateids)) {
 		if (cstate->minorversion) {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 700de01..60e196f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -527,6 +527,7 @@ nfsd4_decode_close(struct nfsd4_compoundargs *argp, struct nfsd4_close *close)
 {
 	DECODE_HEAD;
 
+	close->cl_closed_stateid = NULL;
 	READ_BUF(4);
 	READ32(close->cl_seqid);
 	return nfsd4_decode_stateid(argp, &close->cl_stateid);
@@ -1707,8 +1708,7 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
  * Note that we increment sequence id's here, at the last moment, so we're sure
  * we know whether the error to be returned is a sequence id mutating error.
  */
-
-static void encode_seqid_op_tail(struct nfsd4_compoundres *resp, __be32 *save, __be32 nfserr)
+static void encode_seqid_op_tail(struct nfsd4_compoundres *resp, __be32 *save, __be32 nfserr, struct nfs4_ol_stateid *close_stp)
 {
 	struct nfs4_stateowner *stateowner = resp->cstate.replay_owner;
 
@@ -1719,7 +1719,13 @@ static void encode_seqid_op_tail(struct nfsd4_compoundres *resp, __be32 *save, _
 			  (char *)resp->p - (char *)save;
 		memcpy(stateowner->so_replay.rp_buf, save,
 			stateowner->so_replay.rp_buflen);
-		nfsd4_purge_closed_stateid(stateowner);
+		if (stateowner->so_is_open_owner) {
+			struct nfs4_openowner *oo = openowner(stateowner);
+
+			release_last_closed_stateid(oo);
+			if (close_stp)
+				oo->oo_last_closed_stid = close_stp;
+		}
 	}
 }
 
@@ -2667,7 +2673,7 @@ nfsd4_encode_close(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_c
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &close->cl_stateid);
 
-	encode_seqid_op_tail(resp, save, nfserr);
+	encode_seqid_op_tail(resp, save, nfserr, close->cl_closed_stateid);
 	return nfserr;
 }
 
@@ -2770,7 +2776,7 @@ nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lo
 	else if (nfserr == nfserr_denied)
 		nfsd4_encode_lock_denied(resp, &lock->lk_denied);
 
-	encode_seqid_op_tail(resp, save, nfserr);
+	encode_seqid_op_tail(resp, save, nfserr, NULL);
 	return nfserr;
 }
 
@@ -2790,7 +2796,7 @@ nfsd4_encode_locku(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_l
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &locku->lu_stateid);
 
-	encode_seqid_op_tail(resp, save, nfserr);
+	encode_seqid_op_tail(resp, save, nfserr, NULL);
 	return nfserr;
 }
 
@@ -2885,7 +2891,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	}
 	/* XXX save filehandle here */
 out:
-	encode_seqid_op_tail(resp, save, nfserr);
+	encode_seqid_op_tail(resp, save, nfserr, NULL);
 	return nfserr;
 }
 
@@ -2897,7 +2903,7 @@ nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, __be32 nfserr, struct
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &oc->oc_resp_stateid);
 
-	encode_seqid_op_tail(resp, save, nfserr);
+	encode_seqid_op_tail(resp, save, nfserr, NULL);
 	return nfserr;
 }
 
@@ -2909,7 +2915,7 @@ nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struc
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &od->od_stateid);
 
-	encode_seqid_op_tail(resp, save, nfserr);
+	encode_seqid_op_tail(resp, save, nfserr, NULL);
 	return nfserr;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f6ae4db..477f027 100644
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
 
@@ -477,7 +476,7 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
 extern void put_client_renew(struct nfs4_client *clp);
-extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
+extern void release_last_closed_stateid(struct nfs4_openowner *);
 
 /* nfs4recover operations */
 extern int nfsd4_client_tracking_init(struct net *net);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 40e05e6..4d501db 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -91,7 +91,8 @@ struct nfsd4_access {
 
 struct nfsd4_close {
 	u32		cl_seqid;           /* request */
-	stateid_t	cl_stateid;         /* request+response */
+	stateid_t	cl_stateid;         /* request */
+	struct nfs4_ol_stateid *cl_closed_stateid; /* used during processing */
 };
 
 struct nfsd4_commit {
