Return-Path: <SRS0=/R4e=QG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EC15C282D7
	for <linux-nfs@archiver.kernel.org>; Wed, 30 Jan 2019 19:05:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 230EE2087F
	for <linux-nfs@archiver.kernel.org>; Wed, 30 Jan 2019 19:05:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733291AbfA3TFa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 30 Jan 2019 14:05:30 -0500
Received: from mx1.redhat.com ([209.132.183.28]:33060 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727760AbfA3TF3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Jan 2019 14:05:29 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C72493D966
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2019 19:05:29 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-222.phx2.redhat.com [10.3.116.222])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 8B5FE10021B2
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2019 19:05:29 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: Removed new error=format-overflow=2 errors
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20190129203459.38815-1-steved@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <35c2d012-e8c0-2476-f706-65307397212f@RedHat.com>
Date:   Wed, 30 Jan 2019 14:05:28 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129203459.38815-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 30 Jan 2019 19:05:29 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 1/29/19 3:34 PM, Steve Dickson wrote:
> With the latest C99-compliant gcc printf, sprintf, etc
> now only support up to 4k in buffer sizes. There were
> only a couple places that had to change to not
> violated this new restriction
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed.... 

steved.

> ---
>  utils/blkmapd/device-discovery.c | 2 +-
>  utils/mount/error.c              | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> index 3a202e0..2ce60f8 100644
> --- a/utils/blkmapd/device-discovery.c
> +++ b/utils/blkmapd/device-discovery.c
> @@ -239,7 +239,7 @@ int bl_discover_devices(void)
>  {
>  	FILE *f;
>  	int n;
> -	char buf[PATH_MAX], devname[PATH_MAX], fulldevname[PATH_MAX+NAME_MAX];
> +	char buf[PATH_MAX], devname[NAME_MAX], fulldevname[PATH_MAX];
>  
>  	/* release previous list */
>  	bl_release_disk();
> diff --git a/utils/mount/error.c b/utils/mount/error.c
> index dfe5c7d..562f312 100644
> --- a/utils/mount/error.c
> +++ b/utils/mount/error.c
> @@ -50,8 +50,8 @@
>  
>  extern char *progname;
>  
> -static char errbuf[BUFSIZ];
> -static char *erreob = &errbuf[BUFSIZ];
> +static char errbuf[PATH_MAX];
> +static char *erreob = &errbuf[PATH_MAX];
>  
>  /* Convert RPC errors into strings */
>  static int rpc_strerror(int spos)
> 
