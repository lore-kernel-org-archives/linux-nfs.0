Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:39954 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965852Ab2C3VvW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Mar 2012 17:51:22 -0400
Message-ID: <4F762AD1.2090306@panasas.com>
Date: Fri, 30 Mar 2012 14:51:13 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: [osd-dev] [PATCH] pnfs-obj: Remove unused variable from objlayout_get_deviceinfo()
References: <4F7625D7.8070801@panasas.com>
In-Reply-To: <4F7625D7.8070801@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/30/2012 02:29 PM, Boaz Harrosh wrote:

> From: Sachin Bhamare <sbhamare@panasas.com>
> 
> Local variable 'sb' was not being used in objlayout_get_deviceinfo().
> 
> Signed-off-by: Sachin Bhamare <sbhamare@panasas.com>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>


I was transitioning all my tree's to the 3.4-rc0 Kernel and noticed
we forgot this patch, Please add it to what ever next-kernel branch you
have.

Benny could you please make a pnfs-all-3.3 branch? It should be identical
to the 3.3-rc6, probably, but just for completeness.

Tell me if you also want to add the autologin patches to it I can help
out with that. Else the client side went into 3.4-rc0 so I'll send you
the exofs side for your future 3.4-rc1 tree.

Thanks
Boaz

> ---
>  fs/nfs/objlayout/objlayout.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index 1ae53eb..b158d1b 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -604,7 +604,6 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
>  {
>  	struct objlayout_deviceinfo *odi;
>  	struct pnfs_device pd;
> -	struct super_block *sb;
>  	struct page *page, **pages;
>  	u32 *p;
>  	int err;
> @@ -623,7 +622,6 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
>  	pd.pglen = PAGE_SIZE;
>  	pd.mincount = 0;
>  
> -	sb = pnfslay->plh_inode->i_sb;
>  	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd);
>  	dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
>  	if (err)


