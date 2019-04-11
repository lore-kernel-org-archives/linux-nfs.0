Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4456CC10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 20:47:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0D36F2146F
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 20:47:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fyALUXWQ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726857AbfDKUr2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 16:47:28 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:47068 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726629AbfDKUr2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2019 16:47:28 -0400
Received: by mail-io1-f65.google.com with SMTP id p23so6553873iol.13;
        Thu, 11 Apr 2019 13:47:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=6uAnZiYuQzWBj9XUUGSzFYAyojmptOXbfWruRzXNe88=;
        b=fyALUXWQvs9vHik//9OIUTuZiERxJE4qqE9SKLDDCiAa94KLKAy1FKV4Efqzs7AoXI
         WeWgubLxn71YtAuyO+chaJ0FG7QtjOemIlHZ3zPeIPV8vFPmbL+QudxvZ1LM4lFku2Lr
         ptls33oFFYrcKQ4d6efwRNhP0fwmXQnyUWnA4DPyBqEjmWx7k4Lp9sXoGVTImwRGQYlw
         YCEW9BI0Y51/0e9UnpfOktnFz75A6rsuTJMjppWKTGnCfMFYbqBNokSFrlWtRz1PZbSr
         Dd/zrTEFK2J2oAuI2b5+OQeXN/flyxcXLENnZVPVM/Hi2xvjQptV1y7C6eharg06DmDG
         NN8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=6uAnZiYuQzWBj9XUUGSzFYAyojmptOXbfWruRzXNe88=;
        b=dphsnOj9C82asytFk5xl0XuZ4xmNyEKaXG82riDwU9ajCVDOOzMWMvWvrf3IUIle5F
         EbN8ry6pCXYJGADUUHCcNJHzDZjHQ1DUgU/ReSu93vgamsbjDcue8w9NA/Nk4vap6fyH
         HLPkWBoMYSWdbj/mN6pgYnf8CpDw5B2WIshFBw/mQBv1nyQOVEKrhyF6V+EuSTBYtrf1
         3bma0DqgDzB43ZLBOsEAkPE7PS7ofIGnkhI4wsbJBx5rFt/n172IHAPIibBSzMOPdO7F
         MY+HUK/KNImoU4t3cfxnKarebNfkitAa0w2/Yg5C0pMALDYljU3DalCD4JPvCyL6rp+J
         b9Aw==
X-Gm-Message-State: APjAAAWV/HYvON+KNl7FLfYDDHcO6AAddFy732eJomFTh1dEbyOaQ4+0
        Gi7vYJGIRtt3PULKduBJh3wUUXoOJ50=
X-Google-Smtp-Source: APXvYqwEUPsCZaza01qvKZzY4doACTU/ZqbaSBwW4N98D7DO48148GnqrHXCeEi9tVKz9cuDcps7Eg==
X-Received: by 2002:a6b:144b:: with SMTP id 72mr35884895iou.191.1555015646912;
        Thu, 11 Apr 2019 13:47:26 -0700 (PDT)
Received: from gouda.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.googlemail.com with ESMTPSA id i11sm16168615ioq.71.2019.04.11.13.47.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Apr 2019 13:47:25 -0700 (PDT)
Message-ID: <0d66402eb20f5f6aa74572d2e15239aa1be04bef.camel@gmail.com>
Subject: Re: [PATCH v1 05/19] xprtrdma: Clean up rpcrdma_create_rep() and
 rpcrdma_destroy_rep()
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date:   Thu, 11 Apr 2019 16:47:24 -0400
In-Reply-To: <20190410200658.11522.59896.stgit@manet.1015granger.net>
References: <20190410200446.11522.21145.stgit@manet.1015granger.net>
         <20190410200658.11522.59896.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Chuck,

On Wed, 2019-04-10 at 16:06 -0400, Chuck Lever wrote:
> For code legibility, clean up the function names to be consistent
> with the pattern: "rpcrdma" _ object-type _ action
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |   21 ++++++++-------------
>  1 file changed, 8 insertions(+), 13 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 82ea298..3bc751e 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -76,7 +76,6 @@
>  static void rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc);
>  static void rpcrdma_mrs_create(struct rpcrdma_xprt *r_xprt);
>  static void rpcrdma_mrs_destroy(struct rpcrdma_buffer *buf);
> -static int rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt, bool temp);
>  static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
>  static void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp);
>  
> @@ -1029,15 +1028,12 @@ struct rpcrdma_req *rpcrdma_req_create(struct
> rpcrdma_xprt *r_xprt, gfp_t flags)
>  	return req;
>  }
>  
> -static int
> -rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt, bool temp)
> +static bool rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt, bool temp)
>  {
>  	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
>  	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
>  	struct rpcrdma_rep *rep;
> -	int rc;
>  
> -	rc = -ENOMEM;

rc is used again a little lower, in the IS_ERR(rep->rr_rdmabuf) check. Can you
remove it there too, please?

Thanks,
Anna

>  	rep = kzalloc(sizeof(*rep), GFP_KERNEL);
>  	if (rep == NULL)
>  		goto out;
> @@ -1063,12 +1059,12 @@ struct rpcrdma_req *rpcrdma_req_create(struct
> rpcrdma_xprt *r_xprt, gfp_t flags)
>  	spin_lock(&buf->rb_lock);
>  	list_add(&rep->rr_list, &buf->rb_recv_bufs);
>  	spin_unlock(&buf->rb_lock);
> -	return 0;
> +	return true;
>  
>  out_free:
>  	kfree(rep);
>  out:
> -	return rc;
> +	return false;
>  }
>  
>  int
> @@ -1124,8 +1120,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct
> rpcrdma_xprt *r_xprt, gfp_t flags)
>  	return rc;
>  }
>  
> -static void
> -rpcrdma_destroy_rep(struct rpcrdma_rep *rep)
> +static void rpcrdma_rep_destroy(struct rpcrdma_rep *rep)
>  {
>  	rpcrdma_free_regbuf(rep->rr_rdmabuf);
>  	kfree(rep);
> @@ -1205,7 +1200,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct
> rpcrdma_xprt *r_xprt, gfp_t flags)
>  		rep = list_first_entry(&buf->rb_recv_bufs,
>  				       struct rpcrdma_rep, rr_list);
>  		list_del(&rep->rr_list);
> -		rpcrdma_destroy_rep(rep);
> +		rpcrdma_rep_destroy(rep);
>  	}
>  
>  	while (!list_empty(&buf->rb_send_bufs)) {
> @@ -1334,7 +1329,7 @@ struct rpcrdma_req *
>  	}
>  	spin_unlock(&buffers->rb_lock);
>  	if (rep)
> -		rpcrdma_destroy_rep(rep);
> +		rpcrdma_rep_destroy(rep);
>  }
>  
>  /*
> @@ -1351,7 +1346,7 @@ struct rpcrdma_req *
>  		list_add(&rep->rr_list, &buffers->rb_recv_bufs);
>  		spin_unlock(&buffers->rb_lock);
>  	} else {
> -		rpcrdma_destroy_rep(rep);
> +		rpcrdma_rep_destroy(rep);
>  	}
>  }
>  
> @@ -1500,7 +1495,7 @@ struct rpcrdma_regbuf *
>  			list_del(&rep->rr_list);
>  		spin_unlock(&buf->rb_lock);
>  		if (!rep) {
> -			if (rpcrdma_create_rep(r_xprt, temp))
> +			if (!rpcrdma_rep_create(r_xprt, temp))
>  				break;
>  			continue;
>  		}
> 

