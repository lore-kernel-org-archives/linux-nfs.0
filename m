Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,NICE_REPLY_A,
	SPF_HELO_NONE,SPF_PASS,URI_NOVOWEL,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E271C433E6
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Mar 2021 19:36:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5D19E64F4B
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Mar 2021 19:36:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229901AbhCOTgZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Mar 2021 15:36:25 -0400
Received: from us-smtp-delivery-124.mimecast.com ([63.128.21.124]:57807 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S232684AbhCOTgF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2021 15:36:05 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1615836965;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=3c0hp+YHodqvofOQbKB25YJOI+avrM7aGW35ZHNirLY=;
        b=gzWCYWbSDyhW4UCGTlbqF0X9b4fi2INl+CfQUOr11wTX1zieD14PV6WG4UbJwVh/hmUksf
        nAxOiIcOCsx5PFTjE6NVXiso6ZanjvkXUO/ke4Vvg83/lXsiybh5Q4A3tkfc6SZ4cz/5dz
        TgcX8OblWIw4niMwpwaTprF/PvZ/zdQ=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-266-3lKMLTkvN8W-GlI1gqX-3A-1; Mon, 15 Mar 2021 15:36:01 -0400
X-MC-Unique: 3lKMLTkvN8W-GlI1gqX-3A-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 5C2B2107ACCA;
        Mon, 15 Mar 2021 19:36:00 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-113-124.phx2.redhat.com [10.3.113.124])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 14BF0608BA;
        Mon, 15 Mar 2021 19:36:00 +0000 (UTC)
Subject: Re: [PATCH] nfsdclnts: Ignore SIGPIPE signal
To:     Kenneth D'souza <kennethdsouza94@gmail.com>,
        linux-nfs@vger.kernel.org
References: <20210308120157.36053-1-kennethdsouza94@gmail.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <90aaf999-7b7d-fd17-3069-3c597a9bb9b0@RedHat.com>
Date:   Mon, 15 Mar 2021 15:37:48 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.8.0
MIME-Version: 1.0
In-Reply-To: <20210308120157.36053-1-kennethdsouza94@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 3/8/21 7:01 AM, Kenneth D'souza wrote:
> Fixes (RhBug: 1868828)
> 
> Signed-off-by: Kenneth D'souza <kennethdsouza94@gmail.com>
Committed... (tag: nfs-utils-2-5-4-rc1)

steved.
> ---
>  tools/nfsdclnts/nfsdclnts.py | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/tools/nfsdclnts/nfsdclnts.py b/tools/nfsdclnts/nfsdclnts.py
> index 5e7e03c2..b7280f2c 100755
> --- a/tools/nfsdclnts/nfsdclnts.py
> +++ b/tools/nfsdclnts/nfsdclnts.py
> @@ -223,6 +223,7 @@ def nfsd4_show():
>  
>      global verbose
>      verbose = False
> +    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
>      if args.verbose:
>          verbose = True
>  
> 

