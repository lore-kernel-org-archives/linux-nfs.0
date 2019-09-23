Return-Path: <SRS0=Jjwl=XS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 325E9C4CEC4
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Sep 2019 16:20:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0633F20820
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Sep 2019 16:20:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388971AbfIWQU0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 23 Sep 2019 12:20:26 -0400
Received: from fieldses.org ([173.255.197.46]:57724 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388829AbfIWQU0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Sep 2019 12:20:26 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 08BDFBCC; Mon, 23 Sep 2019 12:20:26 -0400 (EDT)
Date:   Mon, 23 Sep 2019 12:20:26 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     YueHaibing <yuehaibing@huawei.com>
Cc:     chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next] nfsd: Make nfsd_reset_boot_verifier_locked static
Message-ID: <20190923162026.GB1228@fieldses.org>
References: <20190923055859.5616-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190923055859.5616-1-yuehaibing@huawei.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Sep 23, 2019 at 01:58:59PM +0800, YueHaibing wrote:
> Fix sparse warning:
> 
> fs/nfsd/nfssvc.c:364:6: warning:
>  symbol 'nfsd_reset_boot_verifier_locked' was not declared. Should it be static?
> 
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>

OK, applied for 5.4.--b.

> ---
>  fs/nfsd/nfssvc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 3caaf56..fdf7ed4 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -361,7 +361,7 @@ void nfsd_copy_boot_verifier(__be32 verf[2], struct nfsd_net *nn)
>  	done_seqretry(&nn->boot_lock, seq);
>  }
>  
> -void nfsd_reset_boot_verifier_locked(struct nfsd_net *nn)
> +static void nfsd_reset_boot_verifier_locked(struct nfsd_net *nn)
>  {
>  	ktime_get_real_ts64(&nn->nfssvc_boot);
>  }
> -- 
> 2.7.4
> 
