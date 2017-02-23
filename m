Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:6038 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751242AbdBWVzy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 16:55:54 -0500
Subject: Re: [PATCH 2/2] NFSv4: fix getacl ERANGE for some ACL buffer sizes
To: "J. Bruce Fields" <bfields@redhat.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-3-git-send-email-bfields@redhat.com>
 <261D4020-D9E4-4F1E-81CF-11EAAEABA684@primarydata.com>
 <20170222223656.GG24122@parsley.fieldses.org>
 <6606b2d5-719f-9e27-6f95-eec8cebfb1a8@gmail.com>
 <20170223194321.GF9417@parsley.fieldses.org>
 <20170223195338.GG9417@parsley.fieldses.org>
 <20170223195420.GH9417@parsley.fieldses.org>
CC: Weston Andros Adamson <dros@primarydata.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@netapp.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <fa063153-9be2-cd82-0756-ec9ad6873d4b@Netapp.com>
Date: Thu, 23 Feb 2017 16:54:43 -0500
MIME-Version: 1.0
In-Reply-To: <20170223195420.GH9417@parsley.fieldses.org>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, Bruce and Dros!

Anna

On 02/23/2017 02:54 PM, J. Bruce Fields wrote:
> From: Weston Andros Adamson <dros@primarydata.com>
> 
> We're not taking into account that the space needed for the (variable
> length) attr bitmap, with the result that we'd sometimes get a spurious
> ERANGE when the ACL data got close to the end of a page.
> 
> Just add in an extra page to make sure.
> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfs/nfs4proc.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 0a0eaecf9676..60501e10625d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5069,7 +5069,7 @@ static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size
>   */
>  static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
>  {
> -	struct page *pages[NFS4ACL_MAXPAGES] = {NULL, };
> +	struct page *pages[NFS4ACL_MAXPAGES + 1] = {NULL, };
>  	struct nfs_getaclargs args = {
>  		.fh = NFS_FH(inode),
>  		.acl_pages = pages,
> @@ -5083,13 +5083,9 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>  		.rpc_argp = &args,
>  		.rpc_resp = &res,
>  	};
> -	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
> +	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE) + 1;
>  	int ret = -ENOMEM, i;
>  
> -	/* As long as we're doing a round trip to the server anyway,
> -	 * let's be prepared for a page of acl data. */
> -	if (npages == 0)
> -		npages = 1;
>  	if (npages > ARRAY_SIZE(pages))
>  		return -ERANGE;
>  
> 
