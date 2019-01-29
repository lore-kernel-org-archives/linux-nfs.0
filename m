Return-Path: <SRS0=GD9Z=QF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 006E6C169C4
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 20:41:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CE9542087E
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 20:41:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727383AbfA2Ul6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Jan 2019 15:41:58 -0500
Received: from mx1.redhat.com ([209.132.183.28]:32778 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726945AbfA2Ul5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Jan 2019 15:41:57 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D251F369BC;
        Tue, 29 Jan 2019 20:41:57 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-222.phx2.redhat.com [10.3.116.222])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 79F745D982;
        Tue, 29 Jan 2019 20:41:57 +0000 (UTC)
Subject: Re: [PATCH] Makefile.am: update the path of libnfs.a
To:     mingli.yu@windriver.com, linux-nfs@vger.kernel.org
References: <1545026355-401179-1-git-send-email-mingli.yu@windriver.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <9c125d9b-a82f-51ed-d4c8-12cf28bf422f@RedHat.com>
Date:   Tue, 29 Jan 2019 15:41:57 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1545026355-401179-1-git-send-email-mingli.yu@windriver.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 29 Jan 2019 20:41:57 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 12/17/18 12:59 AM, mingli.yu@windriver.com wrote:
> From: Mingli Yu <Mingli.Yu@windriver.com>
> 
> The libnfs.a is under ../support/nfs/.libs/ now,
> update the reference path accordingly to fix below
> build error when run "make -C tests statdb_dump":
> | make: *** No rule to make target '../support/nfs/libnfs.a', needed by 'statdb_dump'.  Stop.
> 
> And below error when run "make -C tests/nsm_client nsm_client"
> | make: *** No rule to make target '../../support/nfs/libnfs.a', needed by 'nsm_client'.  Stop.
> 
> Signed-off-by: Mingli Yu <Mingli.Yu@windriver.com>
My apologies for taking so long to commit this... 

steved.
 
> ---
>  tests/Makefile.am            | 2 +-
>  tests/nsm_client/Makefile.am | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/tests/Makefile.am b/tests/Makefile.am
> index 1f96264..74aa629 100644
> --- a/tests/Makefile.am
> +++ b/tests/Makefile.am
> @@ -3,7 +3,7 @@
>  check_PROGRAMS = statdb_dump
>  statdb_dump_SOURCES = statdb_dump.c
>  
> -statdb_dump_LDADD = ../support/nfs/libnfs.a \
> +statdb_dump_LDADD = ../support/nfs/.libs/libnfs.a \
>  		    ../support/nsm/libnsm.a $(LIBCAP)
>  
>  SUBDIRS = nsm_client
> diff --git a/tests/nsm_client/Makefile.am b/tests/nsm_client/Makefile.am
> index a8fc131..43db9c2 100644
> --- a/tests/nsm_client/Makefile.am
> +++ b/tests/nsm_client/Makefile.am
> @@ -13,7 +13,7 @@ check_PROGRAMS	= nsm_client
>  nsm_client_SOURCES = $(GENFILES) nsm_client.c
>  
>  BUILT_SOURCES = $(GENFILES)
> -nsm_client_LDADD = ../../support/nfs/libnfs.a \
> +nsm_client_LDADD = ../../support/nfs/.libs/libnfs.a \
>  		   ../../support/nsm/libnsm.a $(LIBCAP) $(LIBTIRPC)
>  
>  if CONFIG_RPCGEN
> 
