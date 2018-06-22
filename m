Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43468 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932973AbeFVRyQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Jun 2018 13:54:16 -0400
Date: Fri, 22 Jun 2018 13:54:16 -0400
To: Manjunath Patil <manjunath.b.patil@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: return ENOSPC if unable to allocate a session
 slot
Message-ID: <20180622175416.GA7119@fieldses.org>
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
 <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 21, 2018 at 04:35:33PM +0000, Manjunath Patil wrote:
> Presently nfserr_jukebox is being returned by nfsd for create_session
> request if server is unable to allocate a session slot. This may be
> treated as NFS4ERR_DELAY by the clients and which may continue to re-try
> create_session in loop leading NFSv4.1+ mounts in hung state. nfsd
> should return nfserr_nospc in this case as per rfc5661(section-18.36.4
> subpoint 4. Session creation).

I don't think the spec actually gives us an error that we can use to say
a CREATE_SESSION failed permanently for lack of resources.

Better would be to avoid the need to fail at all.  Possibilities:

	- revive Trond's patches some time back to do dynamic slot size
	  renegotiation
	- make sure the systems you're testing on already have
	  de766e570413 and 44d8660d3bb0 applied.
	- further liberalise the limits here: do we need them at all, or
	  should we just wait till a kmalloc fails?  Or maybe take a
	  hybrid approach?: e.g. allow an arbitrary number of clients
	  and only limit slots & slotsizes.

--b.

> 
> Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 8571414..3734e08 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2716,7 +2716,7 @@ static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs *ca, struct nfs
>  	 */
>  	ca->maxreqs = nfsd4_get_drc_mem(ca);
>  	if (!ca->maxreqs)
> -		return nfserr_jukebox;
> +		return nfserr_nospc;
>  
>  	return nfs_ok;
>  }
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
