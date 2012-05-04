Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:46207 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753566Ab2EDS45 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2012 14:56:57 -0400
Message-ID: <4FA42663.1020403@panasas.com>
Date: Fri, 4 May 2012 21:56:35 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 2/2] NFS: Fix sparse warnings
References: <1336154959-10705-1-git-send-email-Trond.Myklebust@netapp.com> <1336154959-10705-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1336154959-10705-2-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/04/2012 09:09 PM, Trond Myklebust wrote:

> Fix the following sparse warnings:
> 
> fs/nfs/direct.c:221:6: warning: symbol 'nfs_direct_readpage_release' was
> not declared. Should it be static?
> fs/nfs/read.c:38:43: warning: non-ANSI function declaration of function
> 'nfs_readhdr_alloc'
> fs/nfs/objlayout/objio_osd.c:214:5: warning: symbol '__alloc_objio_seg'
> was not declared. Should it be static?
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Fred Isaman <iisaman@netapp.com>
> Cc: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/direct.c              |    2 +-
>  fs/nfs/objlayout/objio_osd.c |    2 +-
>  fs/nfs/read.c                |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index dca9c81..257d009 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -218,7 +218,7 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq)
>  	nfs_direct_req_release(dreq);
>  }
>  
> -void nfs_direct_readpage_release(struct nfs_page *req)
> +static void nfs_direct_readpage_release(struct nfs_page *req)
>  {
>  	dprintk("NFS: direct read done (%s/%lld %d@%lld)\n",
>  		req->wb_context->dentry->d_inode->i_sb->s_id,
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index fbf4874..b47277b 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -211,7 +211,7 @@ static void copy_single_comp(struct ore_components *oc, unsigned c,
>  	memcpy(ocomp->cred, src_comp->oc_cap.cred, sizeof(ocomp->cred));
>  }
>  
> -int __alloc_objio_seg(unsigned numdevs, gfp_t gfp_flags,
> +static int __alloc_objio_seg(unsigned numdevs, gfp_t gfp_flags,
>  		       struct objio_segment **pseg)
>  {


Thanks!

Stupid compiler "can't you see the '__' of course it's static" ;-)

I hope that's the last one of that.

Boaz

>  /*	This is the in memory structure of the objio_segment
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index 37c9eb2..f23cf25 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -35,7 +35,7 @@ static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops;
>  
>  static struct kmem_cache *nfs_rdata_cachep;
>  
> -struct nfs_read_header *nfs_readhdr_alloc()
> +struct nfs_read_header *nfs_readhdr_alloc(void)
>  {
>  	struct nfs_read_header *rhdr;
>  


