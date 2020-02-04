Return-Path: <SRS0=C+as=3Y=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 711A4C35247
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Feb 2020 16:40:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 477552082E
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Feb 2020 16:40:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727317AbgBDQkw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Feb 2020 11:40:52 -0500
Received: from fieldses.org ([173.255.197.46]:37498 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727297AbgBDQkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Feb 2020 11:40:52 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id CD7FBABE; Tue,  4 Feb 2020 11:40:51 -0500 (EST)
Date:   Tue, 4 Feb 2020 11:40:51 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chen Zhou <chenzhou10@huawei.com>
Cc:     chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, yaohongbo@huawei.com
Subject: Re: [PATCH -next] nfsd: make nfsd_filecache_wq variable static
Message-ID: <20200204164051.GA8763@fieldses.org>
References: <20200203014357.114717-1-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200203014357.114717-1-chenzhou10@huawei.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applying.--b.

On Mon, Feb 03, 2020 at 09:43:57AM +0800, Chen Zhou wrote:
> Fix sparse warning:
> 
> fs/nfsd/filecache.c:55:25: warning:
> 	symbol 'nfsd_filecache_wq' was not declared. Should it be static?
> 
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> ---
>  fs/nfsd/filecache.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
> index 23c1fa5..22e77ed 100644
> --- a/fs/nfsd/filecache.c
> +++ b/fs/nfsd/filecache.c
> @@ -52,7 +52,7 @@ struct nfsd_fcache_disposal {
>  	struct rcu_head rcu;
>  };
>  
> -struct workqueue_struct *nfsd_filecache_wq __read_mostly;
> +static struct workqueue_struct *nfsd_filecache_wq __read_mostly;
>  
>  static struct kmem_cache		*nfsd_file_slab;
>  static struct kmem_cache		*nfsd_file_mark_slab;
> -- 
> 2.7.4
