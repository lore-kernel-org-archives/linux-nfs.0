Return-Path: <SRS0=5HTL=2Y=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15F4FC2D0C2
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Jan 2020 16:28:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D9A0221734
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Jan 2020 16:28:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Btkpvo8A"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727912AbgACQ2s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 3 Jan 2020 11:28:48 -0500
Received: from us-smtp-delivery-1.mimecast.com ([205.139.110.120]:53218 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1727905AbgACQ2s (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jan 2020 11:28:48 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1578068926;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=lbsCbTWT7cQqOFjkC5R7xK8kdJ5is+4HSv6VjK+CUcc=;
        b=Btkpvo8AaAzj+zNowgIzV2GgCF7ordt9+8MooEVVWYw5oAjBExKxzteBdln6dcjvg4e/Ai
        flMQ3WVzgUWzlq9JdvDcgg/M4A3vHCV4X3u2xHOcnuSj3YR62CF2IFOa/AzUzpv7wQn37R
        M4vRVFbqBAM12hleG4Q0jL5sclO2QFE=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-314-Da8rCZHMOXaoAKIp52nUqA-1; Fri, 03 Jan 2020 11:28:42 -0500
X-MC-Unique: Da8rCZHMOXaoAKIp52nUqA-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id A09088A20A0;
        Fri,  3 Jan 2020 16:28:41 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-116-81.phx2.redhat.com [10.3.116.81])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 5949A60BF7;
        Fri,  3 Jan 2020 16:28:41 +0000 (UTC)
Subject: Re: [PATCH] gssd: Use setgroups32 syscall, if available.
 BUG:FIXED:340
To:     Markus Schaaf <markuschaaf@gmail.com>, linux-nfs@vger.kernel.org
References: <20200101181349.12248-1-markuschaaf@gmail.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <2209f259-c018-c407-8c12-4faccbd08219@RedHat.com>
Date:   Fri, 3 Jan 2020 11:28:40 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.2.2
MIME-Version: 1.0
In-Reply-To: <20200101181349.12248-1-markuschaaf@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 1/1/20 1:13 PM, Markus Schaaf wrote:
> This closes a bug on older 32-bit platforms, where the 16-bit setgroups
> syscall has been replaced by setgroups32 and is not available anymore.
> 
> Signed-off-by: Markus Schaaf <markuschaaf@gmail.com>
Committed... (tag nfs-utils-2-4-3-rc4)

> 
> (Personal note: Reporting a trivial bug and getting a fix upstream in
> nfs-utils is like running the gauntlet, for the uninitiated average user.)
I'm sorry this was a "gauntlet"... but I simply can not take patches that
are only posted in the bz... More eyes are better than my eyes! :-) 

Please feel free to ping me privately if the process is becoming a 
pain... I'll more that willing to work with you to smooth things out.

steved.

> 
> BR
> 
> ---
>  utils/gssd/gssd_proc.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index bfcf3f09..9ba16af0 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -437,7 +437,11 @@ change_identity(uid_t uid)
>  	int res;
>  
>  	/* drop list of supplimentary groups first */
> +#ifdef __NR_setgroups32
> +	if (syscall(SYS_setgroups32, 0, 0) != 0) {
> +#else
>  	if (syscall(SYS_setgroups, 0, 0) != 0) {
> +#endif
>  		printerr(0, "WARNING: unable to drop supplimentary groups!");
>  		return errno;
>  	}
> 

