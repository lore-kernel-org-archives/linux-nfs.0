From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfsd4: fix unlikely race in session replay case
Date: Mon, 03 May 2010 15:28:38 +0300
Message-ID: <4BDEC176.9000002@panasas.com>
References: <20100428213151.GB23474@fieldses.org> <4BDEB16C.2070003@panasas.com> <20100503122208.GC26898@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50024 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758185Ab0ECM2n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 08:28:43 -0400
Received: by bwz19 with SMTP id 19so1254654bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 05:28:41 -0700 (PDT)
In-Reply-To: <20100503122208.GC26898@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 03, 2010, 15:22 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, May 03, 2010 at 02:20:12PM +0300, Benny Halevy wrote:
>> On Apr. 29, 2010, 0:31 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> @@ -1131,6 +1132,8 @@ encode_op:
>>>  	fh_put(&resp->cstate.save_fh);
>>>  	BUG_ON(resp->cstate.replay_owner);
>>>  out:
>>> +	if (resp->cstate.session)
>>> +		nfsd4_put_session(resp->cstate.session);
>> Bruce, I see what you wanted to do but unfortunately putting the session
>> here won't work since resp->cstate.slot is referred to later on in
>> nfs4svc_encode_compoundres and it points into the slot table
>> which is a member of the same session, therefore the current place
>> in which it gets dereferenced should be maintained.
> 
> Whoops, good catch!  (Since most of the xdr encoding is done before
> nfsd4_proc_compound() exits, I think I must have forgotten that
> nfs4svc_encode_compoundres() is an exception?)
> 
>> Please see below for another suggestion
> 
> Done as you suggest.  I'd applied the patch locally but not pushed it
> out yet, so I've updated it in place; the result is the following.  I'll
> apply and push that to for-2.6.35 if you don't see any further probleme.
> 
> --b.
> 
> commit 44643622678d011642531915442d404ad14eb6c6
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Sat Apr 24 15:35:43 2010 -0400
> 
>     nfsd4: fix unlikely race in session replay case
>     
>     In the replay case, the
>     
>     	renew_client(session->se_client);
>     
>     happens after we've droppped the sessionid_lock, and without holding a
>     reference on the session; so there's nothing preventing the session
>     being freed before we get here.
>     
>     Thanks to Benny Halevy for catching a bug in an earlier version of this
>     patch.
>     
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

Acked-by: Benny Halevy <bhalevy@panasas.com>

> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index e147dbc..61282f8 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1027,6 +1027,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  	resp->rqstp = rqstp;
>  	resp->cstate.minorversion = args->minorversion;
>  	resp->cstate.replay_owner = NULL;
> +	resp->cstate.session = NULL;
>  	fh_init(&resp->cstate.current_fh, NFS4_FHSIZE);
>  	fh_init(&resp->cstate.save_fh, NFS4_FHSIZE);
>  	/* Use the deferral mechanism only for NFSv4.0 compounds */
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index bba9fff..737315c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1443,11 +1443,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	cstate->slot = slot;
>  	cstate->session = session;
>  
> -	/* Hold a session reference until done processing the compound:
> -	 * nfsd4_put_session called only if the cstate slot is set.
> -	 */
> -	nfsd4_get_session(session);
>  out:
> +	/* Hold a session reference until done processing the compound. */
> +	if (cstate->session)
> +		nfsd4_get_session(cstate->session);
>  	spin_unlock(&sessionid_lock);
>  	/* Renew the clientid on success and on replay */
>  	if (cstate->session) {
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index fb27b1d..05bc5bd 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3306,10 +3306,12 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>  		iov = &rqstp->rq_res.head[0];
>  	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
>  	BUG_ON(iov->iov_len > PAGE_SIZE);
> -	if (nfsd4_has_session(cs) && cs->status != nfserr_replay_cache) {
> -		nfsd4_store_cache_entry(resp);
> -		dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
> -		resp->cstate.slot->sl_inuse = false;
> +	if (nfsd4_has_session(cs)) {
> +		if (cs->status != nfserr_replay_cache) {
> +			nfsd4_store_cache_entry(resp);
> +			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
> +			resp->cstate.slot->sl_inuse = false;
> +		}
>  		nfsd4_put_session(resp->cstate.session);
>  	}
>  	return 1;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

