Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:36003 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbcHGWWk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Aug 2016 18:22:40 -0400
Received: by mail-qk0-f175.google.com with SMTP id v123so174676085qkh.3
        for <linux-nfs@vger.kernel.org>; Sun, 07 Aug 2016 15:22:40 -0700 (PDT)
Message-ID: <1470608556.2975.8.camel@redhat.com>
Subject: Re: [PATCH v2] nfsd: Fix race between FREE_STATEID and LOCK
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date: Sun, 07 Aug 2016 18:22:36 -0400
In-Reply-To: <20160807185024.11705.10864.stgit@klimt.1015granger.net>
References: <20160807185024.11705.10864.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2016-08-07 at 14:53 -0400, Chuck Lever wrote:
> When running LTP's nfslock01 test, the Linux client can send a LOCK
> and a FREE_STATEID request at the same time. The LOCK uses the same
> lockowner as the stateid sent in the FREE_STATEID request.
> 
> The outcome is:
> 
> Frame 115025 C FREE_STATEID stateid 2/A
> Frame 115026 C LOCK offset 672128 len 64
> Frame 115029 R FREE_STATEID NFS4_OK
> Frame 115030 R LOCK stateid 3/A
> Frame 115034 C WRITE stateid 0/A offset 672128 len 64
> Frame 115038 R WRITE NFS4ERR_BAD_STATEID
> 
> In other words, the server returns stateid A in a successful LOCK
> reply, but it has already released it. Subsequent uses of the
> stateid fail.
> 
> To address this, protect the generation check in nfsd4_free_stateid
> with the st_mutex. This should guarantee that only one of two
> outcomes occurs: either LOCK returns a fresh valid stateid, or
> FREE_STATEID returns NFS4ERR_LOCKS_HELD.
> 
> Reported-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> Fix-suggested-by: Jeff Layton <jlayton@redhat.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs4state.c |   19 ++++++++++++-------
>  1 file changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b921123..07dc1aa 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4911,19 +4911,20 @@ nfsd4_free_stateid(struct svc_rqst *rqstp,
> struct nfsd4_compound_state *cstate,
>  		ret = nfserr_locks_held;
>  		break;
>  	case NFS4_LOCK_STID:
> +		atomic_inc(&s->sc_count);
> +		spin_unlock(&cl->cl_lock);
> +		stp = openlockstateid(s);
> +		mutex_lock(&stp->st_mutex);
>  		ret = check_stateid_generation(stateid, &s-
> >sc_stateid, 1);
>  		if (ret)
> -			break;
> -		stp = openlockstateid(s);
> +			goto out_mutex_unlock;
>  		ret = nfserr_locks_held;
>  		if (check_for_locks(stp->st_stid.sc_file,
>  				    lockowner(stp->st_stateowner)))
> -			break;
> -		WARN_ON(!unhash_lock_stateid(stp));
> -		spin_unlock(&cl->cl_lock);
> -		nfs4_put_stid(s);
> +			goto out_mutex_unlock;
> +		release_lock_stateid(stp);
>  		ret = nfs_ok;
> -		goto out;
> +		goto out_mutex_unlock;
>  	case NFS4_REVOKED_DELEG_STID:
>  		dp = delegstateid(s);
>  		list_del_init(&dp->dl_recall_lru);
> @@ -4937,6 +4938,10 @@ out_unlock:
>  	spin_unlock(&cl->cl_lock);
>  out:
>  	return ret;
> +out_mutex_unlock:
> +	mutex_unlock(&stp->st_mutex);
> +	nfs4_put_stid(s);
> +	goto out;
>  }
>  
>  static inline int
> 
> 

Looks good to me.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
