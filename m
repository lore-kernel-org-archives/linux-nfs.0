Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38863 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932733Ab3D3WUS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Apr 2013 18:20:18 -0400
Date: Tue, 30 Apr 2013 18:20:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Subject: Re: [PATCH -next] nfsd: make symbol nfsd_reply_cache_shrinker static
Message-ID: <20130430222014.GF30768@fieldses.org>
References: <CAPgLHd-Op0pJQq5SJi5grQB9EhupYWOf=Udrpt_PUjFsB4j9Uw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAPgLHd-Op0pJQq5SJi5grQB9EhupYWOf=Udrpt_PUjFsB4j9Uw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applying, thanks.--b.

On Fri, Apr 05, 2013 at 09:22:39PM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> symbol 'nfsd_reply_cache_shrinker' only used within this file. It should
> be static.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  fs/nfsd/nfscache.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index f8bb605..890a507 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -56,7 +56,7 @@ static void	cache_cleaner_func(struct work_struct *unused);
>  static int 	nfsd_reply_cache_shrink(struct shrinker *shrink,
>  					struct shrink_control *sc);
>  
> -struct shrinker nfsd_reply_cache_shrinker = {
> +static struct shrinker nfsd_reply_cache_shrinker = {
>  	.shrink	= nfsd_reply_cache_shrink,
>  	.seeks	= 1,
>  };
> 
