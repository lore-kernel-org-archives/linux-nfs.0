Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:54423 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbaGGQqJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2014 12:46:09 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so4041835qcv.24
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 09:46:09 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 7 Jul 2014 12:46:07 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSD: Cleanup for nfsd4_release_lockowner()
Message-ID: <20140707124607.5c28f47a@tlielax.poochiereds.net>
In-Reply-To: <53BAAB1D.6080309@gmail.com>
References: <53BAAB1D.6080309@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 07 Jul 2014 22:13:49 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 21 ++++-----------------
>  1 file changed, 4 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 1b5afc1..abb2d81 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4815,11 +4815,9 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  			struct nfsd4_release_lockowner *rlockowner)
>  {
>  	clientid_t *clid = &rlockowner->rl_clientid;
> -	struct nfs4_stateowner *sop = NULL, *tmp;
> +	struct nfs4_stateowner *sop;
>  	struct nfs4_lockowner *lo;
>  	struct nfs4_ol_stateid *stp;
> -	struct xdr_netobj *owner = &rlockowner->rl_owner;
> -	unsigned int hashval = ownerstr_hashval(clid->cl_id, owner);
>  	__be32 status;
>  	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
>  
> @@ -4833,24 +4831,13 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  		goto out;
>  
>  	status = nfserr_locks_held;
> -
> -	/* Find the matching lock stateowner */
> -	list_for_each_entry(tmp, &nn->ownerstr_hashtbl[hashval], so_strhash) {
> -		if (tmp->so_is_open_owner)
> -			continue;
> -		if (same_owner_str(tmp, owner, clid)) {
> -			sop = tmp;
> -			break;
> -		}
> -	}
> -
> -	/* No matching owner found, maybe a replay? Just declare victory... */
> -	if (!sop) {
> +	lo = find_lockowner_str(clid, &rlockowner->rl_owner, nn);
> +	if (!lo) {
>  		status = nfs_ok;
>  		goto out;
>  	}
>  
> -	lo = lockowner(sop);
> +	sop = &lo->lo_owner;
>  	/* see if there are still any locks associated with it */
>  	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
>  		if (check_for_locks(stp->st_file, lo))

I'd rather we not change this just yet. While I agree with you and
Christoph that this code needs some cleanup, this patch will conflict
with some later changes that I have queued. Can we hold off on this
particular patch for now, and reconsider it after the rest of the
client_mutex removal series has been merged? I don't think it'll be
needed at that point.


Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
