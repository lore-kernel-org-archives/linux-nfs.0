Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6453C004D3
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 14:57:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AF2E320645
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 14:57:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF2E320645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727702AbeJVXQ1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 19:16:27 -0400
Received: from mx1.redhat.com ([209.132.183.28]:56158 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727669AbeJVXQ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Oct 2018 19:16:27 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E5AE38830F
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2018 14:57:33 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-120-63.rdu2.redhat.com [10.10.120.63])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 97B1370110
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2018 14:57:33 +0000 (UTC)
Subject: Re: [PATCH] gssd: Introduce use-gss-proxy boolean to nfs.conf
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20181020160329.135824-1-steved@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <0de0414d-8d7e-1a08-386c-8120e9c02d63@RedHat.com>
Date:   Mon, 22 Oct 2018 10:57:32 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20181020160329.135824-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 22 Oct 2018 14:57:33 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 10/20/18 12:03 PM, Steve Dickson wrote:
> Allow the used of the gssprox-mech(8) through a the
> boolean variable in the [gssd] section of nfs.conf
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  nfs.conf             |  1 +
>  systemd/nfs.conf.man |  1 +
>  utils/gssd/gssd.c    | 10 ++++++++++
>  3 files changed, 12 insertions(+)
> 
> diff --git a/nfs.conf b/nfs.conf
> index 0d0ec9b..5546109 100644
> --- a/nfs.conf
> +++ b/nfs.conf
> @@ -11,6 +11,7 @@
>  #[gssd]
>  # use-memcache=0
>  # use-machine-creds=1
> +# use-gss-proxy=0
>  # avoid-dns=1
>  # limit-to-legacy-enctypes=0
>  # context-timeout=0
> diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
> index 189b052..699db3f 100644
> --- a/systemd/nfs.conf.man
> +++ b/systemd/nfs.conf.man
> @@ -213,6 +213,7 @@ for details.
>  Recognized values:
>  .BR use-memcache ,
>  .BR use-machine-creds ,
> +.BR use-gss-proxy ,
>  .BR avoid-dns ,
>  .BR limit-to-legacy-enctypes ,
>  .BR context-timeout ,
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index 00df2fc..2e92f28 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -89,6 +89,7 @@ char *preferred_realm = NULL;
>  char *ccachedir = NULL;
>  /* Avoid DNS reverse lookups on server names */
>  static bool avoid_dns = true;
> +static bool use_gssproxy = false;
>  int thread_started = false;
>  pthread_mutex_t pmutex = PTHREAD_MUTEX_INITIALIZER;
>  pthread_cond_t pcond = PTHREAD_COND_INITIALIZER;
> @@ -872,6 +873,7 @@ read_gss_conf(void)
>  	if (s)
>  		preferred_realm = s;
>  
> +	use_gssproxy = conf_get_bool("gssd", "use-gss-proxy", use_gssproxy);
>  }
>  
>  int
> @@ -957,6 +959,14 @@ main(int argc, char *argv[])
>  		exit(1);
>  	}
>  
> +	if (use_gssproxy) {
> +		if (setenv("GSS_USE_PROXY", "yes", 1) < 0) {
> +			printerr(0, "gssd: Unable to set $GSS_USE_PROXY: %s\n", 
> +				strerror(errno));
> +			exit(EXIT_FAILURE);
> +		}
> +	}
> +
>  	if (ccachedir) {
>  		char *ccachedir_copy;
>  		char *ptr;
> 
