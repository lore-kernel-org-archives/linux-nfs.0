Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756558Ab3CYMmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 08:42:38 -0400
Message-ID: <51504638.8020408@RedHat.com>
Date: Mon, 25 Mar 2013 08:42:32 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH [nfs-utils]] locktes/rpcgen: tweak how we override compiler
 settings
References: <1364163668-15490-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1364163668-15490-1-git-send-email-vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 24/03/13 18:21, Mike Frysinger wrote:
> Newer autotools will use both CFLAGS and <target>_CFLAGS when compiling
> the <target>.  Adding the build settings to the target-specific flags no
> longer works as a way to compile build-time tools.
> 
> Instead, clobber the global flags.  This triggers an automake warning,
> but the end result actually works (unlike the existing code).
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  tools/locktest/Makefile.am | 7 +++----
>  tools/rpcgen/Makefile.am   | 7 +++----
>  2 files changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/tools/locktest/Makefile.am b/tools/locktest/Makefile.am
> index 3156815..efe6fcd 100644
> --- a/tools/locktest/Makefile.am
> +++ b/tools/locktest/Makefile.am
> @@ -1,12 +1,11 @@
>  ## Process this file with automake to produce Makefile.in
>  
>  CC=$(CC_FOR_BUILD)
> -LIBTOOL = @LIBTOOL@ --tag=CC
> +CFLAGS=$(CFLAGS_FOR_BUILD)
> +CPPFLAGS=$(CPPFLAGS_FOR_BUILD)
> +LDFLAGS=$(LDFLAGS_FOR_BUILD)
>  
>  noinst_PROGRAMS = testlk
>  testlk_SOURCES = testlk.c
> -testlk_CFLAGS=$(CFLAGS_FOR_BUILD)
> -testlk_CPPFLAGS=$(CPPFLAGS_FOR_BUILD)
> -testlk_LDFLAGS=$(LDFLAGS_FOR_BUILD)
>  
>  MAINTAINERCLEANFILES = Makefile.in
> diff --git a/tools/rpcgen/Makefile.am b/tools/rpcgen/Makefile.am
> index 8a9ec89..3adeec1 100644
> --- a/tools/rpcgen/Makefile.am
> +++ b/tools/rpcgen/Makefile.am
> @@ -1,7 +1,9 @@
>  ## Process this file with automake to produce Makefile.in
>  
>  CC=$(CC_FOR_BUILD)
> -LIBTOOL = @LIBTOOL@ --tag=CC
> +CFLAGS=$(CFLAGS_FOR_BUILD)
> +CPPFLAGS=$(CPPFLAGS_FOR_BUILD)
> +LDFLAGS=$(LDFLAGS_FOR_BUILD)
>  
>  noinst_PROGRAMS = rpcgen
>  rpcgen_SOURCES = rpc_clntout.c rpc_cout.c rpc_hout.c rpc_main.c \
> @@ -9,9 +11,6 @@ rpcgen_SOURCES = rpc_clntout.c rpc_cout.c rpc_hout.c rpc_main.c \
>  		 rpc_util.c rpc_sample.c rpc_output.h rpc_parse.h \
>  		 rpc_scan.h rpc_util.h
>  
> -rpcgen_CFLAGS=$(CFLAGS_FOR_BUILD)
> -rpcgen_CPPLAGS=$(CPPFLAGS_FOR_BUILD)
> -rpcgen_LDFLAGS=$(LDFLAGS_FOR_BUILD)
>  rpcgen_LDADD=$(LIBTIRPC)
>  
>  MAINTAINERCLEANFILES = Makefile.in
> -- 1.8.1.2 -- To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at http://vger.kernel.org/majordomo-info.html
> 
This patch is causing the following warnings:

tools/locktest/Makefile.am:4: warning: 'CFLAGS' is a user variable, you should not override it;
tools/locktest/Makefile.am:4: use 'AM_CFLAGS' instead
tools/locktest/Makefile.am:5: warning: 'CPPFLAGS' is a user variable, you should not override it;
tools/locktest/Makefile.am:5: use 'AM_CPPFLAGS' instead
tools/locktest/Makefile.am:6: warning: 'LDFLAGS' is a user variable, you should not override it;
tools/locktest/Makefile.am:6: use 'AM_LDFLAGS' instead
tools/rpcgen/Makefile.am:4: warning: 'CFLAGS' is a user variable, you should not override it;
tools/rpcgen/Makefile.am:4: use 'AM_CFLAGS' instead
tools/rpcgen/Makefile.am:5: warning: 'CPPFLAGS' is a user variable, you should not override it;
tools/rpcgen/Makefile.am:5: use 'AM_CPPFLAGS' instead
tools/rpcgen/Makefile.am:6: warning: 'LDFLAGS' is a user variable, you should not override it;
tools/rpcgen/Makefile.am:6: use 'AM_LDFLAGS' instead

You didn't see these in your testing?

Also what exactly broke that this patch fixes? 

steved.
