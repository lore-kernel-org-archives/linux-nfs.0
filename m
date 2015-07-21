Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38688 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754804AbbGUVQk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2015 17:16:40 -0400
Date: Tue, 21 Jul 2015 17:16:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] nfsd: Add layouts checking in client_has_state()
Message-ID: <20150721211639.GB22718@fieldses.org>
References: <20150721095737.7411eb05@canb.auug.org.au>
 <55ADD3FD.405@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55ADD3FD.405@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 21, 2015 at 01:09:17PM +0800, Kinglong Mee wrote:
> Layout is a state resource, nfsd should check it too.
> 
> v2, drop unneeded updating in nfsd4_renew()
> v3, fix compile error without CONFIG_NFSD_PNFS

Got it, thanks.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 61dfb33..94a2980 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2241,6 +2241,9 @@ static bool client_has_state(struct nfs4_client *clp)
>  	 * Also note we should probably be using this in 4.0 case too.
>  	 */
>  	return !list_empty(&clp->cl_openowners)
> +#ifdef CONFIG_NFSD_PNFS
> +		|| !list_empty(&clp->cl_lo_states)
> +#endif
>  		|| !list_empty(&clp->cl_delegations)
>  		|| !list_empty(&clp->cl_sessions);
>  }
> -- 
> 2.4.3
