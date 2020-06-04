Return-Path: <SRS0=JLvH=7R=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E1DDC433DF
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Jun 2020 14:24:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 593D2206E6
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Jun 2020 14:24:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="dI7MrUbD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729008AbgFDOYN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Jun 2020 10:24:13 -0400
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:48643 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1728881AbgFDOYM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2020 10:24:12 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1591280651;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=D60kMRMPD8GUeZgAgfAVGZC45ucj8ZYh57ppYbimbuY=;
        b=dI7MrUbDEBRj/WMGsm2Fbg+OqlQJzHO+dgtIWakKuzpL6HB2vYIG7BaWINt6e31iWDioqM
        kAVrphxbs2WOsi4XC9rxlt83PtT4YpokdXosSzXUL0HRuKLXQNOCMRsV78xVszRIAIofrM
        ypUV4OBvn6JlM1V3V5ewj2zsViGX9gI=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-189-SVk2bRjcPwmVyzc6EaOdyg-1; Thu, 04 Jun 2020 10:23:58 -0400
X-MC-Unique: SVk2bRjcPwmVyzc6EaOdyg-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id E5119800685;
        Thu,  4 Jun 2020 14:23:57 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-114-73.phx2.redhat.com [10.3.114.73])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9F27910013D6;
        Thu,  4 Jun 2020 14:23:57 +0000 (UTC)
Subject: Re: [rpcbind 1/1] security: Fix typos in debug messages and comments
To:     Petr Vorel <pvorel@suse.cz>, linux-nfs@vger.kernel.org
References: <20200603210341.11641-1-pvorel@suse.cz>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <0e896b22-ba88-0b33-c30d-328a36084518@RedHat.com>
Date:   Thu, 4 Jun 2020 10:23:57 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <20200603210341.11641-1-pvorel@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 6/3/20 5:03 PM, Petr Vorel wrote:
> Signed-off-by: Petr Vorel <pvorel@suse.cz>
Committed... (tag: rpcbind-1_2_6-rc5)

steved.

> ---
>  src/rpcbind.c  | 4 ++--
>  src/security.c | 4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 73daa1c..25d8a90 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -505,7 +505,7 @@ init_transport(struct netconfig *nconf)
>  					hints.ai_flags |= AI_NUMERICHOST;
>  				} else {
>  					/*
> -					 * Skip if we have an AF_INET6 adress.
> +					 * Skip if we have an AF_INET6 address.
>  					 */
>  					if (inet_pton(AF_INET6,
>  					    hosts[nhostsbak], host_addr) == 1)
> @@ -518,7 +518,7 @@ init_transport(struct netconfig *nconf)
>  					hints.ai_flags |= AI_NUMERICHOST;
>  				} else {
>  					/*
> -					 * Skip if we have an AF_INET adress.
> +					 * Skip if we have an AF_INET address.
>  					 */
>  					if (inet_pton(AF_INET, hosts[nhostsbak],
>  					    host_addr) == 1)
> diff --git a/src/security.c b/src/security.c
> index 8a12019..329c53d 100644
> --- a/src/security.c
> +++ b/src/security.c
> @@ -145,7 +145,7 @@ is_loopback(struct netbuf *nbuf)
>  #ifdef RPCBIND_DEBUG
>  		if (debugging)
>  			  xlog(LOG_DEBUG,
> -				  "Checking caller's adress (port = %d)\n",
> +				  "Checking caller's address (port = %d)\n",
>  				  ntohs(sin->sin_port));
>  #endif
>  	       	return (sin->sin_addr.s_addr == htonl(INADDR_LOOPBACK));
> @@ -157,7 +157,7 @@ is_loopback(struct netbuf *nbuf)
>  #ifdef RPCBIND_DEBUG
>  		if (debugging)
>  			  xlog(LOG_DEBUG,
> -				  "Checking caller's adress (port = %d)\n",
> +				  "Checking caller's address (port = %d)\n",
>  				  ntohs(sin6->sin6_port));
>  #endif
>  		return (IN6_IS_ADDR_LOOPBACK(&sin6->sin6_addr) ||
> 

