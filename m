Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F061CC433F5
	for <linux-nfs@archiver.kernel.org>; Thu, 23 Sep 2021 16:33:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C325F60F48
	for <linux-nfs@archiver.kernel.org>; Thu, 23 Sep 2021 16:33:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229913AbhIWQe7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 23 Sep 2021 12:34:59 -0400
Received: from us-smtp-delivery-124.mimecast.com ([170.10.133.124]:40433 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S229523AbhIWQe5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2021 12:34:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1632414805;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=4RXdXrxyptnL24gu+4oyO5DctCje0Fvz+bRbp7JVEpU=;
        b=gAiYutdZF2d0jRJXlxZv/kEW5tBrFgxoY6CdOoX4eWgUtzJqLRwV6C4L0jqs9A2QlCXrH2
        f0M9qVS3iP9zAhww/ezTZ/aBfTHVCsuKSQWQkVa6Ftv9h/HmbqpWrlWwRwSeQcNHEGCPkV
        KUZkP23ke/UOehkKiU7YdzUA7spRNc0=
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com
 [209.85.160.197]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-270-pnqVkKOjPa-KgcAHFibI2Q-1; Thu, 23 Sep 2021 12:33:24 -0400
X-MC-Unique: pnqVkKOjPa-KgcAHFibI2Q-1
Received: by mail-qt1-f197.google.com with SMTP id f34-20020a05622a1a2200b0029c338949c1so17843917qtb.8
        for <linux-nfs@vger.kernel.org>; Thu, 23 Sep 2021 09:33:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=4RXdXrxyptnL24gu+4oyO5DctCje0Fvz+bRbp7JVEpU=;
        b=kcuipFoXlBWvinYEbvi52H8H0zO69fIroHTOYtrsRBCKCfj75+WwEl3mXkH4q+TvgT
         uc84JtUXQHWQKJiD+VNvXwpKcpxJ9VF2IX1sQ13vCIR7Mws6SQHPAFWTBxRDpthl6Q2/
         fx6MwXGu8UdB8crH5Cb8xMxw/AOBv6MpIKqVwguUpb5Y0Zt3ee1uwf6fJ+eTog1BPn+G
         lZY1BHmxIQdomDA20Qxnh/X1ve/3T/wA5tyTIUpcaXKR4BDbpC/8Y/ov1kPmn6WJdVpE
         7w0fBa+bNbTzWPNN/7s3q4RTaQOXiQRImXbUfBFo8eNq/85WJ5Ay3sK1F6MAvViNWluE
         9noA==
X-Gm-Message-State: AOAM533BJ4/SS1v5CnVJjZBIMncvXBeZiKM7Tlhj2RXmVB/9A0K88ZPq
        6kQfe9INkgapKh1RCkUOeclhbcbf7WqDyNNQxGHO+Z9o4CbyBhpAy4GLgVhQtTo5sY0JZPDFTwM
        GrDLwKXJcZoJduVG2y7uu
X-Received: by 2002:a0c:c286:: with SMTP id b6mr5387600qvi.9.1632414804320;
        Thu, 23 Sep 2021 09:33:24 -0700 (PDT)
X-Google-Smtp-Source: ABdhPJwbU0wBWH0y1X4Osqnck4vmbea35IAEfhly5ilOTUZLDu2JCfehRo8mIKMYko0+y7wIYSkHWg==
X-Received: by 2002:a0c:c286:: with SMTP id b6mr5387586qvi.9.1632414804112;
        Thu, 23 Sep 2021 09:33:24 -0700 (PDT)
Received: from madhat.boston.devel.redhat.com ([70.105.255.190])
        by smtp.gmail.com with ESMTPSA id q12sm4311734qkc.104.2021.09.23.09.33.23
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 23 Sep 2021 09:33:23 -0700 (PDT)
Subject: Re: [PATCH 0/2] Allow to to install systemd generators dependend on
 --with-systemd unit-dir-path location
To:     Salvatore Bonaccorso <carnil@debian.org>, linux-nfs@vger.kernel.org
Cc:     NeilBrown <neilb@suse.de>, Scott Mayhew <smayhew@redhat.com>
References: <20200628191002.136918-1-carnil@debian.org>
From:   Steve Dickson <steved@redhat.com>
Message-ID: <30ab5551-ec05-6de1-8071-f55251ef4e90@redhat.com>
Date:   Thu, 23 Sep 2021 12:33:22 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.11.0
MIME-Version: 1.0
In-Reply-To: <20200628191002.136918-1-carnil@debian.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 6/28/20 3:10 PM, Salvatore Bonaccorso wrote:
> Currently --with-systemd=unit-dir-path would be ignored to install the
> systemd generators and they are unconditionally installed in
> /usr/lib/systemd/system-generators . Distributions installing systemd
> unit files in /lib/systemd/system would though install the
> systemd-generators in /lib/systemd/system-generators.
> 
> Make the installation of the systemd unit generators relative depending
> on the unit-dir-path passed for --with-systemd.
> 
> Salvatore Bonaccorso (2):
>    systemd/Makefile: Drop exlicit setting of unit_dir
>    systemd generators: Install depending on location for systemd unit
>      files
> 
>   systemd/Makefile.am | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
> 
Committed... (tag: nfs-utils-2-5-5-rc3)

In the future, If have not responded in a month please
feel free to ping me... because mostly likely it has
fell off my radar... my apologies for taking so long...

steved.

