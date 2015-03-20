Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41167 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbbCTUYx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2015 16:24:53 -0400
Date: Fri, 20 Mar 2015 16:24:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Anna.Schumaker@netapp.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Use correct reply size calculating function
Message-ID: <20150320202453.GC5955@fieldses.org>
References: <5505A6AF.7040608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5505A6AF.7040608@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 15, 2015 at 11:35:11PM +0800, Kinglong Mee wrote:
> ALLOCATE/DEALLOCATE only reply one status value to client,
> so, using nfsd4_only_status_rsize for reply size calculating.

Thanks!  Applying for 4.1.  (It's a bug, but I don't see an obvious
serious impact, so I'm assuming it doesn't need to go to 4.0 and stable.
Tell me if I've overlooked something.)

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4proc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 92b9d97..4449359 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -2282,13 +2282,13 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_func = (nfsd4op_func)nfsd4_allocate,
>  		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
>  		.op_name = "OP_ALLOCATE",
> -		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
>  	[OP_DEALLOCATE] = {
>  		.op_func = (nfsd4op_func)nfsd4_deallocate,
>  		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
>  		.op_name = "OP_DEALLOCATE",
> -		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
>  	[OP_SEEK] = {
>  		.op_func = (nfsd4op_func)nfsd4_seek,
> -- 
> 2.3.1
