Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57604 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932381AbdC2Vvd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Mar 2017 17:51:33 -0400
Date: Wed, 29 Mar 2017 17:51:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jason Yan <yanaijie@huawei.com>
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org,
        miaoxie@huawei.com, zhaohongjiang@huawei.com
Subject: Re: [PATCH] nfsd: make strdup_if_nonnull static
Message-ID: <20170329215132.GC29934@fieldses.org>
References: <1490259456-15858-1-git-send-email-yanaijie@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1490259456-15858-1-git-send-email-yanaijie@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 4.12.--b.

On Thu, Mar 23, 2017 at 04:57:36PM +0800, Jason Yan wrote:
> Fixes the following sparse warning:
> 
> fs/nfsd/nfs4state.c:1915:5: warning: symbol 'strdup_if_nonnull' was not
> declared. Should it be static?
> 
> Signed-off-by: Jason Yan <yanaijie@huawei.com>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e9ef50a..59a9e30 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1912,7 +1912,7 @@ static void copy_clid(struct nfs4_client *target, struct nfs4_client *source)
>  	target->cl_clientid.cl_id = source->cl_clientid.cl_id; 
>  }
>  
> -int strdup_if_nonnull(char **target, char *source)
> +static int strdup_if_nonnull(char **target, char *source)
>  {
>  	if (source) {
>  		*target = kstrdup(source, GFP_KERNEL);
> -- 
> 2.5.0
