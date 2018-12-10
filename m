Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95726C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 21:25:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5CDB320821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 21:25:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CDB320821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727880AbeLJVZv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 16:25:51 -0500
Received: from mx1.redhat.com ([209.132.183.28]:43742 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727665AbeLJVZv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Dec 2018 16:25:51 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 71D25308123E;
        Mon, 10 Dec 2018 21:25:51 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-64.phx2.redhat.com [10.3.117.64])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 1306A60BF1;
        Mon, 10 Dec 2018 21:25:50 +0000 (UTC)
Subject: Re: [PATCH nfs-utils] nfsidmap: honour --with-pluginpath for
 instalation.
To:     NeilBrown <neilb@suse.com>
Cc:     linux-nfs@vger.kernel.org
References: <87y3966s24.fsf@notabene.neil.brown.name>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <102d7214-4374-97a8-dde7-8be68fd81555@RedHat.com>
Date:   Mon, 10 Dec 2018 16:25:50 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <87y3966s24.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 10 Dec 2018 21:25:51 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 12/3/18 7:42 PM, NeilBrown wrote:
> 
> The path set with --with-pluginpath is not currently
> used when installing plugins.  It should be.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed... 

steved.

> ---
>  configure.ac                 | 1 +
>  support/nfsidmap/Makefile.am | 2 +-
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/configure.ac b/configure.ac
> index 4163f6a518f5..4bf5aea4442f 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -450,6 +450,7 @@ if test -n "$path_plugins" ; then
>                  [Define this to change the plugins path])
>  fi
>  AM_CONDITIONAL(PATH_PLUGINS, test -n "$path_plugins")
> +AC_SUBST(PATH_PLUGINS, "$path_plugins")
>  
>  AC_SUBST(AM_CPPFLAGS, "$AM_CPPFLAGS")
>  AC_DEFINE([HAVE_NFS4_SET_DEBUG], 1,
> diff --git a/support/nfsidmap/Makefile.am b/support/nfsidmap/Makefile.am
> index 8b5dfe4e784a..cdbeb4c1a9ac 100644
> --- a/support/nfsidmap/Makefile.am
> +++ b/support/nfsidmap/Makefile.am
> @@ -1,4 +1,4 @@
> -pkgplugindir=$(libdir)/libnfsidmap
> +pkgplugindir=$(PATH_PLUGINS)
>  
>  if ENABLE_LDAP
>  UMICH_LDAP_LIB = umich_ldap.la
> 
