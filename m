Return-Path: <SRS0=o69+=33=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72BC0C35242
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Feb 2020 16:09:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 40DA720838
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Feb 2020 16:09:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="KziH8snV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726951AbgBGQJB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 7 Feb 2020 11:09:01 -0500
Received: from us-smtp-1.mimecast.com ([205.139.110.61]:28844 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1727065AbgBGQJB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Feb 2020 11:09:01 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1581091740;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=CJmN4immfLUTLdcZFOrAzF59w7HxDONTzAPPBrkAPNM=;
        b=KziH8snVzDbnkBSAiVj7KKp1PymE57GpnIPmoSFFGT2eeDO3JBIizPv9H1x2rUmPwW+e9N
        zJYMSrDyv8ZOKd12jGkhKrrdVOyXEzr6QD4rW100YZrGngcnISDMmx8geBRurzvjWfhQRt
        WL/SQr414gg3HTrVNAXCrrz1m+UOvB8=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-350-GyeXMRXIPum8-hAcu_0rSQ-1; Fri, 07 Feb 2020 11:08:58 -0500
X-MC-Unique: GyeXMRXIPum8-hAcu_0rSQ-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 19322800E21
        for <linux-nfs@vger.kernel.org>; Fri,  7 Feb 2020 16:08:57 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-117-141.phx2.redhat.com [10.3.117.141])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DE5045C3FD
        for <linux-nfs@vger.kernel.org>; Fri,  7 Feb 2020 16:08:56 +0000 (UTC)
Subject: Re: [PATCH] query_krb5_ccache: Removed dead code that was flagged by
 a covscan
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20200207152109.20855-1-steved@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <dfd22831-13d8-6c8c-0452-a5aca41d5a1c@RedHat.com>
Date:   Fri, 7 Feb 2020 11:08:56 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.4.1
MIME-Version: 1.0
In-Reply-To: <20200207152109.20855-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 2/7/20 10:21 AM, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... (tag: nfs-utils-2-4-3-rc7)

steved.
> ---
>  utils/gssd/krb5_util.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index bff759f..a1c43d2 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1066,8 +1066,6 @@ query_krb5_ccache(const char* cred_cache, char **ret_princname,
>  			    *ret_realm = strdup(str+1);
>  		    }
>  		    k5_free_unparsed_name(context, princstring);
> -		} else {
> -			found = 0;
>  		}
>  	}
>  	krb5_free_principal(context, principal);
> 

