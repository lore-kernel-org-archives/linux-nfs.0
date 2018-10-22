Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51F66C67863
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 14:58:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0B1A720645
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 14:58:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B1A720645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728126AbeJVXQy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 19:16:54 -0400
Received: from mx1.redhat.com ([209.132.183.28]:40192 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727669AbeJVXQy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Oct 2018 19:16:54 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 340EC99CEB
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2018 14:58:00 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-120-63.rdu2.redhat.com [10.10.120.63])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E58577011B
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2018 14:57:59 +0000 (UTC)
Subject: Re: [PATCH] mount.nfs: Only ignore EBUSY when a filesystem is already
 mount
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20181020145347.134233-1-steved@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <adc626f5-cc47-d4fc-6062-042ff0aec905@RedHat.com>
Date:   Mon, 22 Oct 2018 10:57:59 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20181020145347.134233-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 22 Oct 2018 14:58:00 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 10/20/18 10:53 AM, Steve Dickson wrote:
> EBUSY errors can be caused by using the -o sharecache
> flag and different context= values. So make sure
> the filesytem is mounted before ignoring the EBUSY error.
> 
> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1629705
> 
> Found-by: Jianhong.Yin <yin-jianhong@163.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/mount/Makefile.am |  1 +
>  utils/mount/stropts.c   | 16 ++++++++++------
>  2 files changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
> index 7b97c31..ad0be93 100644
> --- a/utils/mount/Makefile.am
> +++ b/utils/mount/Makefile.am
> @@ -27,6 +27,7 @@ endif
>  
>  mount_nfs_LDADD = ../../support/nfs/libnfs.la \
>  		  ../../support/export/libexport.a \
> +		  ../../support/misc/libmisc.a \
>  		  $(LIBTIRPC)
>  
>  mount_nfs_SOURCES = $(mount_common)
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 4d2e37e..eed0356 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -48,6 +48,7 @@
>  #include "version.h"
>  #include "parse_dev.h"
>  #include "conffile.h"
> +#include "misc.h"
>  
>  #ifndef NFS_PROGRAM
>  #define NFS_PROGRAM	(100003)
> @@ -1078,12 +1079,15 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>  		if (nfs_try_mount(mi))
>  			return EX_SUCCESS;
>  
> -		if (errno == EBUSY)
> -			/* The only cause of EBUSY is if exactly the desired
> -			 * filesystem is already mounted.  That can arguably
> -			 * be seen as success.  "mount -a" tries to optimise
> -			 * out this case but sometimes fails.  Help it out
> -			 * by pretending everything is rosy
> +#pragma GCC diagnostic ignored "-Wdiscarded-qualifiers"
> +		if (errno == EBUSY && is_mountpoint(mi->node))
> +#pragma GCC diagnostic warning "-Wdiscarded-qualifiers"
> +			/*
> +			 * EBUSY can happen when mounting a filesystem that
> +			 * is already mounted or when the context= are
> +			 * different when using the -o sharecache
> +			 *
> +			 * Only error out in the latter case.
>  			 */
>  			return EX_SUCCESS;
>  
> 
