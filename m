Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44751C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 19:35:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 092B72084A
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 19:35:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UkDuxLLF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726988AbeLRTfh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 14:35:37 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:34358 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726719AbeLRTfg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Dec 2018 14:35:36 -0500
Received: by mail-io1-f65.google.com with SMTP id w21so13741361ioc.1;
        Tue, 18 Dec 2018 11:35:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=D2RdINkHfnleTSQdNC5OmVDtOcwfQqy4UIQ5A7IFcFM=;
        b=UkDuxLLFEQ78CWp59KNncDAe+D8bE1075yiu0GAwiKIAgJfvyPXuMn7bECK44eGIb1
         saQz8oDhNA6M8NaRJXi4Qe7aBaKZyKrWVl0ww6fXU0BcNTTeKvby+8JehaX/MHj8uA5y
         y2Mu4Y4CnPuuJzwmIticj6XcgoFEHJSGlgO9anvmgP6kcwt9cG2cNjAsu7hFCDFOEEYx
         yv+jt97pvqvs+mTLNM7oweJV6+nTi2qgxXhQrrxhgoJXe1oSmx6Q5fNUCl2+FZ+WlmB/
         xDDVOsN8MoeEIKb7Vw3VfI2YyBFVpk+1mnBW7imoDhEvqjy3lClFN2BAtRRYFcQrie6k
         QjYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=D2RdINkHfnleTSQdNC5OmVDtOcwfQqy4UIQ5A7IFcFM=;
        b=k+W9oRzEwmF4FXHDtBVyFN7KBO/ZXHTn5D7xzLl91BaKeELsICPHIaZXULDiE5zXSB
         axOYXy0gz+mgtiFT2VD7a5lGo6Srp9u53GBYl7JlQcRcyK8kREMk4EF6Lk108h0p9ET8
         S+RqYVyD/ZWJlLlb2DAeTnN1lnmkrYrDzMzgtsdZzDXMkUl2WLmtuz5PABg4+UYuDgQN
         UAcUTKvTidYGUvgbtGdnsokdtptH9a4/co7twNgDdJsq1fbMJfDpu7xpduTUqg5ggE0l
         nRJtqxJNY69zYrreH5X5BGYYHBiS2vSP7RfUTMcnan7CBURl+WiSDriiymGXUfSorInr
         Yx8g==
X-Gm-Message-State: AA+aEWZOrrBF6bEHCAztJ/QYO+i6tuj6XMJUAPQ94uJeJH38o/Iwzu3e
        3Geh9tnKIbzrXuqIiSHTglI=
X-Google-Smtp-Source: AFSGD/XapTKSkTNQLcyvk/dqxKY+yWVZ370yzvkXxyi81jpvCqNnJl84atuREKMdiSfEDkB0WBzDBw==
X-Received: by 2002:a6b:784b:: with SMTP id h11mr5740268iop.216.1545161735413;
        Tue, 18 Dec 2018 11:35:35 -0800 (PST)
Received: from gouda.nowheycreamery.com ([99.9.112.69])
        by smtp.googlemail.com with ESMTPSA id r63sm2191266ita.2.2018.12.18.11.35.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Dec 2018 11:35:34 -0800 (PST)
Message-ID: <ca236b957f74998d0104d9865b2d65943850d5b4.camel@gmail.com>
Subject: Re: [PATCH v4 07/30] xprtrdma: Fix ri_max_segs and the result of
 ro_maxpages
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date:   Tue, 18 Dec 2018 14:35:30 -0500
In-Reply-To: <20181217163958.24133.16923.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
         <20181217163958.24133.16923.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.3 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Chuck,

On Mon, 2018-12-17 at 11:39 -0500, Chuck Lever wrote:
> With certain combinations of krb5i/p, MR size, and r/wsize, I/O can
> fail with EMSGSIZE. This is because the calculated value of
> ri_max_segs (the max number of MRs per RPC) exceeded
> RPCRDMA_MAX_HDR_SEGS, which caused Read or Write list encoding to
> walk off the end of the transport header.
> 
> Once that was addressed, the ro_maxpages result has to be corrected
> to account for the number of MRs needed for Reply chunks, which is
> 2 MRs smaller than a normal Read or Write chunk.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/fmr_ops.c   |    7 +++++--
>  net/sunrpc/xprtrdma/frwr_ops.c  |    7 +++++--
>  net/sunrpc/xprtrdma/transport.c |    6 ++++--
>  3 files changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> index 7f5632c..78a0224 100644
> --- a/net/sunrpc/xprtrdma/fmr_ops.c
> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> @@ -176,7 +176,10 @@ enum {
>  
>  	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
>  				RPCRDMA_MAX_FMR_SGES);
> -	ia->ri_max_segs += 2;	/* segments for head and tail buffers */
> +	/* Reply chunks require segments for head and tail buffers */
> +	ia->ri_max_segs += 2;
> +	if (ia->ri_max_segs > RPCRDMA_MAX_HDR_SEGS)
> +		ia->ri_max_segs = RPCRDMA_MAX_HDR_SEGS;
>  	return 0;
>  }
>  
> @@ -186,7 +189,7 @@ enum {
>  fmr_op_maxpages(struct rpcrdma_xprt *r_xprt)
>  {
>  	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
> -		     RPCRDMA_MAX_HDR_SEGS * RPCRDMA_MAX_FMR_SGES);
> +		     (ia->ri_max_segs - 2) * RPCRDMA_MAX_FMR_SGES);

ia isn't defined in this function.  Should that be r_xprt->rx_ia.ri_max_segs
instead?

Thanks,
Anna

>  }
>  
>  /* Use the ib_map_phys_fmr() verb to register a memory region
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index 27222c0..f587e44 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -244,7 +244,10 @@
>  
>  	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
>  				ia->ri_max_frwr_depth);
> -	ia->ri_max_segs += 2;	/* segments for head and tail buffers */
> +	/* Reply chunks require segments for head and tail buffers */
> +	ia->ri_max_segs += 2;
> +	if (ia->ri_max_segs > RPCRDMA_MAX_HDR_SEGS)
> +		ia->ri_max_segs = RPCRDMA_MAX_HDR_SEGS;
>  	return 0;
>  }
>  
> @@ -257,7 +260,7 @@
>  	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>  
>  	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
> -		     RPCRDMA_MAX_HDR_SEGS * ia->ri_max_frwr_depth);
> +		     (ia->ri_max_segs - 2) * ia->ri_max_frwr_depth);
>  }
>  
>  static void
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index a16296b..fbb14bf 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -704,8 +704,10 @@
>   *	%-ENOTCONN if the caller should reconnect and call again
>   *	%-EAGAIN if the caller should call again
>   *	%-ENOBUFS if the caller should call again after a delay
> - *	%-EIO if a permanent error occurred and the request was not
> - *		sent. Do not try to send this message again.
> + *	%-EMSGSIZE if encoding ran out of buffer space. The request
> + *		was not sent. Do not try to send this message again.
> + *	%-EIO if an I/O error occurred. The request was not sent.
> + *		Do not try to send this message again.
>   */
>  static int
>  xprt_rdma_send_request(struct rpc_rqst *rqst)
> 

