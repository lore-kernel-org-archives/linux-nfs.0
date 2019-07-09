Return-Path: <SRS0=3zAd=VG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7A21C73C64
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Jul 2019 23:36:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 918432082A
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Jul 2019 23:36:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727030AbfGIXg4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Jul 2019 19:36:56 -0400
Received: from fieldses.org ([173.255.197.46]:52808 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726218AbfGIXg4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Jul 2019 19:36:56 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 4674E1C17; Tue,  9 Jul 2019 19:36:56 -0400 (EDT)
Date:   Tue, 9 Jul 2019 19:36:56 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     YueHaibing <yuehaibing@huawei.com>
Cc:     chuck.lever@oracle.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH -next] nfsd: Make __get_nfsdfs_client() static
Message-ID: <20190709233656.GC1536@fieldses.org>
References: <20190708125408.56016-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190708125408.56016-1-yuehaibing@huawei.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applied.--b.

On Mon, Jul 08, 2019 at 08:54:08PM +0800, YueHaibing wrote:
> Fix sparse warning:
> 
> fs/nfsd/nfsctl.c:1221:22: warning:
>  symbol '__get_nfsdfs_client' was not declared. Should it be static?
> 
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> ---
>  fs/nfsd/nfsctl.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 53833b3..0a9a49d 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1218,7 +1218,7 @@ static void clear_ncl(struct inode *inode)
>  }
>  
>  
> -struct nfsdfs_client *__get_nfsdfs_client(struct inode *inode)
> +static struct nfsdfs_client *__get_nfsdfs_client(struct inode *inode)
>  {
>  	struct nfsdfs_client *nc = inode->i_private;
>  
> -- 
> 2.7.4
> 
