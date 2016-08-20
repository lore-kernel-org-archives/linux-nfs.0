Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52066 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752752AbcHTOzP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Aug 2016 10:55:15 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6B4166333E
        for <linux-nfs@vger.kernel.org>; Sat, 20 Aug 2016 14:55:15 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-56-229.rdu2.redhat.com [10.10.56.229])
        by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u7KEtEYQ026004
        for <linux-nfs@vger.kernel.org>; Sat, 20 Aug 2016 10:55:15 -0400
Subject: Re: [RFC PATCH 2/3] configure.ac: Ensure the resolver library is
 installed
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1471545435-15543-1-git-send-email-steved@redhat.com>
 <1471545435-15543-2-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <7c72092c-89cd-9eb0-6501-9a102cca93ee@RedHat.com>
Date: Sat, 20 Aug 2016 10:55:14 -0400
MIME-Version: 1.0
In-Reply-To: <1471545435-15543-2-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/18/2016 02:37 PM, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  configure.ac | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/configure.ac b/configure.ac
> index 5944166..52e12c8 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -13,6 +13,7 @@ LT_INIT
>  AC_PROG_CC
>  
>  # Checks for libraries.
> +AC_CHECK_LIB([resolv], [res_querydomain])
>  
>  AC_ARG_ENABLE([ldap],
>  	[AS_HELP_STRING([--disable-ldap],[Disable support for LDAP @<:@default=detect@:>@])])
> 
