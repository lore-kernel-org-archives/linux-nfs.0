Return-Path: <SRS0=fB6X=RY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72CC6C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 16:02:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 48C3A21874
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 16:02:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728013AbfCUQCd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Mar 2019 12:02:33 -0400
Received: from mx1.redhat.com ([209.132.183.28]:60882 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725985AbfCUQCd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Mar 2019 12:02:33 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2FC6385362;
        Thu, 21 Mar 2019 16:02:33 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (madhat.boston.devel.redhat.com [10.19.60.33])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DD43F19C57;
        Thu, 21 Mar 2019 16:02:32 +0000 (UTC)
Subject: Re: Check that an RPC compiler has been installed
To:     Richard Sharpe <realrichardsharpe@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <CACyXjPx84Y9jwrAQzvhjDz2jH8aZnx8MsvJjQvW9FzDfZy0HCQ@mail.gmail.com>
 <CACyXjPx0oxRhKiSm1AJU9pQ27FEMHYuAnhfLO_NSV20fQVgmyA@mail.gmail.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <3e063650-fbe6-a7b9-4222-47f4374af554@RedHat.com>
Date:   Thu, 21 Mar 2019 12:02:31 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <CACyXjPx0oxRhKiSm1AJU9pQ27FEMHYuAnhfLO_NSV20fQVgmyA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 21 Mar 2019 16:02:33 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 3/7/19 10:01 AM, Richard Sharpe wrote:
> On Wed, Mar 6, 2019 at 5:17 PM Richard Sharpe
> <realrichardsharpe@gmail.com> wrote:
>>
>> When I installed Fedora-29 to check out building on Fedora I didn't
>> have rpcgen installed.
>>
>> autogen worked and configure worked but make failed in spectacular ways.
>>
>> The attached patch warns the user during configure but is perhaps not
>> the correct test, because of rpcgen is on your path but not where the
>> earlier tests expect it, things will still likely fail.
> 
> Here is a better version. Since we already know we didn't find rpcgen,
> just let the user know.
> 
> Tested by uninstalling rpcgen.
Committed.... 

Sorry for taking so long but there was no [PATCH] in the
subject line so I missed it... 

The format of looks good except there is no Signed-off-by
line... just use the -s flag on the commit. 

Try using git send-email to post patches... It
will do the right thing. 

steved.
> 
> From 6caea95ccebb5d3635b3d1c91e8683954fe61645 Mon Sep 17 00:00:00 2001
> From: root <realrichardsharpe@gmail.com>
> Date: Wed, 6 Mar 2019 19:51:12 -0500
> Subject: [PATCH] If we don't find rpcgen let the user know about it rather
>  than getting an error later during make.
> 
> ---
>  configure.ac | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/configure.ac b/configure.ac
> index cb9d921..b23bb6a 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -154,6 +154,9 @@ AC_ARG_WITH(rpcgen,
>         if test "$rpcgen_path" = "yes"; then
>             for p in /usr/local/bin/rpcgen /usr/bin/rpcgen /bin/rpcgen
>             do if test -f $p ; then RPCGEN_PATH=$p ; break; fi ; done
> +           if test -z "$RPCGEN_PATH"; then
> +                AC_MSG_ERROR([Please install rpcgen or use --with-rpcgen])
> +           fi
>         elif test "$rpcgen_path" != "internal"; then
>             RPCGEN_PATH=$rpcgen_path
>         else
> --
> 2.19.1
> 
> 
> 
