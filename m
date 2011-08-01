Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50884 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397Ab1HAW56 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2011 18:57:58 -0400
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <1312238117.23392.19.camel@lade.trondhjem.org>
Date: Mon, 1 Aug 2011 18:57:56 -0400
Cc: Peng Tao <bergwolf@gmail.com>, Jim Rees <rees@umich.edu>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Message-Id: <0A94625F-4E4F-4A88-A0DF-63D429924F66@netapp.com>
References: <1311874276-1386-1-git-send-email-rees@umich.edu> <20110729155136.GB28306@infradead.org> <20110729185415.GA23061@merit.edu> <20110729190133.GA10946@infradead.org> <20110729191341.GC23061@merit.edu> <1311988172.16078.15.camel@lade.trondhjem.org> <20110730032621.GB25188@merit.edu> <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com> <1312233006.23392.17.camel@lade.trondhjem.org> <1312238117.23392.19.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 1, 2011, at 6:35 PM, Trond Myklebust wrote:

> On Mon, 2011-08-01 at 17:10 -0400, Trond Myklebust wrote: 
>> Looking at the callback code, I see that if tbl->highest_used_slotid !=
>> 0, then we BUG() while holding the backchannel's tbl->slot_tbl_lock
>> spinlock. That seems a likely candidate for the above hang.
>> 
>> Andy, how we are guaranteed that tbl->highest_used_slotid won't take
>> values other than 0, and why do we commit suicide when it does? As far
>> as I can see, there is no guarantee that we call nfs4_cb_take_slot() in
>> nfs4_callback_compound(), however we appear to unconditionally call
>> nfs4_cb_free_slot() provided there is a session.
>> 
>> The other strangeness would be the fact that there is nothing enforcing
>> the NFS4_SESSION_DRAINING flag. If the session is draining, then the
>> back-channel simply ignores that and goes ahead with processing the
>> callback. Is this to avoid deadlocks with the server returning
>> NFS4ERR_BACK_CHAN_BUSY when the client does a DESTROY_SESSION?


When NFS4_SESSION_DRAINING is set, the backchannel is drained first - and waits for current processing to complete signaled by the highest_used_slotid == -1. Any other backchannel requests that occur under the NFS4_SESSION_DRAINING flag are processed - but just the CB_SEQUENCE operation which returns NFS4ERR_DELAY.  It does indeed prevent the BACK_CHAN_BUSY deadlock.

> 
> How about something like the following?

Looks good. Nice catch. One change below and a comment inline

-->Andy

> 
> 8<------------------------------------------------------------------------------- 
> From c0c499b0ca9d0af8cbdc29c40effba38475461d9 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Mon, 1 Aug 2011 18:31:12 -0400
> Subject: [PATCH] NFSv4.1: Fix the callback 'highest_used_slotid' behaviour
> 
> Currently, there is no guarantee that we will call nfs4_cb_take_slot() even
> though nfs4_callback_compound() will consistently call
> nfs4_cb_free_slot() provided the cb_process_state has set the 'clp' field.
> The result is that we can trigger the BUG_ON() upon the next call to
> nfs4_cb_take_slot().
> This patch fixes the above problem by using the slot id that was taken in
> the CB_SEQUENCE operation as a flag for whether or not we need to call
> nfs4_cb_free_slot().
> It also fixes an atomicity problem: we need to set tbl->highest_used_slotid
> atomically with the check for NFS4_SESSION_DRAINING, otherwise we end up
> racing with the various tests in nfs4_begin_drain_session().

But the code below doesn't do this - it locks the backchannel slot table to check the flag, but does not set the highest_used_slot atomically with this check.

> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/callback.h      |    2 +-
> fs/nfs/callback_proc.c |   18 +++++++++++++-----
> fs/nfs/callback_xdr.c  |   24 +++++++-----------------
> 3 files changed, 21 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index b257383..07df5f1 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -38,6 +38,7 @@ enum nfs4_callback_opnum {
> struct cb_process_state {
> 	__be32			drc_status;
> 	struct nfs_client	*clp;
> +	int			slotid;
> };
> 
> struct cb_compound_hdr_arg {
> @@ -166,7 +167,6 @@ extern unsigned nfs4_callback_layoutrecall(
> 	void *dummy, struct cb_process_state *cps);
> 
> extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
> -extern void nfs4_cb_take_slot(struct nfs_client *clp);
> 
> struct cb_devicenotifyitem {
> 	uint32_t		cbd_notify_type;
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 74780f9..1bd2c81 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -348,7 +348,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
> 	/* Normal */
> 	if (likely(args->csa_sequenceid == slot->seq_nr + 1)) {
> 		slot->seq_nr++;
> -		return htonl(NFS4_OK);
> +		goto out_ok;
> 	}
> 
> 	/* Replay */
> @@ -367,11 +367,14 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
> 	/* Wraparound */
> 	if (args->csa_sequenceid == 1 && (slot->seq_nr + 1) == 0) {
> 		slot->seq_nr = 1;
> -		return htonl(NFS4_OK);
> +		goto out_ok;
> 	}
> 
> 	/* Misordered request */
> 	return htonl(NFS4ERR_SEQ_MISORDERED);
> +out_ok:
> +	tbl->highest_used_slotid = args->csa_slotid;
> +	return htonl(NFS4_OK);
> }
> 
> /*
> @@ -433,26 +436,32 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
> 			      struct cb_sequenceres *res,
> 			      struct cb_process_state *cps)
> {
> +	struct nfs4_slot_table *tbl;
> 	struct nfs_client *clp;
> 	int i;
> 	__be32 status = htonl(NFS4ERR_BADSESSION);
> 
> -	cps->clp = NULL;
> -
> 	clp = nfs4_find_client_sessionid(args->csa_addr, &args->csa_sessionid);
> 	if (clp == NULL)
> 		goto out;
> 
> +	tbl = &clp->cl_session->bc_slot_table;
> +
> +	spin_lock(&tbl->slot_tbl_lock);
> 	/* state manager is resetting the session */
> 	if (test_bit(NFS4_SESSION_DRAINING, &clp->cl_session->session_state)) {
> 		status = NFS4ERR_DELAY;
                                 
status = htonl(NFS4ERR_DELAY);


> +		spin_unlock(&tbl->slot_tbl_lock);
> 		goto out;
> 	}
> 
> 	status = validate_seqid(&clp->cl_session->bc_slot_table, args);
> +	spin_unlock(&tbl->slot_tbl_lock);
> 	if (status)
> 		goto out;
> 
> +	cps->slotid = args->csa_slotid;
> +
> 	/*
> 	 * Check for pending referring calls.  If a match is found, a
> 	 * related callback was received before the response to the original
> @@ -469,7 +478,6 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
> 	res->csr_slotid = args->csa_slotid;
> 	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
> 	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
> -	nfs4_cb_take_slot(clp);
> 
> out:
> 	cps->clp = clp; /* put in nfs4_callback_compound */
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index c6c86a7..918ad64 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -754,26 +754,15 @@ static void nfs4_callback_free_slot(struct nfs4_session *session)
> 	 * Let the state manager know callback processing done.
> 	 * A single slot, so highest used slotid is either 0 or -1
> 	 */
> -	tbl->highest_used_slotid--;
> +	tbl->highest_used_slotid = -1;
> 	nfs4_check_drain_bc_complete(session);
> 	spin_unlock(&tbl->slot_tbl_lock);
> }
> 
> -static void nfs4_cb_free_slot(struct nfs_client *clp)
> +static void nfs4_cb_free_slot(struct cb_process_state *cps)
> {
> -	if (clp && clp->cl_session)
> -		nfs4_callback_free_slot(clp->cl_session);
> -}
> -
> -/* A single slot, so highest used slotid is either 0 or -1 */
> -void nfs4_cb_take_slot(struct nfs_client *clp)
> -{
> -	struct nfs4_slot_table *tbl = &clp->cl_session->bc_slot_table;
> -
> -	spin_lock(&tbl->slot_tbl_lock);
> -	tbl->highest_used_slotid++;
> -	BUG_ON(tbl->highest_used_slotid != 0);
> -	spin_unlock(&tbl->slot_tbl_lock);
> +	if (cps->slotid != -1)
> +		nfs4_callback_free_slot(cps->clp->cl_session);
> }
> 
> #else /* CONFIG_NFS_V4_1 */
> @@ -784,7 +773,7 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
> 	return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
> }
> 
> -static void nfs4_cb_free_slot(struct nfs_client *clp)
> +static void nfs4_cb_free_slot(struct cb_process_state *cps)
> {
> }
> #endif /* CONFIG_NFS_V4_1 */
> @@ -866,6 +855,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
> 	struct cb_process_state cps = {
> 		.drc_status = 0,
> 		.clp = NULL,
> +		.slotid = -1,
> 	};
> 	unsigned int nops = 0;
> 
> @@ -906,7 +896,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
> 
> 	*hdr_res.status = status;
> 	*hdr_res.nops = htonl(nops);
> -	nfs4_cb_free_slot(cps.clp);
> +	nfs4_cb_free_slot(&cps);
> 	nfs_put_client(cps.clp);
> 	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
> 	return rpc_success;
> -- 
> 1.7.6
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

