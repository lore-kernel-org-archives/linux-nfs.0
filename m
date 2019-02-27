Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8957FC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 17:16:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6155A2183F
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 17:16:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729617AbfB0RQT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 12:16:19 -0500
Received: from mx1.redhat.com ([209.132.183.28]:62851 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726223AbfB0RQT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Feb 2019 12:16:19 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0639530BD62A;
        Wed, 27 Feb 2019 17:16:19 +0000 (UTC)
Received: from madhat.home.dicksonnet.net (ovpn-118-12.phx2.redhat.com [10.3.118.12])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B37C55D6A9;
        Wed, 27 Feb 2019 17:16:18 +0000 (UTC)
Subject: Re: [PATCH 3/3] svc_socket: fix use of undefined macro
 HAVE_GETRPCBYNUMBER_R
To:     Patrick Steinhardt <ps@pks.im>, linux-nfs@vger.kernel.org
References: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
 <5e9826aa52e17d30d7cfee0d3828c5dbecdbfc41.1549290423.git.ps@pks.im>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <b4f940b5-d073-7aff-7f20-0644a6e57be4@RedHat.com>
Date:   Wed, 27 Feb 2019 12:16:18 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <5e9826aa52e17d30d7cfee0d3828c5dbecdbfc41.1549290423.git.ps@pks.im>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 27 Feb 2019 17:16:19 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 2/4/19 9:31 AM, Patrick Steinhardt wrote:
> The macro HAVE_GETRPCBYNUMBER_R is set based on whether the
> `getrpcbynumber_r` function was found by autoconf or not. While another
> location correctly checks whether it is set by using `#ifdef`,
> `getservport()` instead wrongly uses `#if HAVE_GETRPCBYNUMBER_R`. This
> may cause a compilation error with gcc with "-Werror=undef" if the macro
> has not been defined.
> 
> Fix the error by using `#ifdef` instead.
> 
> Signed-off-by: Patrick Steinhardt <ps@pks.im>
Committed...

BTW... If the future, feel free to ping me it appears 
patches slide off my radar... like these did... ;-( 

steved.
> ---
>  support/nfs/svc_socket.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
> index 1239712..d56507a 100644
> --- a/support/nfs/svc_socket.c
> +++ b/support/nfs/svc_socket.c
> @@ -46,7 +46,7 @@ int getservport(u_long number, const char *proto)
>  	struct rpcent *rpcp;
>  	struct servent servbuf, *servp = NULL;
>  	int ret = 0;
> -#if HAVE_GETRPCBYNUMBER_R
> +#ifdef HAVE_GETRPCBYNUMBER_R
>  	char rpcdata[1024];
>  	struct rpcent rpcbuf;
>  
> 
