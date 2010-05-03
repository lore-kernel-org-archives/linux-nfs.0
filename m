From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfsd4: fix unlikely race in session replay case
Date: Mon, 03 May 2010 14:20:12 +0300
Message-ID: <4BDEB16C.2070003@panasas.com>
References: <20100428213151.GB23474@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:33011 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757824Ab0ECLUU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 07:20:20 -0400
Received: by bwz19 with SMTP id 19so1221456bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 04:20:18 -0700 (PDT)
In-Reply-To: <20100428213151.GB23474@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 29, 2010, 0:31 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> In the replay case, the
> 
> 	renew_client(session->se_client);
> 
> happens after we've droppped the sessionid_lock, and without holding a
> reference on the session; so there's nothing preventing the session
> being freed before we get here.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4proc.c  |    3 +++
>  fs/nfsd/nfs4state.c |    7 +++----
>  fs/nfsd/nfs4xdr.c   |    1 -
>  3 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index e147dbc..e4a4a3e 100644
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
> @@ -1131,6 +1132,8 @@ encode_op:
>  	fh_put(&resp->cstate.save_fh);
>  	BUG_ON(resp->cstate.replay_owner);
>  out:
> +	if (resp->cstate.session)
> +		nfsd4_put_session(resp->cstate.session);

Bruce, I see what you wanted to do but unfortunately putting the session
here won't work since resp->cstate.slot is referred to later on in
nfs4svc_encode_compoundres and it points into the slot table
which is a member of the same session, therefore the current place
in which it gets dereferenced should be maintained.

Please see below for another suggestion

>  	nfsd4_release_compoundargs(args);
>  	/* Reset deferral mechanism for RPC deferrals */
>  	rqstp->rq_usedeferral = 1;
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
> index fb27b1d..903c5a6 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3310,7 +3310,6 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>  		nfsd4_store_cache_entry(resp);
>  		dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
>  		resp->cstate.slot->sl_inuse = false;
> -		nfsd4_put_session(resp->cstate.session);
>  	}
>  	return 1;
>  }


How about this instead:

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 34ccf81..b04583c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3307,10 +3307,12 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		iov = &rqstp->rq_res.head[0];
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
-	if (nfsd4_has_session(cs) && cs->status != nfserr_replay_cache) {
-		nfsd4_store_cache_entry(resp);
-		dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
-		resp->cstate.slot->sl_inuse = false;
+	if (nfsd4_has_session(cs)) {
+		if (cs->status != nfserr_replay_cache) {
+			nfsd4_store_cache_entry(resp);
+			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
+			resp->cstate.slot->sl_inuse = false;
+		}
 		nfsd4_put_session(resp->cstate.session);
 	}
 	return 1;
