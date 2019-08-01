Return-Path: <SRS0=JCn4=V5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC233C433FF
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Aug 2019 16:21:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7BA79205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Aug 2019 16:21:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727198AbfHAQV3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Aug 2019 12:21:29 -0400
Received: from mx1.redhat.com ([209.132.183.28]:48332 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727024AbfHAQV2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Aug 2019 12:21:28 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8C44830BFEE3
        for <linux-nfs@vger.kernel.org>; Thu,  1 Aug 2019 16:21:27 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-117-78.phx2.redhat.com [10.3.117.78])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 98A245C207;
        Thu,  1 Aug 2019 16:21:21 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: Fix the error handling if the lseek fails
To:     Alice J Mitchell <ajmitchell@redhat.com>, linux-nfs@vger.kernel.org
References: <1564666361.8625.10.camel@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <76b68650-1a20-4fb0-6972-f0780d4b82f6@RedHat.com>
Date:   Thu, 1 Aug 2019 12:21:18 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1564666361.8625.10.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 01 Aug 2019 16:21:28 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 8/1/19 9:32 AM, Alice J Mitchell wrote:
> The error case when lseek returns a negative value was not correctly handled,
> and the error cleanup routine was potentially leaking memory also.
> 
> Signed-off-by: Alice J Mitchell <ajmitchell@redhat.com>
Committed... 

steved.

> ---
>  support/nfs/conffile.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index b6400be..6ba8a35 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -500,7 +500,7 @@ conf_readfile(const char *path)
>  
>  	if ((stat (path, &sb) == 0) || (errno != ENOENT)) {
>  		char *new_conf_addr = NULL;
> -		size_t sz = sb.st_size;
> +		off_t sz;
>  		int fd = open (path, O_RDONLY, 0);
>  
>  		if (fd == -1) {
> @@ -517,6 +517,11 @@ conf_readfile(const char *path)
>  
>  		/* only after we have the lock, check the file size ready to read it */
>  		sz = lseek(fd, 0, SEEK_END);
> +		if (sz < 0) {
> +			xlog_warn("conf_readfile: unable to determine file size: %s",
> +				  strerror(errno));
> +			goto fail;
> +		}
>  		lseek(fd, 0, SEEK_SET);
>  
>  		new_conf_addr = malloc(sz+1);
> @@ -2162,6 +2167,7 @@ conf_write(const char *filename, const char *section, const char *arg,
>  	ret = 0;
>  
>  cleanup:
> +	flush_outqueue(&inqueue, NULL);
>  	flush_outqueue(&outqueue, NULL);
>  
>  	if (buff)
> 
