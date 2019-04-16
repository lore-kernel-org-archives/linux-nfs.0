Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 044F0C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 18:27:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CF9792075B
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 18:27:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727224AbfDPS1u (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 14:27:50 -0400
Received: from mx1.redhat.com ([209.132.183.28]:33648 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727136AbfDPS1u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Apr 2019 14:27:50 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 19404F74B9;
        Tue, 16 Apr 2019 18:27:50 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-117-181.phx2.redhat.com [10.3.117.181])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C43E519C71;
        Tue, 16 Apr 2019 18:27:49 +0000 (UTC)
Subject: Re: [PATCH] idmapd: Add missing libgen header
To:     Rosen Penev <rosenp@gmail.com>, linux-nfs@vger.kernel.org
References: <20190415021140.1388-1-rosenp@gmail.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <4acaf198-e301-807e-e6e8-b8cd0aafeb3f@RedHat.com>
Date:   Tue, 16 Apr 2019 14:27:49 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190415021140.1388-1-rosenp@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 16 Apr 2019 18:27:50 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 4/14/19 10:11 PM, Rosen Penev wrote:
> Otherwise compilation can fail with an implicit declaration of basename.
> 
> Signed-off-by: Rosen Penev <rosenp@gmail.com>
Committed... 

steved.

> ---
>  utils/idmapd/idmapd.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index 91c0253..62e37b8 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -59,6 +59,7 @@
>  #include <grp.h>
>  #include <limits.h>
>  #include <ctype.h>
> +#include <libgen.h>
>  #include <nfsidmap.h>
>  
>  #ifdef HAVE_CONFIG_H
> 
