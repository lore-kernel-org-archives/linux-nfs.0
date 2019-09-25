Return-Path: <SRS0=I3JF=XU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F709C432C2
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Sep 2019 15:13:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DAD2A21D7B
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Sep 2019 15:13:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726327AbfIYPNW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 25 Sep 2019 11:13:22 -0400
Received: from fieldses.org ([173.255.197.46]:60570 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726287AbfIYPNW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Sep 2019 11:13:22 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 1D0981511; Wed, 25 Sep 2019 11:13:22 -0400 (EDT)
Date:   Wed, 25 Sep 2019 11:13:22 -0400
From:   "J . Bruce Fields" <bfields@fieldses.org>
To:     Colin King <colin.king@canonical.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: clean up indentation issue
Message-ID: <20190925151322.GA8581@fieldses.org>
References: <20190925130930.13076-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190925130930.13076-1-colin.king@canonical.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Applied, thanks.--b.

On Wed, Sep 25, 2019 at 02:09:30PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> There are statements that are indented incorrectly, remove the
> extraneous spacing.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/sunrpc/svc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 220b79988000..d11b70552c33 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1233,8 +1233,8 @@ svc_generic_init_request(struct svc_rqst *rqstp,
>  
>  	if (rqstp->rq_vers >= progp->pg_nvers )
>  		goto err_bad_vers;
> -	  versp = progp->pg_vers[rqstp->rq_vers];
> -	  if (!versp)
> +	versp = progp->pg_vers[rqstp->rq_vers];
> +	if (!versp)
>  		goto err_bad_vers;
>  
>  	/*
> -- 
> 2.20.1
