Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757816Ab3CYOTu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 10:19:50 -0400
Message-ID: <51505D03.6000903@RedHat.com>
Date: Mon, 25 Mar 2013 10:19:47 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH [nfs-utils]] rpcdebug: do not use build toolchain
References: <1364162728-3032-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1364162728-3032-1-git-send-email-vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 24/03/13 18:05, Mike Frysinger wrote:
> The rpcdebug program gets installed, so we don't want to use the build
> toolchain to compile it.  I can't find any scripts in the build system
> that try to execute it, so this shouldn't be a problem.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Committed...

steved
> ---
>  tools/rpcdebug/Makefile.am | 6 ------
>  1 file changed, 6 deletions(-)
> 
> diff --git a/tools/rpcdebug/Makefile.am b/tools/rpcdebug/Makefile.am
> index 39b70c9..b0a3e1f 100644
> --- a/tools/rpcdebug/Makefile.am
> +++ b/tools/rpcdebug/Makefile.am
> @@ -1,15 +1,9 @@
>  ## Process this file with automake to produce Makefile.in
>  
> -CC=$(CC_FOR_BUILD)
> -LIBTOOL = @LIBTOOL@ --tag=CC
> -
>  man8_MANS = rpcdebug.man
>  EXTRA_DIST = $(man8_MANS)
>  
>  sbin_PROGRAMS = rpcdebug
>  rpcdebug_SOURCES = rpcdebug.c
> -rpcdebug_CFLAGS=$(CFLAGS_FOR_BUILD)
> -rpcdebug_CPPFLAGS=$(CPPFLAGS_FOR_BUILD) -I$(top_srcdir)/support/include
> -rpcdebug_LDFLAGS=$(LDFLAGS_FOR_BUILD)
>  
>  MAINTAINERCLEANFILES = Makefile.in
> 
