Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0E84C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 19:49:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 975FF21019
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 19:49:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 975FF21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726019AbeK3G4J (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 01:56:09 -0500
Received: from mx1.redhat.com ([209.132.183.28]:35176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725871AbeK3G4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 01:56:09 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DE13F792BA;
        Thu, 29 Nov 2018 19:49:36 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 93FDE1716D;
        Thu, 29 Nov 2018 19:49:36 +0000 (UTC)
Subject: Re: [PATCH] [nfs-utils] mount: improve error msg when mount fail wirh
 EBUSY
To:     "Jianhong.Yin" <yin-jianhong@163.com>
Cc:     linux-nfs@vger.kernel.org
References: <20181025045400.24997-1-yin-jianhong@163.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <77fe8d1f-412e-e3d6-1f93-c0c63cfbec00@RedHat.com>
Date:   Thu, 29 Nov 2018 14:49:36 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20181025045400.24997-1-yin-jianhong@163.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 29 Nov 2018 19:49:36 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 10/25/18 12:54 AM, Jianhong.Yin wrote:
> EBUSY can happen when mounting a filesystem that
> is already mounted or when the context= are
> different when using the -o sharecache
> 
> so update the error message from to:
> - %mountpoint% is busy or already mounted
> + %mountpoint% is busy or already mounted or sharecache fail
> 
> Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
Committed.... 

steved.

> ---
>  utils/mount/error.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/mount/error.c b/utils/mount/error.c
> index c9797fc..dfe5c7d 100644
> --- a/utils/mount/error.c
> +++ b/utils/mount/error.c
> @@ -223,7 +223,7 @@ void mount_error(const char *spec, const char *mount_point, int error)
>  				  progname, mount_point);
>  		break;
>  	case EBUSY:
> -		nfs_error(_("%s: %s is busy or already mounted"),
> +		nfs_error(_("%s: %s is busy or already mounted or sharecache fail"),
>  			progname, mount_point);
>  		break;
>  	case ENOENT:
> -- 2.17.2
> 
