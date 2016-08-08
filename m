Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38023 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbcHHGsr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2016 02:48:47 -0400
Date: Sun, 7 Aug 2016 23:48:46 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: Fix race between FREE_STATEID and LOCK
Message-ID: <20160808064846.GA2079@infradead.org>
References: <20160807185024.11705.10864.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160807185024.11705.10864.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 07, 2016 at 02:53:07PM -0400, Chuck Lever wrote:
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
>  fs/nfsd/nfs4state.c |   19 ++++++++++++-------
>  1 file changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b921123..07dc1aa 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4911,19 +4911,20 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		ret = nfserr_locks_held;
>  		break;
>  	case NFS4_LOCK_STID:
> +		atomic_inc(&s->sc_count);
> +		spin_unlock(&cl->cl_lock);
> +		stp = openlockstateid(s);
> +		mutex_lock(&stp->st_mutex);
>  		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
>  		if (ret)
> -			break;
> -		stp = openlockstateid(s);
> +			goto out_mutex_unlock;
>  		ret = nfserr_locks_held;
>  		if (check_for_locks(stp->st_stid.sc_file,
>  				    lockowner(stp->st_stateowner)))
> -			break;
> -		WARN_ON(!unhash_lock_stateid(stp));
> -		spin_unlock(&cl->cl_lock);
> -		nfs4_put_stid(s);
> +			goto out_mutex_unlock;
> +		release_lock_stateid(stp);
>  		ret = nfs_ok;
> -		goto out;
> +		goto out_mutex_unlock;

It would be nice to split the non-trivial cases (at least
NFS4_LOCK_STID and NFS4_REVOKED_DELEG_STID) into separate helpers
here as a follow on patch..
