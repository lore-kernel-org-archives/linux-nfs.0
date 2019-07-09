Return-Path: <SRS0=3zAd=VG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEB96C73C64
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Jul 2019 23:36:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9AF682082A
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Jul 2019 23:36:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727057AbfGIXgq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Jul 2019 19:36:46 -0400
Received: from fieldses.org ([173.255.197.46]:52800 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726218AbfGIXgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Jul 2019 19:36:46 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 607D11BE7; Tue,  9 Jul 2019 19:36:46 -0400 (EDT)
Date:   Tue, 9 Jul 2019 19:36:46 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     YueHaibing <yuehaibing@huawei.com>
Cc:     chuck.lever@oracle.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH -next] nfsd: Make two functions static
Message-ID: <20190709233646.GB1536@fieldses.org>
References: <20190708072933.50496-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190708072933.50496-1-yuehaibing@huawei.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applied.--b.

On Mon, Jul 08, 2019 at 03:29:33PM +0800, YueHaibing wrote:
> Fix sparse warnings:
> 
> fs/nfsd/nfs4state.c:1908:6: warning: symbol 'drop_client' was not declared. Should it be static?
> fs/nfsd/nfs4state.c:2518:6: warning: symbol 'force_expire_client' was not declared. Should it be static?
> 
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> ---
>  fs/nfsd/nfs4state.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 94de5c3..7857942 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1905,7 +1905,7 @@ static void __free_client(struct kref *k)
>  	kmem_cache_free(client_slab, clp);
>  }
>  
> -void drop_client(struct nfs4_client *clp)
> +static void drop_client(struct nfs4_client *clp)
>  {
>  	kref_put(&clp->cl_nfsdfs.cl_ref, __free_client);
>  }
> @@ -2515,7 +2515,7 @@ static const struct file_operations client_states_fops = {
>   * so the caller has a guarantee that the client's locks are gone by
>   * the time the write returns:
>   */
> -void force_expire_client(struct nfs4_client *clp)
> +static void force_expire_client(struct nfs4_client *clp)
>  {
>  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
>  	bool already_expired;
> -- 
> 2.7.4
> 
