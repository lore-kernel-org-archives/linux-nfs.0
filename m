Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33649 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757339Ab3EQVkc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 May 2013 17:40:32 -0400
Date: Fri, 17 May 2013 17:40:31 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: avoid undefined signed overflow
Message-ID: <20130517214031.GA14005@fieldses.org>
References: <1368826380-9864-1-git-send-email-rees@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368826380-9864-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 17, 2013 at 05:33:00PM -0400, Jim Rees wrote:
> In C, signed integer overflow results in undefined behavior, but unsigned
> overflow wraps around. So do the subtraction first, then cast to signed.

Thanks!  Applying for 3.11.

(I wonder if it actually bites anyone in practice?  Are there common
compilers or architectures where this makes a difference?  Even if so I
suppose that many generations is probably unlikely enough not to make
this worth backporting to stable branches.)

--b.

> 
> Suggested-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 316ec84..9850329 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3427,7 +3427,7 @@ grace_disallows_io(struct net *net, struct inode *inode)
>  /* Returns true iff a is later than b: */
>  static bool stateid_generation_after(stateid_t *a, stateid_t *b)
>  {
> -	return (s32)a->si_generation - (s32)b->si_generation > 0;
> +	return (s32)(a->si_generation - b->si_generation) > 0;
>  }
>  
>  static __be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session)
> -- 
> 1.8.2.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
