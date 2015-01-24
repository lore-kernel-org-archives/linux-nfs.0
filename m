Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:50933 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbAXLqb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 06:46:31 -0500
Received: by mail-qc0-f174.google.com with SMTP id s11so1434473qcv.5
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 03:46:30 -0800 (PST)
Date: Sat, 24 Jan 2015 06:46:28 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/5] NFSv4: Fix an atomicity problem in CLOSE
Message-ID: <20150124064628.0bc0b289@tlielax.poochiereds.net>
In-Reply-To: <1422077968-116473-2-git-send-email-trond.myklebust@primarydata.com>
References: <1422077968-116473-1-git-send-email-trond.myklebust@primarydata.com>
	<1422077968-116473-2-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 24 Jan 2015 00:39:24 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> If we are to remove the serialisation of OPEN/CLOSE, then we need to
> ensure that the stateid sent as part of a CLOSE operation does not
> change after we test the state in nfs4_close_prepare.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c       | 7 ++++++-
>  fs/nfs/nfs4xdr.c        | 4 ++--
>  include/linux/nfs_xdr.h | 2 +-
>  3 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c347705b0161..4863dec10865 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2587,6 +2587,11 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
>  		case -NFS4ERR_OLD_STATEID:
>  		case -NFS4ERR_BAD_STATEID:
>  		case -NFS4ERR_EXPIRED:
> +			if (!nfs4_stateid_match(&calldata->arg.stateid,
> +						&state->stateid)) {
> +				rpc_restart_call_prepare(task);
> +				goto out_release;
> +			}

Do we need a similar check in the open codepath -- possibly in
nfs4_open_done? AFAICT, currently if the OPEN ends up "losing" the race
here, then we'll fall into full-on stateid recovery, which is almost
certainly not what we want.

>  			if (calldata->arg.fmode == 0)
>  				break;
>  		default:
> @@ -2619,6 +2624,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
>  	is_rdwr = test_bit(NFS_O_RDWR_STATE, &state->flags);
>  	is_rdonly = test_bit(NFS_O_RDONLY_STATE, &state->flags);
>  	is_wronly = test_bit(NFS_O_WRONLY_STATE, &state->flags);
> +	nfs4_stateid_copy(&calldata->arg.stateid, &state->stateid);
>  	/* Calculate the change in open mode */
>  	calldata->arg.fmode = 0;
>  	if (state->n_rdwr == 0) {
> @@ -2757,7 +2763,6 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
>  	calldata->inode = state->inode;
>  	calldata->state = state;
>  	calldata->arg.fh = NFS_FH(state->inode);
> -	calldata->arg.stateid = &state->open_stateid;
>  	/* Serialization for the sequence id */
>  	calldata->arg.seqid = nfs_alloc_seqid(&state->owner->so_seqid, gfp_mask);
>  	if (calldata->arg.seqid == NULL)
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index cb4376b78ed9..7e7be5ab70bb 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1125,7 +1125,7 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
>  {
>  	encode_op_hdr(xdr, OP_CLOSE, decode_close_maxsz, hdr);
>  	encode_nfs4_seqid(xdr, arg->seqid);
> -	encode_nfs4_stateid(xdr, arg->stateid);
> +	encode_nfs4_stateid(xdr, &arg->stateid);
>  }
>  
>  static void encode_commit(struct xdr_stream *xdr, const struct nfs_commitargs *args, struct compound_hdr *hdr)
> @@ -1530,7 +1530,7 @@ static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_co
>  static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
>  {
>  	encode_op_hdr(xdr, OP_OPEN_DOWNGRADE, decode_open_downgrade_maxsz, hdr);
> -	encode_nfs4_stateid(xdr, arg->stateid);
> +	encode_nfs4_stateid(xdr, &arg->stateid);
>  	encode_nfs4_seqid(xdr, arg->seqid);
>  	encode_share_access(xdr, arg->fmode);
>  }
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 467c84efb596..7e38d641236e 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -389,7 +389,7 @@ struct nfs_open_confirmres {
>  struct nfs_closeargs {
>  	struct nfs4_sequence_args	seq_args;
>  	struct nfs_fh *         fh;
> -	nfs4_stateid *		stateid;
> +	nfs4_stateid 		stateid;
>  	struct nfs_seqid *	seqid;
>  	fmode_t			fmode;
>  	const u32 *		bitmask;


-- 
Jeff Layton <jeff.layton@primarydata.com>
