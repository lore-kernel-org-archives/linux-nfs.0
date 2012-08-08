Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43433 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652Ab2HHMtf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 08:49:35 -0400
Message-ID: <5022605D.6060901@netapp.com>
Date: Wed, 08 Aug 2012 08:49:33 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS41: fix error of setting blocklayoutdriver
References: <1344390577-1602-1-git-send-email-bergwolf@gmail.com> <1344390577-1602-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344390577-1602-2-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2012 09:49 PM, Peng Tao wrote:
> After commit e38eb650 (NFS: set_pnfs_layoutdriver() from
> nfs4_proc_fsinfo()), set_pnfs_layoutdriver() is called inside
> nfs4_proc_fsinfo(), but pnfs_blksize is not set. It causes setting
> blocklayoutdriver failure and pnfsblock mount failure.
> 
> Cc: Bryan Schumaker <bjschuma@netapp.com>
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  fs/nfs/nfs4proc.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 78b2163..299c311 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3362,8 +3362,11 @@ static int nfs4_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, s
>  
>  	nfs_fattr_init(fsinfo->fattr);
>  	error = nfs4_do_fsinfo(server, fhandle, fsinfo);
> -	if (error == 0)
> +	if (error == 0) {
> +		/* block layout checks this! */
> +		server->pnfs_blksize = fsinfo->blksize;

fs/nfs/client.c:nfs_server_set_fsinfo() also sets this field, so I'm surprised there was a problem.  You should remove the same line from nfs_server_set_fsinfo() if you're going to set it here.

- Bryan

>  		set_pnfs_layoutdriver(server, fhandle, fsinfo->layouttype);
> +	}
>  
>  	return error;
>  }
> 

