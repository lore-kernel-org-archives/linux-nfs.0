Return-Path: <SRS0=tL+H=BI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,NICE_REPLY_A,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69E84C433DF
	for <linux-nfs@archiver.kernel.org>; Wed, 29 Jul 2020 14:27:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4715B207E8
	for <linux-nfs@archiver.kernel.org>; Wed, 29 Jul 2020 14:27:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="NsAkjTBm"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726588AbgG2O1c (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 29 Jul 2020 10:27:32 -0400
Received: from us-smtp-delivery-1.mimecast.com ([205.139.110.120]:37885 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726353AbgG2O1c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jul 2020 10:27:32 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1596032851;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=2lzllwyt3ECeAgfJSSQ9psAtn0KTj2w/atlZhUbsDlo=;
        b=NsAkjTBm1/yHOVBEC6w56kBmDoR3dmOgMpqdbGDWe5JIAcZ3/6+Ahb8bjhBXxJaBHJYcaO
        1aWQI/lj9CLSTYGuPuUwDy+GjSqVFMkY6hbmcs2SsWH1uJOTUfmMaoVnZfLO7c3xAuSe5G
        QexaAPeeCKEtcjTGFXzn+NOhmhPAtwg=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-282-iyOrixGwOfWfg5CfB5KhdA-1; Wed, 29 Jul 2020 10:27:29 -0400
X-MC-Unique: iyOrixGwOfWfg5CfB5KhdA-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 135FE8C3540;
        Wed, 29 Jul 2020 14:27:28 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-113-147.phx2.redhat.com [10.3.113.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B011260CD1;
        Wed, 29 Jul 2020 14:27:27 +0000 (UTC)
Subject: Re: [PATCH 4/5] Add ability to detect if we're on the main thread.
To:     Doug Nazar <nazard@nazar.ca>, libtirpc-devel@lists.sourceforge.net
Cc:     linux-nfs@vger.kernel.org
References: <20200722053445.27987-1-nazard@nazar.ca>
 <20200722053445.27987-5-nazard@nazar.ca>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <badd66b3-ab94-efbb-fc6f-360ab45314df@RedHat.com>
Date:   Wed, 29 Jul 2020 10:27:27 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <20200722053445.27987-5-nazard@nazar.ca>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 7/22/20 1:34 AM, Doug Nazar wrote:
> Signed-off-by: Doug Nazar <nazard@nazar.ca>
> ---
>  src/mt_misc.c     | 17 +++++++++++++++++
>  tirpc/reentrant.h |  1 +
>  2 files changed, 18 insertions(+)
> 
> diff --git a/src/mt_misc.c b/src/mt_misc.c
> index 5a49b78..020b55d 100644
> --- a/src/mt_misc.c
> +++ b/src/mt_misc.c
> @@ -151,3 +151,20 @@ void tsd_key_delete(void)
>  	return;
>  }
>  
> +static pthread_t main_thread_id;
> +
> +__attribute__((constructor))
> +static void
> +get_thread_id(void)
> +{
> +	/* This will only work if we're opened by the main thread.
> +	 * Shouldn't be a problem in practice since we expect to be
> +	 * linked against, not dlopen() from a random thread.
> +	 */
> +	main_thread_id = pthread_self();
> +}
> +
> +int thr_main(void)
> +{
> +	return pthread_equal(main_thread_id, pthread_self());
> +}
> diff --git a/tirpc/reentrant.h b/tirpc/reentrant.h
> index 5bb581a..ee65454 100644
> --- a/tirpc/reentrant.h
> +++ b/tirpc/reentrant.h
> @@ -76,4 +76,5 @@
>  #define thr_self()		pthread_self()
>  #define thr_exit(x)		pthread_exit(x)
>  
> +extern int thr_main(void);
>  #endif
> 
Again... why is this needed? 

Your description part of these patches are a bit thin ;-)

steved.

