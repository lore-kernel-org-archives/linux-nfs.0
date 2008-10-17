From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 3/3] NFSD deferral processing
Date: Fri, 17 Oct 2008 16:46:50 -0400
Message-ID: <RTPCLUEXC1-PRDNY30k000001cc@RTPMVEXC1-PRD.hq.netapp.com>
References: <>
 <1224104426-12293-1-git-send-email-andros@netapp.com>
 <1224104426-12293-2-git-send-email-andros@netapp.com>
 <1224104426-12293-3-git-send-email-andros@netapp.com>
 <1224104426-12293-4-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25541 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753224AbYJQUq7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 16:46:59 -0400
In-Reply-To: <1224104426-12293-4-git-send-email-andros@netapp.com>
References: <>
 <1224104426-12293-1-git-send-email-andros@netapp.com>
 <1224104426-12293-2-git-send-email-andros@netapp.com>
 <1224104426-12293-3-git-send-email-andros@netapp.com>
 <1224104426-12293-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 05:00 PM 10/15/2008, andros@netapp.com wrote:
>From: Andy Adamson <andros@netapp.com>
>
>Use a slab cache for nfsd4_compound_state allocation
>
>Save the struct nfsd4_compound_state and set the save_state callback for
>each request for potential deferral handling.
>
>If an NFSv4 operation causes a deferral, the save_state callback is called
>by svc_defer which saves the defer_data with the deferral, and sets the
>restore_state deferral callback.
>
>fh_put is called so that the deferral is not referencing the file handles,
>allowing umount of the file system.

Can you explain the safety of this? If the COMPOUND starts off with an
operation that uses them, what's the implication of one going stale
partway through? Is fh_verify() when the deferral continues enough to
ensure the fh is protected until the end of the op? There's a comment
at the top of fh_verify() that it is "only called at the start of an nfsproc
call", with some assumptions, for instance.

Tom

