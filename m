Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45044 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023Ab3ACAeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jan 2013 19:34:07 -0500
Date: Wed, 2 Jan 2013 19:34:05 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: ycnian@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Pass correct slot number to nfsd4_put_drc_mem()
Message-ID: <20130103003404.GC26356@fieldses.org>
References: <1356343887-11952-1-git-send-email-ycnian@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1356343887-11952-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 24, 2012 at 06:11:27PM +0800, ycnian@gmail.com wrote:
> From: Yanchuan Nian <ycnian@gmail.com>
> 
> In alloc_session(), numslots is the correct slot number used by the session.
> But the slot number passed to nfsd4_put_drc_mem() is the one from nfs client.

Thanks, applying for 3.9.--b.

> 
> Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
> ---
>  fs/nfsd/nfs4state.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index ac8ed96..29924a0 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -905,7 +905,7 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan,
>  
>  	new = __alloc_session(slotsize, numslots);
>  	if (!new) {
> -		nfsd4_put_drc_mem(slotsize, fchan->maxreqs);
> +		nfsd4_put_drc_mem(slotsize, numslots);
>  		return NULL;
>  	}
>  	init_forechannel_attrs(&new->se_fchannel, fchan, numslots, slotsize, nn);
> -- 
> 1.7.4.4
> 
