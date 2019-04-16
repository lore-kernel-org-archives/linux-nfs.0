Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F201C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 14:34:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2F52C20656
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 14:34:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729598AbfDPOew (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 10:34:52 -0400
Received: from mx1.redhat.com ([209.132.183.28]:42070 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729597AbfDPOew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Apr 2019 10:34:52 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 702784623E;
        Tue, 16 Apr 2019 14:34:52 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (madhat.boston.devel.redhat.com [10.19.60.33])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 26CA319C6A;
        Tue, 16 Apr 2019 14:34:52 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: nfsidmap fail to build if no --with-pluginpath
 specified
To:     Yongcheng Yang <yongcheng.yang@gmail.com>
Cc:     linux-nfs@vger.kernel.org
References: <20190402091651.17186-1-yongcheng.yang@gmail.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <95e49187-6d99-4168-1bb1-4a3f6f2500ee@RedHat.com>
Date:   Tue, 16 Apr 2019 10:34:51 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190402091651.17186-1-yongcheng.yang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 16 Apr 2019 14:34:52 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

On 4/2/19 5:16 AM, Yongcheng Yang wrote:
> The var "pkgplugindir" will be empty if no pluginpath provided.
> Makefile "-rpath $(pkgplugindir)" will then get failed.
> 
> Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
> ---
>  support/nfsidmap/Makefile.am | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/support/nfsidmap/Makefile.am b/support/nfsidmap/Makefile.am
> index cdbeb4c..9c21fa3 100644
> --- a/support/nfsidmap/Makefile.am
> +++ b/support/nfsidmap/Makefile.am
> @@ -1,4 +1,8 @@
> +if PATH_PLUGINS
>  pkgplugindir=$(PATH_PLUGINS)
> +else
> +pkgplugindir=$(libdir)/libnfsidmap
> +endif
>  
>  if ENABLE_LDAP
>  UMICH_LDAP_LIB = umich_ldap.la
> 
The only way I see a failure is when ./configure --with-pluginpath= 
without a path which is wrong... 

./configure --with-pluginpath=/usr/lib/libnfsidmap seems to work
just fine

I thinking it is better to error out when a path is not given
then to gloss over but used a default.

steved.

