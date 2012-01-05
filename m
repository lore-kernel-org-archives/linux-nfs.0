Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47870 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101Ab2AEVne (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jan 2012 16:43:34 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q05LhY35026679
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 5 Jan 2012 16:43:34 -0500
Message-ID: <4F061985.2040102@RedHat.com>
Date: Thu, 05 Jan 2012 16:43:33 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] autoconf: fix up libevent autoconf test
References: <1324669625-2948-1-git-send-email-jlayton@redhat.com> <1324669625-2948-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1324669625-2948-2-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/23/2011 02:47 PM, Jeff Layton wrote:
> Have it set LIBEVENT to -levent and use that in the Makefiles instead
> of hardcoding it.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed...

steved.
> ---
>  aclocal/libevent.m4      |    3 ++-
>  utils/idmapd/Makefile.am |    2 +-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/aclocal/libevent.m4 b/aclocal/libevent.m4
> index 3c962b3..b5ac00f 100644
> --- a/aclocal/libevent.m4
> +++ b/aclocal/libevent.m4
> @@ -2,8 +2,9 @@ dnl Checks for libevent
>  AC_DEFUN([AC_LIBEVENT], [
>  
>    dnl Check for libevent, but do not add -levent to LIBS
> -  AC_CHECK_LIB([event], [event_dispatch], [libevent=1],
> +  AC_CHECK_LIB([event], [event_dispatch], [LIBEVENT=-levent],
>                 [AC_MSG_ERROR([libevent not found.])])
> +  AC_SUBST(LIBEVENT)
>  
>    AC_CHECK_HEADERS([event.h], ,
>                     [AC_MSG_ERROR([libevent headers not found.])])
> diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
> index 4328e41..f8578b0 100644
> --- a/utils/idmapd/Makefile.am
> +++ b/utils/idmapd/Makefile.am
> @@ -16,7 +16,7 @@ idmapd_SOURCES = \
>  	nfs_idmap.h \
>  	queue.h
>  
> -idmapd_LDADD = -levent -lnfsidmap ../../support/nfs/libnfs.a
> +idmapd_LDADD = $(LIBEVENT) -lnfsidmap ../../support/nfs/libnfs.a
>  
>  MAINTAINERCLEANFILES = Makefile.in
>  
