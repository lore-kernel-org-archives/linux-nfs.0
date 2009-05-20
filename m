From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [RFC 06/11] nfsd41: Backchannel: Add sequence arguments to callback
 RPC arguments
Date: Wed, 20 May 2009 10:32:41 +0300
Message-ID: <4A13B219.2020101@panasas.com>
References: <273FE88A07F5D445824060902F70034405CEB64D@SACMVEXC1-PRD.hq.netapp.com> <1242788428-18723-1-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-2-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-3-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-4-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-5-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-6-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:22277 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754246AbZETHeL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2009 03:34:11 -0400
In-Reply-To: <1242788428-18723-6-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 20, 2009, 6:00 +0300, Ricardo Labiaga <Ricardo.Labiaga@netapp.com> wrote:
> Follow the model we use in the client. Make the sequence arguments
> part of the regular RPC arguments.  The results point to them.  Adjust
> references to the sequence arguments.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [define struct nfsd4_cb_sequence here]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c     |    9 +++++++++
>  include/linux/nfsd/state.h |    9 +++++++++
>  2 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index f75750e..0b5c4a6 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -92,6 +92,15 @@ enum nfs_cb_opnum4 {
>  					cb_sequence_dec_sz +            \
>  					op_dec_sz)
>  
> +struct nfs4_rpc_args {
> +	void				*args_op;
> +	struct nfsd4_cb_sequence	args_seq;
> +};
> +
> +struct nfs4_rpc_res {
> +	struct nfsd4_cb_sequence	*res_seq;

Given the size of nfsd4_cb_sequence, why not just embed it here?
(Historically, it didn't have the cbs_minorversion member so
it's presence was the actual indication of the minorversion.
Now that this has changed, I see no good reason not to embed it.

Benny

> +};
> +
>  /*
>  * Generic encode routines from fs/nfs/nfs4xdr.c
>  */
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 212a75b..931aaa6 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -61,6 +61,12 @@ typedef struct {
>  #define si_stateownerid   si_opaque.so_stateownerid
>  #define si_fileid         si_opaque.so_fileid
>  
> +struct nfsd4_cb_sequence {
> +	/* args/res */
> +	u32			cbs_minorversion;
> +	struct nfs4_client	*cbs_clp;
> +};
> +
>  struct nfs4_delegation {
>  	struct list_head	dl_perfile;
>  	struct list_head	dl_perclnt;
> @@ -188,6 +194,9 @@ struct nfs4_client {
>  	struct nfsd4_slot	cl_slot;	/* create_session slot */
>  	u32			cl_exchange_flags;
>  	struct nfs4_sessionid	cl_sessionid;
> +
> +	/* for nfs41 callbacks */
> +	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
>  };
>  
>  /* struct nfs4_client_reset
