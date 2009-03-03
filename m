From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Fixed cross-compilation of nfs-utils tools.
Date: Tue, 3 Mar 2009 13:03:52 -0500
Message-ID: <9DAB51AD-9EE9-4AC5-A77F-C261CBDAAD96@oracle.com>
References: <1236102558-18099-1-git-send-email-ihar.hrachyshka@gmail.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Ihar Hrachyshka <ihar.hrachyshka@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:37644 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbZCCSEG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 13:04:06 -0500
In-Reply-To: <1236102558-18099-1-git-send-email-ihar.hrachyshka@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 3, 2009, at Mar 3, 2009, 12:49 PM, Ihar Hrachyshka wrote:
> Build nfs-utils tools with compiler defined by ./configure script.

In the patch description, can you provide some information about the  
problem you encountered?

> ---
> tools/locktest/Makefile.am |    4 ----
> tools/rpcdebug/Makefile.am |    4 ----
> tools/rpcgen/Makefile.am   |    5 -----
> 3 files changed, 0 insertions(+), 13 deletions(-)
>
> diff --git a/tools/locktest/Makefile.am b/tools/locktest/Makefile.am
> index 3156815..e89fbad 100644
> --- a/tools/locktest/Makefile.am
> +++ b/tools/locktest/Makefile.am
> @@ -1,12 +1,8 @@
> ## Process this file with automake to produce Makefile.in
>
> -CC=$(CC_FOR_BUILD)
> LIBTOOL = @LIBTOOL@ --tag=CC
>
> noinst_PROGRAMS = testlk
> testlk_SOURCES = testlk.c
> -testlk_CFLAGS=$(CFLAGS_FOR_BUILD)
> -testlk_CPPFLAGS=$(CPPFLAGS_FOR_BUILD)
> -testlk_LDFLAGS=$(LDFLAGS_FOR_BUILD)
>
> MAINTAINERCLEANFILES = Makefile.in
> diff --git a/tools/rpcdebug/Makefile.am b/tools/rpcdebug/Makefile.am
> index 39b70c9..c627b01 100644
> --- a/tools/rpcdebug/Makefile.am
> +++ b/tools/rpcdebug/Makefile.am
> @@ -1,6 +1,5 @@
> ## Process this file with automake to produce Makefile.in
>
> -CC=$(CC_FOR_BUILD)
> LIBTOOL = @LIBTOOL@ --tag=CC
>
> man8_MANS = rpcdebug.man
> @@ -8,8 +7,5 @@ EXTRA_DIST = $(man8_MANS)
>
> sbin_PROGRAMS = rpcdebug
> rpcdebug_SOURCES = rpcdebug.c
> -rpcdebug_CFLAGS=$(CFLAGS_FOR_BUILD)
> -rpcdebug_CPPFLAGS=$(CPPFLAGS_FOR_BUILD) -I$(top_srcdir)/support/ 
> include
> -rpcdebug_LDFLAGS=$(LDFLAGS_FOR_BUILD)
>
> MAINTAINERCLEANFILES = Makefile.in
> diff --git a/tools/rpcgen/Makefile.am b/tools/rpcgen/Makefile.am
> index 51a2bfa..fc75108 100644
> --- a/tools/rpcgen/Makefile.am
> +++ b/tools/rpcgen/Makefile.am
> @@ -1,6 +1,5 @@
> ## Process this file with automake to produce Makefile.in
>
> -CC=$(CC_FOR_BUILD)
> LIBTOOL = @LIBTOOL@ --tag=CC
>
> noinst_PROGRAMS = rpcgen
> @@ -9,10 +8,6 @@ rpcgen_SOURCES = rpc_clntout.c rpc_cout.c  
> rpc_hout.c rpc_main.c \
> 		 rpc_util.c rpc_sample.c rpc_output.h rpc_parse.h \
> 		 rpc_scan.h rpc_util.h
>
> -rpcgen_CFLAGS=$(CFLAGS_FOR_BUILD)
> -rpcgen_CPPLAGS=$(CPPFLAGS_FOR_BUILD)
> -rpcgen_LDFLAGS=$(LDFLAGS_FOR_BUILD)
> -

Are you sure rpcgen should be built for the target system?  rpcgen  
only needs to run on the build system; it's not installed on the  
target, as far as I know.  The rpcgen on my systems are from glibc- 
common.

>
> MAINTAINERCLEANFILES = Makefile.in
>
> EXTRA_DIST = rpcgen.new.1

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
