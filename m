Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DACFC433E0
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Mar 2021 11:33:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 65D4C64FA8
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Mar 2021 11:33:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232105AbhCLLdM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 12 Mar 2021 06:33:12 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:53537 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S232194AbhCLLdC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Mar 2021 06:33:02 -0500
Received: from [192.168.0.2] (ip5f5aeac2.dynamic.kabel-deutschland.de [95.90.234.194])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        (Authenticated sender: pmenzel)
        by mx.molgen.mpg.de (Postfix) with ESMTPSA id 6C8B9206479CD;
        Fri, 12 Mar 2021 12:33:01 +0100 (CET)
Subject: Re: [PATCH] nfsd: Demote UMH upcall init message from warning- to
 info-level
To:     "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
References: <20210312112840.49517-1-pmenzel@molgen.mpg.de>
From:   Paul Menzel <pmenzel@molgen.mpg.de>
Message-ID: <acd50b86-a200-34bf-5768-e5bb93b2278f@molgen.mpg.de>
Date:   Fri, 12 Mar 2021 12:33:00 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.8.0
MIME-Version: 1.0
In-Reply-To: <20210312112840.49517-1-pmenzel@molgen.mpg.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Dear Linux folks,


Am 12.03.21 um 12:28 schrieb Paul Menzel:
> By default, using `printk()`, Linux logs messages with level warning,
> which leaves the user seeing
> 
>      NFSD: Using UMH upcall client tracking operations.
> 
> what to do about it. Reading `nfsd4_umh_cltrack_init()`, the message is
> actually logged on success, so nothing needs to be done, and the info
> level should be used.
> 
> Cc: linux-nfs@vger.kernel.org
> Signed-off-by: Paul Menzel <pmenzel@molgen.mpg.de>
> ---
>   fs/nfsd/nfs4recover.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 891395c6c7d3..db66c45a6b97 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -1864,7 +1864,7 @@ nfsd4_umh_cltrack_init(struct net *net)
>   	ret = nfsd4_umh_cltrack_upcall("init", NULL, grace_start, NULL);
>   	kfree(grace_start);
>   	if (!ret)
> -		printk("NFSD: Using UMH upcall client tracking operations.\n");
> +		pr_info("NFSD: Using UMH upcall client tracking operations.\n");
>   	return ret;
>   }

A debug-level message could also be used, or the line totally removed, 
and the condition be changed to print an error in case of failure. I am 
wondering about the benefit for the user reading through the logs. Maybe 
the log was only there, because UMH upcall client tracking operations 
were something new?


Kind regards,

Paul
