Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33754 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752758Ab3DLOsH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Apr 2013 10:48:07 -0400
Date: Fri, 12 Apr 2013 10:48:04 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: fanchaoting <fanchaoting@cn.fujitsu.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: don't  calculate mem's size in loop every time
Message-ID: <20130412144804.GJ7081@fieldses.org>
References: <5163AF52.2080303@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5163AF52.2080303@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 09, 2013 at 02:04:02PM +0800, fanchaoting wrote:
> 
>  Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>

Thanks, this makes sense, but meanwhile I've been rewriting that
code--now pushed out to my for-3.10 branch.  Let me know if you see
anything that looks wrong there.

--b.

> ---
>  fs/nfsd/nfs4state.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2e27430..df3e3fd 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -716,8 +716,8 @@ static struct nfsd4_session *__alloc_session(int slotsize, int numslots)
>  	if (!new)
>  		return NULL;
>  	/* allocate each struct nfsd4_slot and data cache in one piece */
> +	mem = sizeof(struct nfsd4_slot) + slotsize;
>  	for (i = 0; i < numslots; i++) {
> -		mem = sizeof(struct nfsd4_slot) + slotsize;
>  		new->se_slots[i] = kzalloc(mem, GFP_KERNEL);
>  		if (!new->se_slots[i])
>  			goto out_free;
> -- 
> 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
