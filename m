Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51325 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844AbaC2Tdb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Mar 2014 15:33:31 -0400
Date: Sat, 29 Mar 2014 15:33:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Idan Kedar <idank@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: Don't return NFS4ERR_STALE_STATEID for NFSv4.1+
Message-ID: <20140329193331.GD11085@fieldses.org>
References: <1396118619-12771-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1396118619-12771-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 29, 2014 at 02:43:38PM -0400, Trond Myklebust wrote:
> RFC5661 obsoletes NFS4ERR_STALE_STATEID in favour of NFS4ERR_BAD_STATEID.
> 
> Note that because nfsd encodes the clientid boot time in the stateid, we
> can hit this error case in certain scenarios where the Linux client
> state management thread exits early, before it has finished recovering
> all state.

Thanks, applying.

--b.

> 
> Reported-by: Idan Kedar <idank@primarydata.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index d5d070fbeb35..dd32f3746e4d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3627,8 +3627,11 @@ static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
>  		return nfserr_bad_stateid;
>  	status = lookup_clientid(&stateid->si_opaque.so_clid, sessions,
>  							nn, &cl);
> -	if (status == nfserr_stale_clientid)
> +	if (status == nfserr_stale_clientid) {
> +		if (sessions)
> +			return nfserr_bad_stateid;
>  		return nfserr_stale_stateid;
> +	}
>  	if (status)
>  		return status;
>  	*s = find_stateid_by_type(cl, stateid, typemask);
> -- 
> 1.9.0
> 