>
>Signed-off-by: Andy Adamson<andros@netapp.com>
>---
> fs/nfsd/nfs4proc.c        |   47 +++++++++++++++++++-------------------------
> fs/nfsd/nfs4state.c       |   37 +++++++++++++++++++++++++++++++++++
> include/linux/nfsd/xdr4.h |    5 ++++
> 3 files changed, 62 insertions(+), 27 deletions(-)
>
>diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>index 1c19ff9..e60b359 100644
>--- a/fs/nfsd/nfs4proc.c
>+++ b/fs/nfsd/nfs4proc.c
>@@ -813,37 +813,13 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
> 		nfsdstats.nfs4_opcount[opnum]++;
> }
> 
>-static void cstate_free(struct nfsd4_compound_state *cstate)
>-{
>-	if (cstate == NULL)
>-		return;
>-	fh_put(&cstate->current_fh);
>-	fh_put(&cstate->save_fh);
>-	BUG_ON(cstate->replay_owner);
>-	kfree(cstate);
>-}
>-
>-static struct nfsd4_compound_state *cstate_alloc(void)
>-{
>-	struct nfsd4_compound_state *cstate;
>-
>-	cstate = kmalloc(sizeof(struct nfsd4_compound_state), GFP_KERNEL);
>-	if (cstate == NULL)
>-		return NULL;
>-	fh_init(&cstate->current_fh, NFS4_FHSIZE);
>-	fh_init(&cstate->save_fh, NFS4_FHSIZE);
>-	cstate->replay_owner = NULL;
>-	return cstate;
>-}
>-
> /*
>  * RPC deferral callbacks
>  */
> static void
> nfsd4_release_deferred_state(struct svc_deferred_req *dreq)
> {
>-	nfsd4_clear_respages(dreq->respages, dreq->resused);
>-	cstate_free(dreq->defer_data);
>+	nfsd4_cstate_free(dreq->defer_data, dreq);
> }
> 
> static void
>@@ -926,12 +902,22 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
> 		goto out;
> 
> 	status = nfserr_resource;
>-	cstate = cstate_alloc();
>+	cstate = nfsd4_cstate_alloc(rqstp);
> 	if (cstate == NULL)
> 		goto out;
> 
>+	if (rqstp->rq_deferred && rqstp->rq_deferred->defer_data) {
>+		resp->opcnt = cstate->last_op_cnt;
>+		resp->p = cstate->last_op_p;
>+		fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_NOP);
>+		fh_verify(rqstp, &cstate->save_fh, 0, NFSD_MAY_NOP);
>+	}
>+	rqstp->rq_defer_data = cstate;
>+	rqstp->rq_save_state = nfsd4_save_deferred_state;
>+
> 	status = nfs_ok;
> 	while (!status && resp->opcnt < args->opcnt) {
>+		cstate->last_op_p = resp->p;
> 		op = &args->ops[resp->opcnt++];
> 
> 		dprintk("nfsv4 compound op #%d/%d: %d (%s)\n",
>@@ -996,8 +982,15 @@ encode_op:
> 
> 		nfsd4_increment_op_stats(op->opnum);
> 	}
>+	rqstp->rq_defer_data = NULL;
>+	rqstp->rq_save_state = NULL;
>+
>+	if (status == nfserr_dropit) {
>+		cstate->last_op_cnt = resp->opcnt - 1;
>+		return status;
>+	}
> 
>-	cstate_free(cstate);
>+	nfsd4_cstate_free(cstate, rqstp->rq_deferred);
> out:
> 	nfsd4_release_compoundargs(args);
> 	dprintk("nfsv4 compound returned %d\n", ntohl(status));
>diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>index f266e45..002a57c 100644
>--- a/fs/nfsd/nfs4state.c
>+++ b/fs/nfsd/nfs4state.c
>@@ -91,6 +91,7 @@ static struct kmem_cache *stateowner_slab = NULL;
> static struct kmem_cache *file_slab = NULL;
> static struct kmem_cache *stateid_slab = NULL;
> static struct kmem_cache *deleg_slab = NULL;
>+static struct kmem_cache *cstate_slab;
> 
> void
> nfs4_lock_state(void)
>@@ -442,6 +443,37 @@ static struct nfs4_client *create_client(struct 
>xdr_netobj name, char *recdir)
> 	return clp;
> }
> 
>+void nfsd4_cstate_free(struct nfsd4_compound_state *cstate,
>+		       struct svc_deferred_req *dreq)
>+{
>+	if (dreq && dreq->release_state)
>+		nfsd4_clear_respages(dreq->respages, dreq->resused);
>+	if (cstate == NULL)
>+		return;
>+	fh_put(&cstate->current_fh);
>+	fh_put(&cstate->save_fh);
>+	BUG_ON(cstate->replay_owner);
>+	kmem_cache_free(cstate_slab, cstate);
>+}
>+
>+struct nfsd4_compound_state *nfsd4_cstate_alloc(struct svc_rqst *rqstp)
>+{
>+	struct nfsd4_compound_state *cstate;
>+
>+	if (rqstp->rq_deferred && rqstp->rq_deferred->defer_data) {
>+		cstate = rqstp->rq_deferred->defer_data;
>+		goto out;
>+	}
>+	cstate = kmem_cache_alloc(cstate_slab, GFP_KERNEL);
>+	if (cstate == NULL)
>+		return NULL;
>+	fh_init(&cstate->current_fh, NFS4_FHSIZE);
>+	fh_init(&cstate->save_fh, NFS4_FHSIZE);
>+	cstate->replay_owner = NULL;
>+out:
>+	return cstate;
>+}
>+
> static void copy_verf(struct nfs4_client *target, nfs4_verifier *source)
> {
> 	memcpy(target->cl_verifier.data, source->data,
>@@ -986,6 +1018,7 @@ nfsd4_free_slabs(void)
> 	nfsd4_free_slab(&file_slab);
> 	nfsd4_free_slab(&stateid_slab);
> 	nfsd4_free_slab(&deleg_slab);
>+	nfsd4_free_slab(&cstate_slab);
> }
> 
> static int
>@@ -1007,6 +1040,10 @@ nfsd4_init_slabs(void)
> 			sizeof(struct nfs4_delegation), 0, 0, NULL);
> 	if (deleg_slab == NULL)
> 		goto out_nomem;
>+	cstate_slab = kmem_cache_create("nfsd4_compound_states",
>+			sizeof(struct nfsd4_compound_state), 0, 0, NULL);
>+	if (cstate_slab == NULL)
>+		goto out_nomem;
> 	return 0;
> out_nomem:
> 	nfsd4_free_slabs();
>diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
>index f3495ae..3407f4b 100644
>--- a/include/linux/nfsd/xdr4.h
>+++ b/include/linux/nfsd/xdr4.h
>@@ -48,6 +48,8 @@ struct nfsd4_compound_state {
> 	struct svc_fh current_fh;
> 	struct svc_fh save_fh;
> 	struct nfs4_stateowner *replay_owner;
>+	__be32 *last_op_p;
>+	u32 last_op_cnt;
> };
> 
> struct nfsd4_change_info {
>@@ -447,6 +449,9 @@ extern void nfsd4_cache_rqst_pages(struct svc_rqst *rqstp,
> 		struct page **respages, short *resused);
> extern void nfsd4_restore_rqst_pages(struct svc_rqst *rqstp,
> 		struct page **respages, short resused);
>+extern struct nfsd4_compound_state *nfsd4_cstate_alloc(struct 
>svc_rqst *rqstp);
>+extern void nfsd4_cstate_free(struct nfsd4_compound_state *cstate,
>+		struct svc_deferred_req *dreq);
> extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
> 		struct nfsd4_compound_state *,
> 		struct nfsd4_setclientid *setclid);
>-- 
>1.5.4.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

