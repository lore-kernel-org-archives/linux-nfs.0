Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33662 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755550AbcLSQyW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2016 11:54:22 -0500
Received: by mail-io0-f194.google.com with SMTP id p13so19719578ioi.0
        for <linux-nfs@vger.kernel.org>; Mon, 19 Dec 2016 08:54:22 -0800 (PST)
Subject: Re: [PATCH 1/9] NFSv4: Don't invalidate the directory twice
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <2099263b-3d8e-f237-3dd8-50dc0f63fb3e@gmail.com>
Date: Mon, 19 Dec 2016 11:54:20 -0500
MIME-Version: 1.0
In-Reply-To: <20161217182711.10643-2-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 12/17/2016 01:27 PM, Trond Myklebust wrote:
> If an operation that modified the directory raced with a GETATTR, then we
> don't need to invalidate the directory cache more than once.

This patch causes cthon basic tests to fail with:

./test6: readdir
        ./test6: (/nfs/all) unlinked 'file.0' dir entry read pass 1
        ./test6: (/nfs/all) Test failed with 1 errors
basic tests failed

Thanks,
Anna
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d33242c8d95d..713932440e07 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1088,12 +1088,15 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
>  	struct nfs_inode *nfsi = NFS_I(dir);
>  
>  	spin_lock(&dir->i_lock);
> +	if (dir->i_version == cinfo->after)
> +		goto out;
>  	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
>  	if (!cinfo->atomic || cinfo->before != dir->i_version)
>  		nfs_force_lookup_revalidate(dir);
>  	dir->i_version = cinfo->after;
>  	nfsi->attr_gencount = nfs_inc_attr_generation_counter();
>  	nfs_fscache_invalidate(dir);
> +out:
>  	spin_unlock(&dir->i_lock);
>  }
>  
> 
