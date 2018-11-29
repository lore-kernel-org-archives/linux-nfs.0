Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAAB4C43610
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 20:01:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7EFA721104
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 20:01:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EFA721104
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726333AbeK3HHf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 02:07:35 -0500
Received: from mx1.redhat.com ([209.132.183.28]:52356 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725871AbeK3HHf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 02:07:35 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8B1E93F75C;
        Thu, 29 Nov 2018 20:01:00 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 3F446105705A;
        Thu, 29 Nov 2018 20:01:00 +0000 (UTC)
Subject: Re: [PATCH 1/2] nfs-utils: configure.ac: Fix --with-rpcgen=internal
 nottaking effect.
To:     Yang Bo <phoooyb@gmail.com>, linux-nfs@vger.kernel.org
References: <5be145a0.1c69fb81.9f722.e02a@mx.google.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <449e4151-52a0-9aa2-e870-6ce0d67fc347@RedHat.com>
Date:   Thu, 29 Nov 2018 15:00:59 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <5be145a0.1c69fb81.9f722.e02a@mx.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 29 Nov 2018 20:01:00 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 11/6/18 2:41 AM, Yang Bo wrote:
> Signed-off-by: Yang Bo <rslovers@yandex.com>
Committed... Boy I didn't think the internal rpcgen
was being used or could be used ;-) 

Thanks for the patches!

steved. 
> ---
>  configure.ac | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/configure.ac b/configure.ac
> index cf1c4b9..3caeebc 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -155,6 +155,8 @@ AC_ARG_WITH(rpcgen,
>  	    do if test -f $p ; then RPCGEN_PATH=$p ; break; fi ; done
>  	elif test "$rpcgen_path" != "internal"; then
>  	    RPCGEN_PATH=$rpcgen_path
> +	else
> +	    RPCGEN_PATH=internal
>  	fi
>  	AC_SUBST(RPCGEN_PATH)
>  	AM_CONDITIONAL(CONFIG_RPCGEN, [test "$RPCGEN_PATH" = "internal"])
> 
