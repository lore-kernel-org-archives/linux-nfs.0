Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753390AbeBGSsl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Feb 2018 13:48:41 -0500
Subject: Re: [PATCH] Remove unneeded reference to nfsidmap_internal.h
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
References: <20180117221020.11056.59627.stgit@manet.1015granger.net>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <d8abfb29-84e7-9196-8394-b385c6d2e651@RedHat.com>
Date: Wed, 7 Feb 2018 13:48:40 -0500
MIME-Version: 1.0
In-Reply-To: <20180117221020.11056.59627.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/17/2018 05:10 PM, Chuck Lever wrote:
> This file is not part of "git clone" and is not #included from any
> C file.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.
> ---
>  support/nfsidmap/Makefile.am |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Hey Steve-
> 
> I don't see nfsidmap_internal.h anywhere.  Wondering if I missed
> something?
> 
> diff --git a/support/nfsidmap/Makefile.am b/support/nfsidmap/Makefile.am
> index 9466f92..8b5dfe4 100644
> --- a/support/nfsidmap/Makefile.am
> +++ b/support/nfsidmap/Makefile.am
> @@ -25,7 +25,7 @@ pkgplugin_LTLIBRARIES = nsswitch.la static.la $(UMICH_LDAP_LIB) $(GUMS_MAPPING_L
>  #  <age> 	The number of previous additional interfaces supported
>  #  		by this library.
>  
> -libnfsidmap_la_SOURCES = libnfsidmap.c nfsidmap_internal.h nfsidmap_common.c
> +libnfsidmap_la_SOURCES = libnfsidmap.c nfsidmap_common.c
>  libnfsidmap_la_LDFLAGS = -version-info 1:0:0
>  libnfsidmap_la_LIBADD = -ldl ../../support/nfs/libnfsconf.la
>  
> 
