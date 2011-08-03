Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:55919 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab1HCIxP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 04:53:15 -0400
Received: by vxh35 with SMTP id 35so453649vxh.19
        for <linux-nfs@vger.kernel.org>; Wed, 03 Aug 2011 01:53:14 -0700 (PDT)
In-Reply-To: <1312311040-9400-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1312306214.2823.10.camel@lade.trondhjem.org> <1312311040-9400-1-git-send-email-Trond.Myklebust@netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 3 Aug 2011 16:52:53 +0800
Message-ID: <CA+a=Yy5g3xkO8cbyG+NL87Y+4phqxHLsf2Pjzp+=4egYeJYJXg@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] NFSv4.1: Fix the callback 'highest_used_slotid' behaviour
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andy Adamson <andros@netapp.com>, Jim Rees <rees@umich.edu>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I applied the two patches and tested more than 10 runs and no hang so far.

Thanks,
Tao

On Wed, Aug 3, 2011 at 2:50 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> Currently, there is no guarantee that we will call nfs4_cb_take_slot() even
> though nfs4_callback_compound() will consistently call
> nfs4_cb_free_slot() provided the cb_process_state has set the 'clp' field.
> The result is that we can trigger the BUG_ON() upon the next call to
> nfs4_cb_take_slot().
>
> This patch fixes the above problem by using the slot id that was taken in
> the CB_SEQUENCE operation as a flag for whether or not we need to call
> nfs4_cb_free_slot().
> It also fixes an atomicity problem: we need to set tbl->highest_used_slotid
> atomically with the check for NFS4_SESSION_DRAINING, otherwise we end up
> racing with the various tests in nfs4_begin_drain_session().
>
> Cc: stable@kernel.org [2.6.38+]
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/callback.h      |    2 +-
>  fs/nfs/callback_proc.c |   20 ++++++++++++++------
>  fs/nfs/callback_xdr.c  |   24 +++++++-----------------
>  3 files changed, 22 insertions(+), 24 deletions(-)
>
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index b257383..07df5f1 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -38,6 +38,7 @@ enum nfs4_callback_opnum {
>  struct cb_process_state {
>        __be32                  drc_status;
>        struct nfs_client       *clp;
> +       int                     slotid;
>  };
>
>  struct cb_compound_hdr_arg {
> @@ -166,7 +167,6 @@ extern unsigned nfs4_callback_layoutrecall(
>        void *dummy, struct cb_process_state *cps);
>
>  extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
> -extern void nfs4_cb_take_slot(struct nfs_client *clp);
>
>  struct cb_devicenotifyitem {
>        uint32_t                cbd_notify_type;
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 74780f9..0ab8202 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -348,7 +348,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
>        /* Normal */
>        if (likely(args->csa_sequenceid == slot->seq_nr + 1)) {
>                slot->seq_nr++;
> -               return htonl(NFS4_OK);
> +               goto out_ok;
>        }
>
>        /* Replay */
> @@ -367,11 +367,14 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
>        /* Wraparound */
>        if (args->csa_sequenceid == 1 && (slot->seq_nr + 1) == 0) {
>                slot->seq_nr = 1;
> -               return htonl(NFS4_OK);
> +               goto out_ok;
>        }
>
>        /* Misordered request */
>        return htonl(NFS4ERR_SEQ_MISORDERED);
> +out_ok:
> +       tbl->highest_used_slotid = args->csa_slotid;
> +       return htonl(NFS4_OK);
>  }
>
>  /*
> @@ -433,26 +436,32 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
>                              struct cb_sequenceres *res,
>                              struct cb_process_state *cps)
>  {
> +       struct nfs4_slot_table *tbl;
>        struct nfs_client *clp;
>        int i;
>        __be32 status = htonl(NFS4ERR_BADSESSION);
>
> -       cps->clp = NULL;
> -
>        clp = nfs4_find_client_sessionid(args->csa_addr, &args->csa_sessionid);
>        if (clp == NULL)
>                goto out;
>
> +       tbl = &clp->cl_session->bc_slot_table;
> +
> +       spin_lock(&tbl->slot_tbl_lock);
>        /* state manager is resetting the session */
>        if (test_bit(NFS4_SESSION_DRAINING, &clp->cl_session->session_state)) {
> -               status = NFS4ERR_DELAY;
> +               spin_unlock(&tbl->slot_tbl_lock);
> +               status = htonl(NFS4ERR_DELAY);
>                goto out;
>        }
>
>        status = validate_seqid(&clp->cl_session->bc_slot_table, args);
> +       spin_unlock(&tbl->slot_tbl_lock);
>        if (status)
>                goto out;
>
> +       cps->slotid = args->csa_slotid;
> +
>        /*
>         * Check for pending referring calls.  If a match is found, a
>         * related callback was received before the response to the original
> @@ -469,7 +478,6 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
>        res->csr_slotid = args->csa_slotid;
>        res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
>        res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
> -       nfs4_cb_take_slot(clp);
>
>  out:
>        cps->clp = clp; /* put in nfs4_callback_compound */
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index c6c86a7..918ad64 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -754,26 +754,15 @@ static void nfs4_callback_free_slot(struct nfs4_session *session)
>         * Let the state manager know callback processing done.
>         * A single slot, so highest used slotid is either 0 or -1
>         */
> -       tbl->highest_used_slotid--;
> +       tbl->highest_used_slotid = -1;
>        nfs4_check_drain_bc_complete(session);
>        spin_unlock(&tbl->slot_tbl_lock);
>  }
>
> -static void nfs4_cb_free_slot(struct nfs_client *clp)
> +static void nfs4_cb_free_slot(struct cb_process_state *cps)
>  {
> -       if (clp && clp->cl_session)
> -               nfs4_callback_free_slot(clp->cl_session);
> -}
> -
> -/* A single slot, so highest used slotid is either 0 or -1 */
> -void nfs4_cb_take_slot(struct nfs_client *clp)
> -{
> -       struct nfs4_slot_table *tbl = &clp->cl_session->bc_slot_table;
> -
> -       spin_lock(&tbl->slot_tbl_lock);
> -       tbl->highest_used_slotid++;
> -       BUG_ON(tbl->highest_used_slotid != 0);
> -       spin_unlock(&tbl->slot_tbl_lock);
> +       if (cps->slotid != -1)
> +               nfs4_callback_free_slot(cps->clp->cl_session);
>  }
>
>  #else /* CONFIG_NFS_V4_1 */
> @@ -784,7 +773,7 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
>        return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
>  }
>
> -static void nfs4_cb_free_slot(struct nfs_client *clp)
> +static void nfs4_cb_free_slot(struct cb_process_state *cps)
>  {
>  }
>  #endif /* CONFIG_NFS_V4_1 */
> @@ -866,6 +855,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
>        struct cb_process_state cps = {
>                .drc_status = 0,
>                .clp = NULL,
> +               .slotid = -1,
>        };
>        unsigned int nops = 0;
>
> @@ -906,7 +896,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
>
>        *hdr_res.status = status;
>        *hdr_res.nops = htonl(nops);
> -       nfs4_cb_free_slot(cps.clp);
> +       nfs4_cb_free_slot(&cps);
>        nfs_put_client(cps.clp);
>        dprintk("%s: done, status = %u\n", __func__, ntohl(status));
>        return rpc_success;
> --
> 1.7.6
>
>
