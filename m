Return-Path: <SRS0=5YGM=OL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB4CFC04EB8
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 17:26:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 84AD520851
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 17:26:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CKHE5Dke"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84AD520851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725554AbeLBR03 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 12:26:29 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:39793 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725550AbeLBR03 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 12:26:29 -0500
Received: by mail-it1-f196.google.com with SMTP id a6so5272956itl.4
        for <linux-nfs@vger.kernel.org>; Sun, 02 Dec 2018 09:26:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:message-id:subject:to:cc:in-reply-to:references:organization
         :mime-version:date:user-agent:content-transfer-encoding;
        bh=OmFhsXCQRai9Jtkto9DZISpI7+xUR+dCn8F3+rynTi0=;
        b=CKHE5DkejNTu+yW7M+8TslWFBevN5lhqG3SHlp6euMNywvgT4SOnSUt031M9BDaECV
         St8AfoDj5rMJjT1d8WKgaZ6IEn3RG7pcq9nDe0k1cvhrSfVFlQS9tyqy9WduRKLtjfjO
         TsccEUyRzJI9+CnZubKj80kAwpVVHAFIT6B8VKS+8Rwu7SWQ57Ktdy+namp2zrApAFo9
         fJJI2uAgcHGuPgU/suF7BfJbyssQpC4bVZb8LJhzJue1bT1p75Yr4r6jt6yN7ET6tMzK
         DRRcjaEzE72B+UwCdOlbFLchdaw3YXGeTRbw0QEP/hfXZbGV1E8aHYScqXLSnDJrSgBQ
         k2WA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:message-id:subject:to:cc:in-reply-to
         :references:organization:mime-version:date:user-agent
         :content-transfer-encoding;
        bh=OmFhsXCQRai9Jtkto9DZISpI7+xUR+dCn8F3+rynTi0=;
        b=p9GE23u4dPLYZVU3iErsvoiwHOD/cR/0nvktHiSP5bogE+tro5F8rDTK9wCmZCKtZr
         0jMyNci1AlrBbE6+8d0YoWn6zJS8EeYIeM2sJo81IkpKj/dGcCXtEJFm79ia/uUHR4MN
         OfIGeeIiyVnbgVusqbh5oCOm6uc6hNBjMWoRB0pdiffxEguNtYaDTbP88swb8tW4OGSh
         AXEwvdpTcXV8GVCbLmU1TqyjGOenUbLpr0FovyLxdm0H7xrUQlKkcjN6WFSr9BPITpdz
         qqRAtbxJrUYGmlmbO6tyLY16IgYbdvilm+agxt7Tr+UXyvVIaLb57mWKf7bdF7Xk2Tza
         odoQ==
X-Gm-Message-State: AA+aEWYZXcS32H6AM1cgp0I4oaTOVEtwHNQMzN9sSQ7EbveY1pxedei3
        5amaSqgQh9KrIYTbY3TAaw==
X-Google-Smtp-Source: AFSGD/UGA8VaPKmt3T9VOPo9IByaJK9xkGFhjM6VKNKIr84V0mmCFhlZAB7uIgL8aQSpnWXw/LzoNQ==
X-Received: by 2002:a24:ce42:: with SMTP id v63mr5294727itg.136.1543771585706;
        Sun, 02 Dec 2018 09:26:25 -0800 (PST)
Received: from leira (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id q23sm4395867ioi.66.2018.12.02.09.26.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 02 Dec 2018 09:26:25 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trondmy@hammerspace.com>
Message-ID: <fdb18aece66221c91c0f8ce4e0a7849bc60505fc.camel@hammerspace.com>
Subject: Re: [PATCH] SUNRPC: Fix a potential race in xprt_connect()
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <4BAC007E-35BE-423B-BA11-5413D0EEDDBD@oracle.com>
References: <20181202144223.42562-1-trond.myklebust@hammerspace.com>
         <4BAC007E-35BE-423B-BA11-5413D0EEDDBD@oracle.com>
Organization: Hammerspace Inc
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Date:   Sun, 02 Dec 2018 12:26:11 -0500
User-Agent: Evolution 3.30.2 (3.30.2-2.fc29) 
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, 2018-12-02 at 12:07 -0500, Chuck Lever wrote:
> Test report.
> 
> I applied this on top of the three v4 patches from Friday.
> 
> With TCP, I no longer see the soft IRQ warnings or bdev leaks.
> However, at some point during my test (sec=krb5p,vers=3) the
> mount stops responding and the client becomes idle. ^C leaves
> the iozone processes in D state.

Does /proc/*/stack show any tasks with any interesting stack behaviour?

> 
> With RDMA, I can see a few issues:
>  - A lot of -74 and server disconnects. I suspect this is due
>    to GSS sequence window overruns
>  - xprt_connect puts the calling task to sleep if the credit
>    limit has been reached, and that can result in a deadlock
>  - The reconnect logic appears to busy-wait until something
>    else (eg, an RTO) forces a reconnect
>  - A connect or disconnect wake-up that occurs while an RPC
>    reply is being handled (ie, is still on xprt->pending)
>    results in that RPC being retried unnecessarily.
> 
> I'm not sure how to address that last one. Sometimes RDMA has
> to invalidate MRs, and that involves a wait/context swith which
> opens the race window significantly.

In principle the latter issue is supposed to be handled by the connect
cookies. Are the updates perhaps being ordered incorrectly w.r.t. the
xprt->pending wakeup? If so, then that could cause races.

I'd expect the cookie would need to be updated before the call to xprt-
>pending both on connect and disconnect.

> 
> > On Dec 2, 2018, at 9:42 AM, Trond Myklebust <trondmy@gmail.com>
> > wrote:
> > 
> > If an asynchronous connection attempt completes while another task
> > is
> > in xprt_connect(), then the call to rpc_sleep_on() could end up
> > racing with the call to xprt_wake_pending_tasks().
> > So add a second test of the connection state after we've put the
> > task to sleep and set the XPRT_CONNECTING flag, when we know that
> > there
> > can be no asynchronous connection attempts still in progress.
> > 
> > Fixes: 0b9e79431377d ("SUNRPC: Move the test for XPRT_CONNECTING
> > into...")
> > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> > ---
> > net/sunrpc/xprt.c | 11 +++++++++--
> > 1 file changed, 9 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index 122c91c28e7c..ce927002862a 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -826,8 +826,15 @@ void xprt_connect(struct rpc_task *task)
> > 			return;
> > 		if (xprt_test_and_set_connecting(xprt))
> > 			return;
> > -		xprt->stat.connect_start = jiffies;
> > -		xprt->ops->connect(xprt, task);
> > +		/* Race breaker */
> > +		if (!xprt_connected(xprt)) {
> > +			xprt->stat.connect_start = jiffies;
> > +			xprt->ops->connect(xprt, task);
> > +		} else {
> > +			xprt_clear_connecting(xprt);
> > +			task->tk_status = 0;
> > +			rpc_wake_up_queued_task(&xprt->pending, task);
> > +		}
> > 	}
> > 	xprt_release_write(xprt, task);
> > }
> > -- 
> > 2.19.2
> > 
> 
> --
> Chuck Lever
> 
> 
> 
-- 
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trond.myklebust@hammerspace.com



