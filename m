Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DBE2C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 17:56:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DFB9820874
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 17:56:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545069409;
	bh=HawIpgmdC2avxp5D8Lhdnsk7PnER3qJFKPS8eU+8eh8=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=aeuUlVWVZXMHo81ALSimXLowgBMmJNV+MeTuYjo1rqKZmwuLLkWRXPO+kwL+J4/ia
	 QMjxrz0pB4qAUgqdyNqLicep/RcN7bDzGrjkVIt8eih6jifFT9WPx6Kofj9hJfZxJs
	 ivp0FonRAdwMgJNAehSY6qw+/j62eVcP8GzYbWg8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727200AbeLQR4s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 12:56:48 -0500
Received: from mail.kernel.org ([198.145.29.99]:59694 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726801AbeLQR4s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Dec 2018 12:56:48 -0500
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4CD4F2086C;
        Mon, 17 Dec 2018 17:56:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1545069407;
        bh=HawIpgmdC2avxp5D8Lhdnsk7PnER3qJFKPS8eU+8eh8=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=BAOtPqSRZ/tkq+Kmtx+Fj8qytoNGvykpovy4lSmuJZqCdGrp4Hu2tL2bWago8gRVR
         WqH5qhgSlS3+BsjgcEvPgqyIy9jMA0j6c/n4l27fAGHjXV22xfP6qLTBIZgMXIBl6v
         4b2JyTypJFwSMelkFLTgd2LM/as+YY2EQMaIrD7U=
Message-ID: <285400e54a70548b4404ecdba9e44c4e8e6c5953.camel@kernel.org>
Subject: Re: [PATCH 4/4] nfs: fix debug message in svc_create_xprt()
From:   Jeff Layton <jlayton@kernel.org>
To:     Vasily Averin <vvs@virtuozzo.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>,
        Konstantin Khorenko <khorenko@virtuozzo.com>
Date:   Mon, 17 Dec 2018 12:56:44 -0500
In-Reply-To: <cff6406f-5c47-d0c6-64c8-48274c811d86@virtuozzo.com>
References: <cff6406f-5c47-d0c6-64c8-48274c811d86@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.3 (3.30.3-1.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2018-12-17 at 19:26 +0300, Vasily Averin wrote:
> _svc_create_xprt() returns positive port number 
> so its non-zero return value is not an error
> 
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  net/sunrpc/svc_xprt.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 51d36230b6e3..130af22d5c66 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -296,9 +296,9 @@ int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
>  		request_module("svc%s", xprt_name);
>  		err = _svc_create_xprt(serv, xprt_name, net, family, port, flags);
>  	}
> -	if (err)
> +	if (err < 0)
>  		dprintk("svc: transport %s not found, err %d\n",
> -			xprt_name, err);
> +			xprt_name, -err);
>  	return err;
>  }
>  EXPORT_SYMBOL_GPL(svc_create_xprt);

This patch is fine, but _svc_create_xprt does not make it clear that it
returns a positive port number.

Would you be amenable to spinning up a patch to add a kerneldoc comment
over that function (and maybe one over svc_create_xprt too), to make it
clear what it does?

Thanks,

Reviewed-by: Jeff Layton <jlayton@kernel.org>

