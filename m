Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:40918 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbaHSUOK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 16:14:10 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so6824906qcz.0
        for <linux-nfs@vger.kernel.org>; Tue, 19 Aug 2014 13:14:05 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 19 Aug 2014 16:14:04 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 5/6 v4] NFSD: New helper nfs4_get_stateowner() for
 atomic_inc sop reference
Message-ID: <20140819161404.27621456@tlielax.poochiereds.net>
In-Reply-To: <53F36C6C.3050600@gmail.com>
References: <53BAAAC5.9000106@gmail.com>
	<53E22EA5.70708@gmail.com>
	<20140809065112.700e0ecc@tlielax.poochiereds.net>
	<53E791F1.40802@gmail.com>
	<53ED5093.6000308@gmail.com>
	<53F36C6C.3050600@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 19 Aug 2014 23:25:32 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> v4: same as v3
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 32 ++++++++++++++++----------------
>  1 file changed, 16 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 98edf97..e087a71 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -216,6 +216,13 @@ static void nfsd4_put_session(struct nfsd4_session *ses)
>  	spin_unlock(&nn->client_lock);
>  }
>  
> +static inline struct nfs4_stateowner *
> +nfs4_get_stateowner(struct nfs4_stateowner *sop)
> +{
> +	atomic_inc(&sop->so_count);
> +	return sop;
> +}
> +
>  static int
>  same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner)
>  {
> @@ -235,10 +242,8 @@ find_openstateowner_str_locked(unsigned int hashval, struct nfsd4_open *open,
>  			    so_strhash) {
>  		if (!so->so_is_open_owner)
>  			continue;
> -		if (same_owner_str(so, &open->op_owner)) {
> -			atomic_inc(&so->so_count);
> -			return openowner(so);
> -		}
> +		if (same_owner_str(so, &open->op_owner))
> +			return openowner(nfs4_get_stateowner(so));
>  	}
>  	return NULL;
>  }
> @@ -1644,7 +1649,7 @@ __destroy_client(struct nfs4_client *clp)
>  	}
>  	while (!list_empty(&clp->cl_openowners)) {
>  		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
> -		atomic_inc(&oo->oo_owner.so_count);
> +		nfs4_get_stateowner(&oo->oo_owner);
>  		release_openowner(oo);
>  	}
>  	nfsd4_shutdown_callback(clp);
> @@ -3125,8 +3130,7 @@ static void nfsd4_cstate_assign_replay(struct nfsd4_compound_state *cstate,
>  {
>  	if (!nfsd4_has_session(cstate)) {
>  		mutex_lock(&so->so_replay.rp_mutex);
> -		cstate->replay_owner = so;
> -		atomic_inc(&so->so_count);
> +		cstate->replay_owner = nfs4_get_stateowner(so);
>  	}
>  }
>  
> @@ -3225,8 +3229,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
>  	atomic_inc(&stp->st_stid.sc_count);
>  	stp->st_stid.sc_type = NFS4_OPEN_STID;
>  	INIT_LIST_HEAD(&stp->st_locks);
> -	stp->st_stateowner = &oo->oo_owner;
> -	atomic_inc(&stp->st_stateowner->so_count);
> +	stp->st_stateowner = nfs4_get_stateowner(&oo->oo_owner);
>  	get_nfs4_file(fp);
>  	stp->st_stid.sc_file = fp;
>  	stp->st_access_bmap = 0;
> @@ -4914,10 +4917,8 @@ find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
>  			    so_strhash) {
>  		if (so->so_is_open_owner)
>  			continue;
> -		if (!same_owner_str(so, owner))
> -			continue;
> -		atomic_inc(&so->so_count);
> -		return lockowner(so);
> +		if (same_owner_str(so, owner))
> +			return lockowner(nfs4_get_stateowner(so));
>  	}
>  	return NULL;
>  }
> @@ -4996,8 +4997,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
>  
>  	atomic_inc(&stp->st_stid.sc_count);
>  	stp->st_stid.sc_type = NFS4_LOCK_STID;
> -	stp->st_stateowner = &lo->lo_owner;
> -	atomic_inc(&lo->lo_owner.so_count);
> +	stp->st_stateowner = nfs4_get_stateowner(&lo->lo_owner);
>  	get_nfs4_file(fp);
>  	stp->st_stid.sc_file = fp;
>  	stp->st_stid.sc_free = nfs4_free_lock_stateid;
> @@ -5539,7 +5539,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  			}
>  		}
>  
> -		atomic_inc(&sop->so_count);
> +		nfs4_get_stateowner(sop);
>  		break;
>  	}
>  	spin_unlock(&clp->cl_lock);

Reviewed-by: Jeff Layton <jlayton@primarydata.com>
