From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH 1/2] NFS: Fix a bug in nfs_fscache_release_page()
Date: Sun, 07 Feb 2010 16:56:15 +0530
Message-ID: <4B6EA357.3000604@suse.de>
References: <1265409793-18314-1-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48514 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754640Ab0BGL0Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Feb 2010 06:26:24 -0500
In-Reply-To: <1265409793-18314-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/06/2010 04:13 AM, Trond Myklebust wrote:
> Not having an fscache cookie is perfectly valid if the user didn't mount
> with the fscache option.
> 
> This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=15234
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: stable@kernel.org
> ---
>  fs/nfs/fscache.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
> index fa58800..534adb8 100644
> --- a/fs/nfs/fscache.c
> +++ b/fs/nfs/fscache.c
> @@ -355,11 +355,11 @@ void nfs_fscache_reset_inode_cookie(struct inode *inode)
>  int nfs_fscache_release_page(struct page *page, gfp_t gfp)
>  {
>  	struct nfs_inode *nfsi = NFS_I(page->mapping->host);
> -	struct fscache_cookie *cookie = nfsi->fscache;
> -
> -	BUG_ON(!cookie);
>  
>  	if (PageFsCache(page)) {
> +		struct fscache_cookie *cookie = nfsi->fscache;
> +
> +		BUG_ON(!cookie);
>  		dfprintk(FSCACHE, "NFS: fscache releasepage (0x%p/0x%p/0x%p)\n",
>  			 cookie, page, nfsi);
>  

There are only two callers for nfs_fscache_release_page() -
nfs_release_page() and nfs_migrate_page(). nfs_migrate_page already does
this:

       if (PageFsCache(page))
                nfs_fscache_release_page(page, GFP_KERNEL);

and the assumption in nfs_release_page() is that the page should have
either PG_private set or PG_fscache set and nfs_fscache_release_page
gets called only if PG_private is not set.

I think the idea is that nfs_fscache_release_page should not get called
if fsc option is not used. So it appears to me this patch is fixing the
symptom not the actual issue. Perhaps, this the assumption in
nfs_release_page is wrong or the PageFsCache() check should be moved to
nfs_release_page?



Thanks,

-- 
Suresh Jayaraman
