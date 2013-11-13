Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754213Ab3KMQJj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 11:09:39 -0500
Date: Wed, 13 Nov 2013 11:09:37 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weng Meiling <wengmeiling.weng@huawei.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH] nfsd:add '\n' when read file supported_krb5_enctypes
Message-ID: <20131113160937.GI28033@fieldses.org>
References: <52786412.5030403@huawei.com>
 <527C9170.9030005@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <527C9170.9030005@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 08, 2013 at 03:23:28PM +0800, Weng Meiling wrote:
> 
> From: Weng Meiling <wengmeiling.weng@huawei.com>

I agree completely that a \n at the end would make more sense.

Have you tested that this nfs-utils is OK with this change?

I suspect that the only code that reads this file anywhere is

	nfs-utils/utils/gssd/svcgssd_krb5.c:parse_enctypes()

And on a quick skim of that function.... I *think* it should be fine.
But I'd be happier if you could confirm that you've tested it.

--b.

> 
> Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
> ---
>  fs/nfsd/nfsctl.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 7f55517..31db42c 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -188,7 +188,7 @@ static const struct file_operations export_features_operations = {
>  #if defined(CONFIG_SUNRPC_GSS) || defined(CONFIG_SUNRPC_GSS_MODULE)
>  static int supported_enctypes_show(struct seq_file *m, void *v)
>  {
> -	seq_printf(m, KRB5_SUPPORTED_ENCTYPES);
> +	seq_printf(m, "%s\n", KRB5_SUPPORTED_ENCTYPES);
>  	return 0;
>  }
> 
> -- 
> 1.8.3.1
> 
> 
> 
> 
