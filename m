Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25654 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758290Ab2AEVoD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jan 2012 16:44:03 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q05Li20a026830
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 5 Jan 2012 16:44:02 -0500
Message-ID: <4F0619A1.9010009@RedHat.com>
Date: Thu, 05 Jan 2012 16:44:01 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] autoconf: don't let libnfsidmap test add -lnfsidmap
 to $LIBS
References: <1324669625-2948-1-git-send-email-jlayton@redhat.com> <1324669625-2948-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1324669625-2948-3-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/23/2011 02:47 PM, Jeff Layton wrote:
> ...as that makes that library get linked into every binary. Also,
> replace "hardcoded" -lnfsidmap linker flag in Makefiles with
> a AC_SUBST variable.
> 
> This fixes a regression introduced in commit d7c64dd.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed...

steved.

> ---
>  aclocal/libnfsidmap.m4     |    9 ++++++---
>  utils/gssd/Makefile.am     |    2 +-
>  utils/idmapd/Makefile.am   |    2 +-
>  utils/nfsidmap/Makefile.am |    2 +-
>  4 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/aclocal/libnfsidmap.m4 b/aclocal/libnfsidmap.m4
> index 484b1ec..ae697e8 100644
> --- a/aclocal/libnfsidmap.m4
> +++ b/aclocal/libnfsidmap.m4
> @@ -3,7 +3,7 @@ dnl
>  AC_DEFUN([AC_LIBNFSIDMAP], [
>  
>    dnl Check for libnfsidmap, but do not add -lnfsidmap to LIBS
> -  AC_CHECK_LIB([nfsidmap], [nfs4_init_name_mapping], [libnfsidmap=1],
> +  AC_CHECK_LIB([nfsidmap], [nfs4_init_name_mapping], [LIBNFSIDMAP=-lnfsidmap],
>                 [AC_MSG_ERROR([libnfsidmap not found.])])
>  
>    AC_CHECK_HEADERS([nfsidmap.h], ,
> @@ -14,7 +14,10 @@ AC_DEFUN([AC_LIBNFSIDMAP], [
>                 [AC_DEFINE([HAVE_NFS4_SET_DEBUG], 1,
>                            [Define to 1 if you have the `nfs4_set_debug' function.])])
>  
> -  dnl only enable nfsidmap when libnfsidmap supports it
> -  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid])
> +  dnl nfs4_owner_to_uid() doesn't appear in all versions of libnfsidmap
> +  dnl We just need this test to set $ac_cv_lib_nfsidmap_nfs4_owner_to_uid
> +  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [:])
> +
> +  AC_SUBST(LIBNFSIDMAP)
>  
>  ])dnl
> diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
> index d7888ad..9136189 100644
> --- a/utils/gssd/Makefile.am
> +++ b/utils/gssd/Makefile.am
> @@ -58,7 +58,7 @@ svcgssd_SOURCES = \
>  
>  svcgssd_LDADD = \
>  	../../support/nfs/libnfs.a \
> -	$(RPCSECGSS_LIBS) $(GSSGLUE_LIBS) -lnfsidmap \
> +	$(RPCSECGSS_LIBS) $(GSSGLUE_LIBS) $(LIBNFSIDMAP) \
>  	$(KRBLIBS)
>  
>  svcgssd_LDFLAGS = $(KRBLDFLAGS)
> diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
> index f8578b0..58b33ec 100644
> --- a/utils/idmapd/Makefile.am
> +++ b/utils/idmapd/Makefile.am
> @@ -16,7 +16,7 @@ idmapd_SOURCES = \
>  	nfs_idmap.h \
>  	queue.h
>  
> -idmapd_LDADD = $(LIBEVENT) -lnfsidmap ../../support/nfs/libnfs.a
> +idmapd_LDADD = $(LIBEVENT) $(LIBNFSIDMAP) ../../support/nfs/libnfs.a
>  
>  MAINTAINERCLEANFILES = Makefile.in
>  
> diff --git a/utils/nfsidmap/Makefile.am b/utils/nfsidmap/Makefile.am
> index 037aa79..c0675c4 100644
> --- a/utils/nfsidmap/Makefile.am
> +++ b/utils/nfsidmap/Makefile.am
> @@ -4,6 +4,6 @@ man8_MANS = nfsidmap.man
>  
>  sbin_PROGRAMS	= nfsidmap
>  nfsidmap_SOURCES = nfsidmap.c
> -nfsidmap_LDADD = -lnfsidmap -lkeyutils ../../support/nfs/libnfs.a
> +nfsidmap_LDADD = $(LIBNFSIDMAP) -lkeyutils ../../support/nfs/libnfs.a
>  
>  MAINTAINERCLEANFILES = Makefile.in
