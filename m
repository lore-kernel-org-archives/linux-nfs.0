Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:33001 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752471AbbIQNEJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Sep 2015 09:04:09 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] nfs: fix v4.2 SEEK on files over 2 gigs
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
References: <20150916212127.GA5169@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Message-ID: <55FABA40.6010406@Netapp.com>
Date: Thu, 17 Sep 2015 09:04:00 -0400
MIME-Version: 1.0
In-Reply-To: <20150916212127.GA5169@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Bruce,

I actually worked on a version of this patch on my own yesterday, too.  Looks like you beat me to submitting it!  :)

On 09/16/2015 05:21 PM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We're incorrectly assigning a loff_t return to an int.  If SEEK_HOLE or
> SEEK_DATA returns an offset over 2^31 then the application will see a
> weird lseek() result (usually -EIO).

I saw roughly the same thing with xfstests generic/285.

> 
> Cc: stable@vger.kernel.org
> Fixes: bdcc2cd14e4e "NFSv4.2: handle NFS-specific llseek errors"
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Reviewed-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

> ---
>  fs/nfs/nfs42proc.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index d731bbf974aa..0f020e4d8421 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -175,10 +175,12 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
>  {
>  	struct nfs_server *server = NFS_SERVER(file_inode(filep));
>  	struct nfs4_exception exception = { };
> -	int err;
> +	loff_t err;
>  
>  	do {
>  		err = _nfs42_proc_llseek(filep, offset, whence);
> +		if (err >= 0)
> +			break;
>  		if (err == -ENOTSUPP)
>  			return -EOPNOTSUPP;
>  		err = nfs4_handle_exception(server, err, &exception);
> 

