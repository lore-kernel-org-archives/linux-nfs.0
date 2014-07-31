Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49196 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868AbaGaUE2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2014 16:04:28 -0400
Date: Thu, 31 Jul 2014 16:04:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v3 20/38] nfsd: Migrate the stateid reference into
 nfs4_find_stateid_by_type()
Message-ID: <20140731200421.GA21300@fieldses.org>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
 <1406684083-19736-21-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406684083-19736-21-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These look OK to me at least through this patch.

--b.

On Tue, Jul 29, 2014 at 09:34:25PM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Allow nfs4_find_stateid_by_type to take the stateid reference, while
> still holding the &cl->cl_lock. Necessary step toward client_mutex
> removal.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a4a49a3b464c..653de6b14665 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1696,8 +1696,12 @@ find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
>  
>  	spin_lock(&cl->cl_lock);
>  	s = find_stateid_locked(cl, t);
> -	if (s != NULL && !(typemask & s->sc_type))
> -		s = NULL;
> +	if (s != NULL) {
> +		if (typemask & s->sc_type)
> +			atomic_inc(&s->sc_count);
> +		else
> +			s = NULL;
> +	}
>  	spin_unlock(&cl->cl_lock);
>  	return s;
>  }
> @@ -3326,8 +3330,6 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
>  	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
>  	if (!ret)
>  		return NULL;
> -	/* FIXME: move into find_stateid_by_type */
> -	atomic_inc(&ret->sc_count);
>  	return delegstateid(ret);
>  }
>  
> @@ -4170,8 +4172,6 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
>  	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
>  	if (!*s)
>  		return nfserr_bad_stateid;
> -	/* FIXME: move into find_stateid_by_type */
> -	atomic_inc(&(*s)->sc_count);
>  	return nfs_ok;
>  }
>  
> -- 
> 1.9.3
> 
