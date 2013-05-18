Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esgaroth.petrovitsch.at ([78.47.184.11]:2161 "EHLO
	esgaroth.petrovitsch.priv.at" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752987Ab3ERLTP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 May 2013 07:19:15 -0400
Subject: Re: [PATCH v2] nfsd: avoid undefined signed overflow
From: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
To: Jim Rees <rees@umich.edu>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Sat, 18 May 2013 13:04:00 +0200
In-Reply-To: <1368826380-9864-1-git-send-email-rees@umich.edu>
References: <1368826380-9864-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1368875049.11003.31.camel@thorin>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fre, 2013-05-17 at 17:33 -0400, Jim Rees wrote:
> In C, signed integer overflow results in undefined behavior, but unsigned
> overflow wraps around. So do the subtraction first, then cast to signed.
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

Hmm, what is actually wrong with plain-old
----  snip  ----
static bool stateid_generation_after(stateid_t *a, stateid_t *b)
{
	return a->si_generation > b->si_generation;
}
----  snip  ----
?

Kind regards,
	Bernd
-- 
Bernd Petrovitsch                  Email : bernd@petrovitsch.priv.at
                     LUGA : http://www.luga.at

