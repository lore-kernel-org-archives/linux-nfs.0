Return-Path: <SRS0=vPHX=PY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFA62C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 02:48:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A058620866
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 02:48:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728808AbfAPCsq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Jan 2019 21:48:46 -0500
Received: from mx1.redhat.com ([209.132.183.28]:50300 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728619AbfAPCsq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Jan 2019 21:48:46 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9A6BC37E66;
        Wed, 16 Jan 2019 02:48:45 +0000 (UTC)
Received: from ming.t460p (ovpn-8-27.pek2.redhat.com [10.72.8.27])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 131811042B7B;
        Wed, 16 Jan 2019 02:48:39 +0000 (UTC)
Date:   Wed, 16 Jan 2019 10:48:33 +0800
From:   Ming Lei <ming.lei@redhat.com>
To:     Stephen Rothwell <sfr@canb.auug.org.au>
Cc:     Jens Axboe <axboe@kernel.dk>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: linux-next: build failure after merge of the block tree
Message-ID: <20190116024832.GA26146@ming.t460p>
References: <20190116133552.37436b9c@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190116133552.37436b9c@canb.auug.org.au>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 16 Jan 2019 02:48:45 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jan 16, 2019 at 01:35:52PM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the block tree, today's linux-next build (arm
> multi_v7_defconfig) failed like this:
> 
> net/sunrpc/xprtsock.c: In function 'xs_flush_bvec':
> net/sunrpc/xprtsock.c:390:2: error: implicit declaration of function 'for_each_bvec'; did you mean 'for_each_net'? [-Werror=implicit-function-declaration]
>   for_each_bvec(bv, bvec, bi, bi)
>   ^~~~~~~~~~~~~
>   for_each_net
> net/sunrpc/xprtsock.c:390:33: error: expected ';' before 'flush_dcache_page'
>   for_each_bvec(bv, bvec, bi, bi)
>                                  ^
>                                  ;
>    flush_dcache_page(bv.bv_page);
>    ~~~~~~~~~~~~~~~~~              
> 
> Caused by commit
> 
>   f3effe4c1240 ("block: rename bvec helpers")
> 
> interacting with commit
> 
>   6a829eb8619f ("SUNRPC: Fix TCP receive code on archs with flush_dcache_page()")
> 
> from the nfs-anna tree.
> 
> [I love API changes :-(]
> 
> I have applied the following merge fix patch:
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 16 Jan 2019 13:32:59 +1100
> Subject: [PATCH] SUNRPC: merge fix for "block: rename bvec helpers"
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  net/sunrpc/xprtsock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7754aa3e434f..47f29cc23f27 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -387,7 +387,7 @@ xs_flush_bvec(const struct bio_vec *bvec, size_t count, size_t seek)
>  	struct bio_vec bv;
>  
>  	bvec_iter_advance(bvec, &bi, seek & PAGE_MASK);
> -	for_each_bvec(bv, bvec, bi, bi)
> +	for_each_segment(bv, bvec, bi, bi)
>  		flush_dcache_page(bv.bv_page);
>  }
>  #else

This fix is correct, thanks!

Thanks,
Ming
