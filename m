Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48D63C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 02:29:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 17A6D2073F
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 02:29:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726227AbfACC3O (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 21:29:14 -0500
Received: from mail5.windriver.com ([192.103.53.11]:59480 "EHLO mail5.wrs.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728164AbfACC3O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Jan 2019 21:29:14 -0500
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca.corp.ad.wrs.com [147.11.189.40])
        by mail5.wrs.com (8.15.2/8.15.2) with ESMTPS id x032Sr1x009323
        (version=TLSv1 cipher=AES128-SHA bits=128 verify=FAIL)
        for <linux-nfs@vger.kernel.org>; Wed, 2 Jan 2019 18:29:03 -0800
Received: from [128.224.162.194] (128.224.162.194) by ALA-HCA.corp.ad.wrs.com
 (147.11.189.50) with Microsoft SMTP Server (TLS) id 14.3.408.0; Wed, 2 Jan
 2019 18:28:42 -0800
Subject: Re: [PATCH] Makefile.am: update the path of libnfs.a
References: <1545026355-401179-1-git-send-email-mingli.yu@windriver.com>
To:     <linux-nfs@vger.kernel.org>
From:   "Yu, Mingli" <mingli.yu@windriver.com>
Message-ID: <5C2D7279.2040202@windriver.com>
Date:   Thu, 3 Jan 2019 10:24:57 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101
 Thunderbird/38.4.0
MIME-Version: 1.0
In-Reply-To: <1545026355-401179-1-git-send-email-mingli.yu@windriver.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-Originating-IP: [128.224.162.194]
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ping.

On 2018年12月17日 13:59, mingli.yu@windriver.com wrote:
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
> ---
>   tests/Makefile.am            | 2 +-
>   tests/nsm_client/Makefile.am | 2 +-
>   2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/tests/Makefile.am b/tests/Makefile.am
> index 1f96264..74aa629 100644
> --- a/tests/Makefile.am
> +++ b/tests/Makefile.am
> @@ -3,7 +3,7 @@
>   check_PROGRAMS = statdb_dump
>   statdb_dump_SOURCES = statdb_dump.c
>
> -statdb_dump_LDADD = ../support/nfs/libnfs.a \
> +statdb_dump_LDADD = ../support/nfs/.libs/libnfs.a \
>   		    ../support/nsm/libnsm.a $(LIBCAP)
>
>   SUBDIRS = nsm_client
> diff --git a/tests/nsm_client/Makefile.am b/tests/nsm_client/Makefile.am
> index a8fc131..43db9c2 100644
> --- a/tests/nsm_client/Makefile.am
> +++ b/tests/nsm_client/Makefile.am
> @@ -13,7 +13,7 @@ check_PROGRAMS	= nsm_client
>   nsm_client_SOURCES = $(GENFILES) nsm_client.c
>
>   BUILT_SOURCES = $(GENFILES)
> -nsm_client_LDADD = ../../support/nfs/libnfs.a \
> +nsm_client_LDADD = ../../support/nfs/.libs/libnfs.a \
>   		   ../../support/nsm/libnsm.a $(LIBCAP) $(LIBTIRPC)
>
>   if CONFIG_RPCGEN
>
