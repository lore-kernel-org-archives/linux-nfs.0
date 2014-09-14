Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:42091 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbaINKtj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Sep 2014 06:49:39 -0400
Received: by mail-pa0-f50.google.com with SMTP id bj1so4434922pad.23
        for <linux-nfs@vger.kernel.org>; Sun, 14 Sep 2014 03:49:39 -0700 (PDT)
Message-ID: <541572BE.6000504@plexistor.com>
Date: Sun, 14 Sep 2014 13:49:34 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
CC: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2] nfs41: change PNFS_LAYOUTRET_ON_SETATTR to only return
 on truncation to smaller size
References: <1410491050-12858-1-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1410491050-12858-1-git-send-email-tao.peng@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/12/2014 06:04 AM, Peng Tao wrote:
> Both blocks layout and objects layout want to use it to avoid CB_LAYOUTRECALL
> but that should only happen if client is doing truncation to a smaller size.
> For other cases, we let server decide if it wants to recall client's layouts.
> Change PNFS_LAYOUTRET_ON_SETATTR to follow the logic and not to send
> layoutreturn unnecessarily.
> 
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Boaz Harrosh <boaz@plexistor.com>

Peng, Christoph Hi

This is in violation of the pnf-objects draft. We are obliged
on chown to return layouts because of how the CAPs work, they
have an embedded CAPs version which might increment when chown
is changed, and also the credential keys. Which means that using
the old layout will return an E_ACCESS from the OSD.

But..

I will agree with this patch. The above is true in an OSD
protocol higher then NO_SEC. But none of the current implementation
support anything other then NO_SEC.

Second also with none-NO_SEC once a client does a chown the server
needs to RECALL all other clients, so as Peng says above the Server
should/can also recall from us.

But some good sole needs to make an errata at the RFC draft so to
explain.

So:

ACK-by: Boaz Harrosh <bharrosh@panasas.com>
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 4 +++-
>  fs/nfs/pnfs.h     | 3 ++-
>  2 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 7dd8aca..63a5b80 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3213,7 +3213,9 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
>  	struct nfs4_label *label = NULL;
>  	int status;
>  
> -	if (pnfs_ld_layoutret_on_setattr(inode))
> +	if (pnfs_ld_layoutret_on_setattr(inode) &&
> +	    sattr->ia_valid & ATTR_SIZE &&
> +	    sattr->ia_size < i_size_read(inode))
>  		pnfs_commit_and_return_layout(inode);
>  
>  	nfs_fattr_init(fattr);
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index aca3dff..04a3646 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -68,7 +68,8 @@ enum {
>  };
>  
>  enum layoutdriver_policy_flags {
> -	/* Should the pNFS client commit and return the layout upon a setattr */
> +	/* Should the pNFS client commit and return the layout upon truncate to
> +	 * a smaller size */
>  	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
>  	PNFS_LAYOUTRET_ON_ERROR		= 1 << 1,
>  };
> 

