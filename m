Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CCA5C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 20:01:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 133C321104
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 20:01:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 133C321104
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725883AbeK3HIA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 02:08:00 -0500
Received: from mx1.redhat.com ([209.132.183.28]:59012 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725871AbeK3HIA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 02:08:00 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 610843082190;
        Thu, 29 Nov 2018 20:01:25 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 1B5821712C;
        Thu, 29 Nov 2018 20:01:25 +0000 (UTC)
Subject: Re: [PATCH 2/2] nfs-utils: configure.ac: Do not fatalize
 -Wstrict-prototypes with internal rpcgen.
To:     Yang Bo <phoooyb@gmail.com>, linux-nfs@vger.kernel.org
References: <5be14884.1c69fb81.a6fae.51d4@mx.google.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <cb0346c2-3550-b93c-a74c-4ec4b2579aab@RedHat.com>
Date:   Thu, 29 Nov 2018 15:01:24 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <5be14884.1c69fb81.a6fae.51d4@mx.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 29 Nov 2018 20:01:25 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 11/6/18 2:53 AM, Yang Bo wrote:
> The internal rpcgen is not able to generate -Wstrict-prototypes free code,
> the problematic files are:
> 
> ./tests/nsm_client/nlm_sm_inter_svc.c
> ./support/nsm/sm_inter_svc.c
> 
> Signed-off-by: Yang Bo <rslovers@yandex.com>
Committed....

steved.

> ---
>  configure.ac | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/configure.ac b/configure.ac
> index 3caeebc..ad2985c 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -149,6 +149,7 @@ AC_ARG_WITH(rpcgen,
>  	[AC_HELP_STRING([--with-rpcgen=internal], [use internal rpcgen instead of system one])],
>  	rpcgen_path=$withval,
>  	rpcgen_path=yes )
> +	rpcgen_cflags=-Werror=strict-prototypes
>  	RPCGEN_PATH=
>  	if test "$rpcgen_path" = "yes"; then
>  	    for p in /usr/local/bin/rpcgen /usr/bin/rpcgen /bin/rpcgen
> @@ -157,6 +158,7 @@ AC_ARG_WITH(rpcgen,
>  	    RPCGEN_PATH=$rpcgen_path
>  	else
>  	    RPCGEN_PATH=internal
> +	    rpcgen_cflags=-Wstrict-prototypes
>  	fi
>  	AC_SUBST(RPCGEN_PATH)
>  	AM_CONDITIONAL(CONFIG_RPCGEN, [test "$RPCGEN_PATH" = "internal"])
> @@ -542,7 +544,7 @@ my_am_cflags="\
>   -pipe \
>   -Wall \
>   -Wextra \
> - -Werror=strict-prototypes \
> + $rpcgen_cflags \
>   -Werror=missing-prototypes \
>   -Werror=missing-declarations \
>   -Werror=format=2 \
> 
