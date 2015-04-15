Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32980 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755844AbbDOPle (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2015 11:41:34 -0400
Received: by paboj16 with SMTP id oj16so55069676pab.0
        for <linux-nfs@vger.kernel.org>; Wed, 15 Apr 2015 08:41:33 -0700 (PDT)
Message-ID: <552E86A8.6080506@gmail.com>
Date: Wed, 15 Apr 2015 23:41:28 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>, linux-nfs@vger.kernel.org
Subject: Re: Problem installing nfs-utils to non standard dir
References: <552E3508.5000403@fys.uio.no>
In-Reply-To: <552E3508.5000403@fys.uio.no>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/15/2015 5:53 PM, Eino Juhani Oltedal wrote:
> Hi!
> 
> I'm trying to build nfs from source. I'm using nfs-utils-1.3.2 from http://sourceforge.net/projects/nfs/files/nfs-utils/1.3.2/.
> I configure using the following command
> 
>     ./configure --prefix=/home/username/installs/tmp --exec-prefix=/home/username/installs/tmp
> 
> When i run "make install" most of the packages are put under /home/username/installs/tmp, but for some reason the
> install script tries to put osd_login under /sbin, which results in an error:
> 
>     Making install in osd_login
>     make[2]: Entering directory `/home/username/installs/nfs-utils-1.3.2/utils/osd_login'
>     make[3]: Entering directory `/home/username/installs/nfs-utils-1.3.2/utils/osd_login'
>         /usr/bin/mkdir -p '/sbin'
>         /usr/bin/install -c osd_login '/sbin'
>         /usr/bin/install: cannot remove ‘/sbin/osd_login’: Permission denied
>         make[3]: *** [install-dist_sbinSCRIPTS] Error 1
> 
> This is not supposed to happen, is it?

No, it is.
There are three utils (mount.nfs/mount.nfs4, nfsdcltrack and osd_login)
must be installed in directory /sbin/, they are hard-coded.

> Is there an easy way to fix it? I get the same error trying to build nfs-utils-1.3.1 as well.

No, they are must installed in /sbin/ for kernel module nfsd.ko needing
/sbin/nfsdcltrack and objlayoutdriver.ko needing /sbin/osd_login.

You can not skip this problem with recently source.
if you are hurry， you can avoid this problem with the following patch and configure as,

# ./configure --disable-mount --disable-nfsdcltrack --disable-osdlogin --prefix=/root/test --exec-prefix=/root/test/

Ps: It is just a draft made by diff. I will send some patches for this problem.

thanks,
Kinglong Mee

===================================================================
diff --git a/configure.ac b/configure.ac
index e61430f..294e7a3 100644
--- a/configure.ac
+++ b/configure.ac
@@ -213,9 +213,16 @@ fi
 AC_ARG_ENABLE(nfsdcltrack,
 	[AC_HELP_STRING([--disable-nfsdcltrack],
 			[disable NFSv4 clientid tracking programs @<:@default=no@:>@])],
-	enable_nfsdctrack=$enableval,
+	enable_nfsdcltrack=$enableval,
 	enable_nfsdcltrack="yes")
 
+AC_ARG_ENABLE(osdlogin,
+	[AC_HELP_STRING([--disable-osdlogin],
+			[disable osd_login scripts @<:@default=no@:>@])],
+	enable_osdlogin=$enableval,
+	enable_osdlogin="yes")
+	AM_CONDITIONAL(CONFIG_OSD_LOGIN, [test "$enable_osdlogin" = "yes" ])
+
 dnl Check for TI-RPC library and headers
 AC_LIBTIRPC
 
@@ -346,7 +353,7 @@ AC_SUBST(LIBBSD)
 AC_SUBST(LIBBLKID)
 AC_SUBST(LIBDL)
 
-if test "$enable_libmount" != no; then
+if test "$enable_libmount" = yes; then
    AC_CHECK_LIB(mount, mnt_context_do_mount, [LIBMOUNT="-lmount"], AC_MSG_ERROR([libmount needed]))
    AC_CHECK_HEADER(libmount/libmount.h, , AC_MSG_ERROR([Cannot find libmount header file libmount/libmount.h]))
 fi
diff --git a/utils/Makefile.am b/utils/Makefile.am
index b892dc8..6dd4a57 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -25,6 +25,10 @@ if CONFIG_NFSDCLTRACK
 OPTDIRS += nfsdcltrack
 endif
 
+if CONFIG_OSD_LOGIN
+OPTDIRS += osd_login
+endif
+
 SUBDIRS = \
 	exportfs \
 	mountd \
@@ -32,7 +36,6 @@ SUBDIRS = \
 	nfsstat \
 	showmount \
 	statd \
-	osd_login \
 	$(OPTDIRS)
 
 MAINTAINERCLEANFILES = Makefile.in
