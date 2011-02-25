Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754602Ab1BYAhd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Feb 2011 19:37:33 -0500
Date: Thu, 24 Feb 2011 16:36:29 -0800
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: fix decode_cb_sequence4resok
Message-ID: <20110225003629.GA31943@pad.home.fieldses.org>
References: <1298414602-17029-1-git-send-email-bhalevy@panasas.com>
 <EEB9D74B-D547-4C43-AC8B-B8B58EBD9A54@oracle.com>
 <4D653F12.8090101@panasas.com>
 <20110223172957.GA6238@pad.home.fieldses.org>
 <4D654CD7.3020000@panasas.com>
 <4D655541.4020200@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D655541.4020200@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 23, 2011 at 10:43:13AM -0800, Benny Halevy wrote:
> On 2011-02-23 10:07, Benny Halevy wrote:
> >    SEQ4_STATUS_BACKCHANNEL_FAULT
> >       The server has encountered an unrecoverable fault with the
> >       backchannel (e.g., it has lost track of the sequence ID for a slot
> >       in the backchannel).  The client MUST stop sending more requests
> >       on the session's fore channel, wait for all outstanding requests
> >       to complete on the fore and back channel, and then destroy the
> >       session.
> > 
> > Right?

Yep, thanks.  Looking at my todo list on the wiki, I see I mistakenly
had two entries for the backchannel error handling.... I've fixed that
and added a mention of this case:

	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#Callback_failure_handling

> How about this patch?

Thanks for diving into this!

I suspect the FAULT state should be per-session, not
per-client--otherwise a client that has more than one session may be
forced to throw away some other perfectly good session.

Makes sense to me to set this on any callback decode error, as that's a
pretty sure sign that the backchannel is hopeless.

It's probably the right behavior on failure to decode a later op in the
compound as well, and we don't want to add this check to every op
decoder--perhaps a check in e.g. nfsd4_cb_done() could catch any error
that results from callback decoding.

--b.

> 
> From c5b856eaab1e17f3d67b6fd0964d0803318ec342 Mon Sep 17 00:00:00 2001
> From: Benny Halevy <bhalevy@panasas.com>
> Date: Wed, 23 Feb 2011 10:38:19 -0800
> Subject: [PATCH] nfsd41: use SEQ4_STATUS_BACKCHANNEL_FAULT when cb_sequence is invalid
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c |   10 ++++++++++
>  fs/nfsd/nfs4state.c    |    8 +++++++-
>  fs/nfsd/state.h        |    1 +
>  3 files changed, 18 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index d046bdb..b914fb1 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -39,6 +39,8 @@
>  
>  #define NFSDDBG_FACILITY                NFSDDBG_PROC
>  
> +static void nfsd4_mark_cb_fault(struct nfs4_client *, int reason);
> +
>  #define NFSPROC4_CB_NULL 0
>  #define NFSPROC4_CB_COMPOUND 1
>  
> @@ -620,6 +622,8 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
>  	 */
>  	status = 0;
>  out:
> +	if (status)
> +		nfsd4_mark_cb_fault(cb->cb_clp, status);
>  	return status;
>  out_overflow:
>  	print_overflow_msg(__func__, xdr);
> @@ -935,6 +939,12 @@ static void nfsd4_mark_cb_down(struct nfs4_client *clp, int reason)
>  	warn_no_callback_path(clp, reason);
>  }
>  
> +static void nfsd4_mark_cb_fault(struct nfs4_client *clp, int reason)
> +{
> +	clp->cl_cb_state = NFSD4_CB_FAULT;
> +	warn_no_callback_path(clp, reason);
> +}
> +
>  static void nfsd4_cb_probe_done(struct rpc_task *task, void *calldata)
>  {
>  	struct nfs4_client *clp = container_of(calldata, struct nfs4_client, cl_cb_null);
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e8df39f..2188c16 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1856,8 +1856,14 @@ out:
>  
>  		nfsd4_get_session(cstate->session);
>  		atomic_inc(&clp->cl_refcount);
> -		if (clp->cl_cb_state == NFSD4_CB_DOWN)
> +		switch (clp->cl_cb_state) {
> +		case NFSD4_CB_DOWN:
>  			seq->status_flags |= SEQ4_STATUS_CB_PATH_DOWN;
> +			break;
> +		case NFSD4_CB_FAULT:
> +			seq->status_flags |= SEQ4_STATUS_BACKCHANNEL_FAULT;
> +			break;
> +		}
>  	}
>  	kfree(conn);
>  	spin_unlock(&client_lock);
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index c934e1c..95ddf7a 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -235,6 +235,7 @@ struct nfs4_client {
>  #define NFSD4_CB_UP		0
>  #define NFSD4_CB_UNKNOWN	1
>  #define NFSD4_CB_DOWN		2
> +#define NFSD4_CB_FAULT		3
>  	int			cl_cb_state;
>  	struct nfsd4_callback	cl_cb_null;
>  	struct nfsd4_session	*cl_cb_session;
> -- 
> 1.7.3.4
> 
