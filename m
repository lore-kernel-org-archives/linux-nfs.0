From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 001/100] nfsd4: probe callback channel only once
Date: Mon, 28 Jan 2008 12:35:48 -0500
Message-ID: <68314FDD-D9D1-4DAA-9BC1-423612F05907@oracle.com>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:23330 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbYA1SFR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 13:05:17 -0500
In-Reply-To: <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 25, 2008, at 6:15 PM, J. Bruce Fields wrote:
> Our callback code doesn't actually handle concurrent attempts to probe
> the callback channel.  Some rethinking of the locking may be required.
> However, we can also just move the callback probing to this case.   
> Since
> this is the only time a client is "confirmed" (and since that can only
> happen once in the lifetime of a client), this ensures we only probe
> once.

Applying 001/100 without applying 002/100 will probably break  
bisectability.  Should you consider combining these two?

> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4callback.c |    3 +--
>  fs/nfsd/nfs4state.c    |    3 +--
>  2 files changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 9d536a8..a9735a6 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -395,8 +395,7 @@ nfsd4_probe_callback(struct nfs4_client *clp)
>  	};
>  	struct task_struct *t;
>
> -	if (atomic_read(&cb->cb_set))
> -		return;
> +	BUG_ON(atomic_read(&clp->cl_callback.cb_set));
>
>  	/* Initialize address */
>  	memset(&addr, 0, sizeof(addr));
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 31673cd..9d81c71 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -948,6 +948,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  			}
>  			move_to_confirmed(unconf);
>  			conf = unconf;
> +			nfsd4_probe_callback(conf);
>  			status = nfs_ok;
>  		}
>  	} else if ((!conf || (conf && !same_verf(&conf->cl_confirm,  
> &confirm)))
> @@ -965,8 +966,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  		status = nfserr_clid_inuse;
>  	}
>  out:
> -	if (!status)
> -		nfsd4_probe_callback(conf);
>  	nfs4_unlock_state();
>  	return status;
>  }
> -- 
> 1.5.4.rc2.60.gb2e62
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux- 
> nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



