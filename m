Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:49129 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932555AbbCPPDP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2015 11:03:15 -0400
Message-ID: <5506F0B0.4010204@Netapp.com>
Date: Mon, 16 Mar 2015 11:03:12 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Use correct reply size calculating function
References: <5505A6AF.7040608@gmail.com>
In-Reply-To: <5505A6AF.7040608@gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/15/2015 11:35 AM, Kinglong Mee wrote:
> ALLOCATE/DEALLOCATE only reply one status value to client,
> so, using nfsd4_only_status_rsize for reply size calculating.

Makes sense to me.  Thanks for catching this!

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
> 

