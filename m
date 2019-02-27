Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C56FC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 17:14:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D21912183F
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 17:14:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726877AbfB0ROS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 12:14:18 -0500
Received: from mx1.redhat.com ([209.132.183.28]:46528 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726181AbfB0ROS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Feb 2019 12:14:18 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EFE38F3FB1;
        Wed, 27 Feb 2019 17:14:17 +0000 (UTC)
Received: from madhat.home.dicksonnet.net (ovpn-118-12.phx2.redhat.com [10.3.118.12])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 5F1E26B8CD;
        Wed, 27 Feb 2019 17:14:17 +0000 (UTC)
Subject: Re: [PATCH 1/3] configure.ac: more carefully detect availability of
 res_querydomain(3)
To:     Patrick Steinhardt <ps@pks.im>, linux-nfs@vger.kernel.org
References: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <01523a34-5c3b-383a-a532-cb9bc0f4af8f@RedHat.com>
Date:   Wed, 27 Feb 2019 12:14:16 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 27 Feb 2019 17:14:18 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 2/4/19 9:31 AM, Patrick Steinhardt wrote:
> Since glibc 2.2, the function res_querydomain(3) is implemented as a
> define to `__res_querydomain`. Due to this implementation detail, using
> `AC_CHECK_LIB` with a symbol name of "res_querydomain" will cause a
> linking failure and thus fail to detect its availability. This is why
> right now, we try to detect availability of `__res_querydomain` instead.
> 
> Unfortunately, this may break on other platforms where there is no
> `__res_querydomain` but only the function without leading underscores.
> To fix this, we can perform another `AC_CHECK_LIB([resolv],
> [res_querydomain], ...)` call in case where the other one was not found
> and only raise an error if both symbols weren't found.
> 
> Signed-off-by: Patrick Steinhardt <ps@pks.im>
Committed...

steved.
> ---
>  configure.ac | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/configure.ac b/configure.ac
> index 4bf5aea..cb9d921 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -411,7 +411,8 @@ if test "$enable_gss" = yes; then
>  fi
>  
>  dnl libdnsidmap specific checks
> -AC_CHECK_LIB([resolv], [__res_querydomain], , AC_MSG_ERROR(res_querydomain needed))
> +AC_CHECK_LIB([resolv], [__res_querydomain], ,
> +	AC_CHECK_LIB([resolv], [res_querydomain], , AC_MSG_ERROR(res_querydomain needed)))
>  
>  AC_ARG_ENABLE([ldap],
>  	[AS_HELP_STRING([--disable-ldap],[Disable support for LDAP @<:default=detect@:>@])])
> 
