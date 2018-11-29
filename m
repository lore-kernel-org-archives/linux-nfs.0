Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88924C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 18:46:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 587DD20868
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 18:46:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 587DD20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726512AbeK3Fwd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 00:52:33 -0500
Received: from mx1.redhat.com ([209.132.183.28]:34674 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726044AbeK3Fwd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 00:52:33 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 624003084026;
        Thu, 29 Nov 2018 18:46:13 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 15E68679E4;
        Thu, 29 Nov 2018 18:46:13 +0000 (UTC)
Subject: Re: [PATCH v1 1/3] Fix quoting in configure.ac
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
References: <20181031200218.7507.15214.stgit@klimt.1015granger.net>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <2d71fb1b-d0dc-df8e-f201-0badd56d9244@RedHat.com>
Date:   Thu, 29 Nov 2018 13:46:12 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20181031200218.7507.15214.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 29 Nov 2018 18:46:13 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 10/31/18 4:02 PM, Chuck Lever wrote:
> Replace an unmatched single quote to help syntax coloring editors.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  configure.ac |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/configure.ac b/configure.ac
> index cf1c4b9..16eae06 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -165,7 +165,7 @@ AC_ARG_ENABLE(uuid,
>  	choose_blkid=default)
>  AC_ARG_ENABLE(mount,
>  	[AC_HELP_STRING([--disable-mount],
> -		[Don't build mount.nfs and do use the util-linux mount(8) functionality. @<:@default=no@:>@])],
> +		[Do not build mount.nfs and do use the util-linux mount(8) functionality. @<:@default=no@:>@])],
>  	enable_mount=$enableval,
>  	enable_mount=yes)
>  	AM_CONDITIONAL(CONFIG_MOUNT, [test "$enable_mount" = "yes"])
> 
All three patches committed.... 

steved.
