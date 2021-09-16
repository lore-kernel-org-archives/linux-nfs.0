Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0859C433FE
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Sep 2021 22:03:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 93F3D60F6E
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Sep 2021 22:03:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240647AbhIPWEo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Sep 2021 18:04:44 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39334 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S240632AbhIPWEn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Sep 2021 18:04:43 -0400
Received: from mail-pf1-x430.google.com (mail-pf1-x430.google.com [IPv6:2607:f8b0:4864:20::430])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 84E60C061766
        for <linux-nfs@vger.kernel.org>; Thu, 16 Sep 2021 15:03:22 -0700 (PDT)
Received: by mail-pf1-x430.google.com with SMTP id e16so7252949pfc.6
        for <linux-nfs@vger.kernel.org>; Thu, 16 Sep 2021 15:03:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=4stWjV+988moSr8o995OIf8ggHEv0wfGWBUivSMtLdE=;
        b=P4NV3mSxnseSsUwN1r4NRyp6pr/mGZacESSUAMJ4OA+ZSrKJezFJJLBTBqIGE5zj29
         fGLa8Iljpr3nqHZTQFQp8l5bvDwsrhpN+vnIpX//X5XzvsLhDyiRXqjCRtt+6PGG5T2A
         2/1o6jaBirRCA+eTm6GobnrXmpuh83bdlbabE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=4stWjV+988moSr8o995OIf8ggHEv0wfGWBUivSMtLdE=;
        b=5x6zNl7EV+EVR96pVpWHEWj4IBRSi4eYc5+aAI6EmfeAqMx92Pqas4JJdqa2PdrpKg
         1jkDGTM/zpeFdXHlJJt1xdR498qr4VhDj65/4XmKpqMxod9wUp4wp8Aio5/ggyPW5cE6
         2EDnoCHHy7YQVok41opAWDk2hIZCZd3utEYe5Epv7/gFzE92R2SD5WUrws930iAyc/My
         YH84wAhHpT+eNKNO5jfsAau8KZUYw+9ks+d8pjDPQ2XJR4758vImsU3qNtunyaCcxbt9
         Jjtl1ie1rsUTCcK6FuO59aOqmtQ/Wc6WHDTqzlqpfxbgdgkX90vSmn1jyYpn5wwgGq51
         Auiw==
X-Gm-Message-State: AOAM533sECe8XXquvJ6cCuga5BAwsqQKYJb0baztZWSaKnDMm9GQVgRA
        pms5Ry2xR7TXwmYavcwy1uKgdg==
X-Google-Smtp-Source: ABdhPJzByTUQfNUTQXxfAdKQO1SbJaWR9nrJXL7Z5u9uxynbmpO0acSoreFm30VnzwHjGd5cvjNgCw==
X-Received: by 2002:a63:5c1b:: with SMTP id q27mr6786249pgb.284.1631829801905;
        Thu, 16 Sep 2021 15:03:21 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id z11sm4184633pff.144.2021.09.16.15.03.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 16 Sep 2021 15:03:21 -0700 (PDT)
Date:   Thu, 16 Sep 2021 15:03:20 -0700
From:   Kees Cook <keescook@chromium.org>
To:     Thomas Huth <thuth@redhat.com>
Cc:     linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Luis Chamberlain <mcgrof@kernel.org>,
        Iurii Zaikin <yzaikin@google.com>, linux-s390@vger.kernel.org,
        Jia He <hejianet@gmail.com>,
        Pan Xinhui <xinhui.pan@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] sysctl: introduce new proc handler proc_dobool
Message-ID: <202109161502.7B79ED57F@keescook>
References: <20210803105937.52052-1-thuth@redhat.com>
 <20210803105937.52052-2-thuth@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210803105937.52052-2-thuth@redhat.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Aug 03, 2021 at 12:59:36PM +0200, Thomas Huth wrote:
> From: Jia He <hejianet@gmail.com>
> 
> This is to let bool variable could be correctly displayed in
> big/little endian sysctl procfs. sizeof(bool) is arch dependent,
> proc_dobool should work in all arches.
> 
> Suggested-by: Pan Xinhui <xinhui@linux.vnet.ibm.com>
> Signed-off-by: Jia He <hejianet@gmail.com>

Hi! I apologize for the delay. Yes, this looks good to me; thanks!

Acked-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
