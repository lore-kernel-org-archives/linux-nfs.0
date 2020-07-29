Return-Path: <SRS0=tL+H=BI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,NICE_REPLY_A,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FD08C433DF
	for <linux-nfs@archiver.kernel.org>; Wed, 29 Jul 2020 14:20:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3D07D207E8
	for <linux-nfs@archiver.kernel.org>; Wed, 29 Jul 2020 14:20:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="KnK3amuW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726449AbgG2OUW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 29 Jul 2020 10:20:22 -0400
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:55306 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726353AbgG2OUW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jul 2020 10:20:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1596032421;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=NMkL/6blYaWQaoMebRmm4e1fbM39u2c/NhNZg49MEyg=;
        b=KnK3amuWWNX7TCNNByQNUxzvTmgXnD3sePPFGMafb7D6yY66LoNi8E1QWIQBnqgV4tGS8h
        Ej5ZEjeWutLDdIcsR4St8sRLRWDV2T5KKHbC3FwWrjIrfmLJOXLc2faf3oPpLALfsb7anh
        jElRz1866tncAl+XEcwuXObMcAdTCIg=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-385-F5hD6U4FPT-YaFmCtBSZvQ-1; Wed, 29 Jul 2020 10:20:18 -0400
X-MC-Unique: F5hD6U4FPT-YaFmCtBSZvQ-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 5673A80047C;
        Wed, 29 Jul 2020 14:20:17 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-113-147.phx2.redhat.com [10.3.113.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id BC4B919C71;
        Wed, 29 Jul 2020 14:20:16 +0000 (UTC)
Subject: Re: [PATCH 2/5] svc: Batch allocations of pollfds
To:     Doug Nazar <nazard@nazar.ca>, libtirpc-devel@lists.sourceforge.net
Cc:     linux-nfs@vger.kernel.org
References: <20200722053445.27987-1-nazard@nazar.ca>
 <20200722053445.27987-3-nazard@nazar.ca>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <fc8ebe17-7e16-6be5-2323-6111a393510e@RedHat.com>
Date:   Wed, 29 Jul 2020 10:20:16 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <20200722053445.27987-3-nazard@nazar.ca>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 7/22/20 1:34 AM, Doug Nazar wrote:
> Signed-off-by: Doug Nazar <nazard@nazar.ca>
> ---
>  src/svc.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/src/svc.c b/src/svc.c
> index 6db164b..57f7ba3 100644
> --- a/src/svc.c
> +++ b/src/svc.c
> @@ -54,6 +54,7 @@
>  #include "rpc_com.h"
>  
>  #define	RQCRED_SIZE	400	/* this size is excessive */
> +#define	SVC_POLLFD_INCREMENT	16
>  
>  #define max(a, b) (a > b ? a : b)
>  
> @@ -107,6 +108,7 @@ xprt_register (xprt)
>    if (sock < _rpc_dtablesize())
>      {
>        int i;
> +      size_t size;
>        struct pollfd *new_svc_pollfd;
>  
>        __svc_xports[sock] = xprt;
> @@ -126,17 +128,17 @@ xprt_register (xprt)
>              goto unlock;
>            }
>  
> -      new_svc_pollfd = (struct pollfd *) realloc (svc_pollfd,
> -                                                  sizeof (struct pollfd)
> -                                                  * (svc_max_pollfd + 1));
> +      size = sizeof (struct pollfd) * (svc_max_pollfd + SVC_POLLFD_INCREMENT);
> +      new_svc_pollfd = (struct pollfd *) realloc (svc_pollfd, size);
>        if (new_svc_pollfd == NULL) /* Out of memory */
>          goto unlock;
>        svc_pollfd = new_svc_pollfd;
> -      ++svc_max_pollfd;
> +      svc_max_pollfd += SVC_POLLFD_INCREMENT;
>  
> -      svc_pollfd[svc_max_pollfd - 1].fd = sock;
> -      svc_pollfd[svc_max_pollfd - 1].events = (POLLIN | POLLPRI |
> -                                               POLLRDNORM | POLLRDBAND);
> +      svc_pollfd[i].fd = sock;
> +      svc_pollfd[i].events = (POLLIN | POLLPRI | POLLRDNORM | POLLRDBAND);
> +      for (++i; i < svc_max_pollfd; ++i)
> +        svc_pollfd[i].fd = -1;
>      }
>  unlock:
>    rwlock_unlock (&svc_fd_lock);
> 
Just curious as why batch allocations are need? What problem does it solve?

steved.

