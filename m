Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8024BC10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 18:28:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 563702075B
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 18:28:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728108AbfDPS2U (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 14:28:20 -0400
Received: from mx1.redhat.com ([209.132.183.28]:57954 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728032AbfDPS2U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Apr 2019 14:28:20 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 93FA2C13070F;
        Tue, 16 Apr 2019 18:28:20 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-117-181.phx2.redhat.com [10.3.117.181])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4978860C76;
        Tue, 16 Apr 2019 18:28:20 +0000 (UTC)
Subject: Re: [PATCH] mount: Add missing cast to getsockname
To:     Rosen Penev <rosenp@gmail.com>, linux-nfs@vger.kernel.org
References: <20190415020838.924-1-rosenp@gmail.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <ee4c0c64-4a3b-555b-2299-251e1c76774e@RedHat.com>
Date:   Tue, 16 Apr 2019 14:28:19 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190415020838.924-1-rosenp@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 16 Apr 2019 18:28:20 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 4/14/19 10:08 PM, Rosen Penev wrote:
> Otherwise compilation can fail with incompatible pointer type.
> 
> Signed-off-by: Rosen Penev <rosenp@gmail.com>
Committed.... 

steved.

> ---
>  utils/mount/network.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index fc21110..e166a82 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1062,7 +1062,7 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
>  	if (caddr) {
>  		/* Get the address of our end of this connection */
>  		socklen_t len = sizeof(*caddr);
> -		if (getsockname(sock, caddr, &len) != 0)
> +		if (getsockname(sock, (struct sockaddr *) caddr, &len) != 0)
>  			caddr->sin_family = 0;
>  	}
>  
> 
