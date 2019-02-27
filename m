Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EC01C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 17:14:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3D8A62183F
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 17:14:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729115AbfB0ROk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 12:14:40 -0500
Received: from mx1.redhat.com ([209.132.183.28]:53516 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727636AbfB0ROk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Feb 2019 12:14:40 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9C87B30BC12F;
        Wed, 27 Feb 2019 17:14:40 +0000 (UTC)
Received: from madhat.home.dicksonnet.net (ovpn-118-12.phx2.redhat.com [10.3.118.12])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 51A271001DD6;
        Wed, 27 Feb 2019 17:14:40 +0000 (UTC)
Subject: Re: [PATCH 2/3] file: fix missing include for PATH_MAX constant
To:     Patrick Steinhardt <ps@pks.im>, linux-nfs@vger.kernel.org
References: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
 <b867217d30569b84e098ca013c44e07e1df598fb.1549290423.git.ps@pks.im>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <4ad0a829-fd7f-4829-6334-90d1ed23448f@RedHat.com>
Date:   Wed, 27 Feb 2019 12:14:39 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <b867217d30569b84e098ca013c44e07e1df598fb.1549290423.git.ps@pks.im>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 27 Feb 2019 17:14:40 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 2/4/19 9:31 AM, Patrick Steinhardt wrote:
> While making use of the PATH_MAX constant, "file.c" does not include the
> "limits.h" header. While it is being transitively included via other
> headers on most platforms, it is not on e.g. musl-based systems.
> 
> Add the include to fix compilation.
Committed...

steved. 
> 
> Signed-off-by: Patrick Steinhardt <ps@pks.im>
> ---
>  support/misc/file.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/support/misc/file.c b/support/misc/file.c
> index 4065376..e7c3819 100644
> --- a/support/misc/file.c
> +++ b/support/misc/file.c
> @@ -27,6 +27,7 @@
>  #include <dirent.h>
>  #include <stdlib.h>
>  #include <stdbool.h>
> +#include <limits.h>
>  
>  #include "xlog.h"
>  #include "misc.h"
> 
