Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E7D9C10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 19:41:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EAD992084D
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 19:41:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726629AbfDKTlD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 15:41:03 -0400
Received: from mx1.redhat.com ([209.132.183.28]:41800 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726577AbfDKTlD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 Apr 2019 15:41:03 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 98A1630020CD;
        Thu, 11 Apr 2019 19:41:02 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-118-23.phx2.redhat.com [10.3.118.23])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 0FDC2600CC;
        Thu, 11 Apr 2019 19:41:01 +0000 (UTC)
Subject: Re: [PATCH v2] [cthon04] fix typo and fix make failure on ubuntu
To:     "Jianhong.Yin" <yin-jianhong@163.com>
Cc:     ben@swartzlander.org, linux-nfs@vger.kernel.org
References: <20190403033813.12333-1-yin-jianhong@163.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <e961f95d-b370-76ab-7470-8afb47df6f61@RedHat.com>
Date:   Thu, 11 Apr 2019 15:41:01 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190403033813.12333-1-yin-jianhong@163.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 11 Apr 2019 19:41:02 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 4/2/19 11:38 PM, Jianhong.Yin wrote:
> based on git://git.linux-nfs.org/projects/steved/cthon04.git
> test pass on:
>   RHEL-8 RHEL-7 RHEL-6 RHEL-5 and RHEL-4
>   Debian-9 Ubuntu-18.10
>   OpenSUSE Tumbleweed
>   Slackware 14.2
> 
> Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
Committed... 

steved.

> ---
>  Makefile      |  4 +--
>  tests.init    | 77 ---------------------------------------------------
>  tests.init.sh | 26 +++++++++--------
>  3 files changed, 16 insertions(+), 91 deletions(-)
>  delete mode 100644 tests.init
> 
> diff --git a/Makefile b/Makefile
> index 9fd76d9..dc12956 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -13,7 +13,7 @@ COPYFILES=runtests tests.init server domount.c README READWIN.txt Testitems \
>  	getopt.c tests.h unixdos.h cthon04.spec
>  
>  # generate tests.init file
> -$(shell ./tests.init.sh)
> +$(shell ./tests.init.sh $(FSTYPE) $(OS))
>  
>  include tests.init
>  
> @@ -78,4 +78,4 @@ mknewdirs:
>  
>  .PHONY: tests.init
>  tests.init:
> -	sh ./tests.init.sh
> +	sh ./tests.init.sh $(FSTYPE) $(OS)
> diff --git a/tests.init b/tests.init
> deleted file mode 100644
> index b2f642f..0000000
> --- a/tests.init
> +++ /dev/null
> @@ -1,77 +0,0 @@
> -#
> -#       @(#)tests.init	1.26 2003/12/30 Connectathon testsuite
> -#
> -MNTOPTIONS="rw,hard,intr"
> -# Dummy MNTPOINT definition; should get overriden by server script.
> -MNTPOINT="/mnt"
> -
> -SERVER=""
> -SERVPATH="/server"
> -TEST="-a"
> -TESTARG="-t"
> -
> -# set MOUNTCMD and UMOUNTCMD
> -# Use this mount command if using:
> -#	BSD
> -#	SunOS 4.X
> -#	Tru64 UNIX
> -#	HPUX
> -#	Linux
> -#	AIX
> -#	Mac OS X
> -# At least some BSD systems don't recognize "hard" (since that's the
> -# default), so you might also want to use this definition of MNTOPTIONS.
> -MNTOPTIONS="rw,intr"
> -MOUNTCMD='./domount -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
> -UMOUNTCMD='./domount -u $MNTPOINT'
> -
> -# set DASHN and BLC
> -# Use the next two lines if using:
> -#	BSD
> -#	SunOS 4.X
> -#	Linux
> -#	Tru64 UNIX
> -#	Mac OS X
> -DASHN=-n
> -BLC=
> -
> -# set PATH
> -# Use this path for:
> -#	Tru64 UNIX
> -#	SVR4
> -#	Linux
> -PATH=/bin:/usr/bin:/usr/ucb:/usr/ccs/bin:/sbin:/usr/sbin:.
> -
> -# -----------------------------------------------
> -# Defines for various variables used in scripts and makefiles.
> -#
> -# Do not remove the following three lines.  They may be overridden by
> -# other configuration parameters lower in this file, but these three
> -# variables must be defined.
> -CC=cc
> -CFLAGS=
> -LIBS=
> -LOCKTESTS=tlock
> -MOUNT=/bin/mount
> -UMOUNT=/bin/umount
> -LOCKTESTS=`echo tlocklfs tlock64`
> -
> -# Use with Linux if your distro doesn't provide a "cc".
> -CC=gcc
> -
> -# Use with Linux 2.2 / GNU libc 2.0
> -#CFLAGS=`echo -DLINUX -DGLIBC=20 -DMMAP -DSTDARG -fwritable-strings`
> -#LIBS=`echo -lnsl`
> -
> -# Use with Linux 2.4 / GNU libc 2.2
> -#CFLAGS=`echo -DLINUX -DGLIBC=22 -DMMAP -DSTDARG -fwritable-strings`
> -#LIBS=`echo -lnsl`
> -
> -# Use with Linux 2.6 / gcc 4.0
> -CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
> -LIBS=`echo -lnsl`
> -
> -# Use with Linux glibc > 2.26
> -CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
> -CFLAGS+=`pkg-config --cflags libtirpc`
> -LIBS=`pkg-config --libs libtirpc`
> diff --git a/tests.init.sh b/tests.init.sh
> index 778206f..fe90e42 100755
> --- a/tests.init.sh
> +++ b/tests.init.sh
> @@ -1,16 +1,16 @@
>  #!/bin/sh
>  
> -OS=${1:-Linux}
> -FSTYPE=$${2:-nfs}
> +FSTYPE=${1:-nfs}
> +OS=${2:-`uname -s`}
>  Initfile=tests.init
>  
> -cat <<\EOF >$Initfile
> +cat <<EOF >$Initfile
>  #
>  #       @(#)tests.init	1.26 2003/12/30 Connectathon testsuite
>  #
>  MNTOPTIONS="rw,hard,intr"
>  # Dummy MNTPOINT definition; should get overriden by server script.
> -MNTPOINT="/mnt"
> +MNTPOINT="/mnt/$FSTYPE"
>  
>  SERVER=""
>  SERVPATH="/server"
> @@ -38,7 +38,7 @@ MOUNTCMD='./domount -F nfs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
>  CFSMOUNTCMD='./domount -F cachefs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
>  EOF
>  ;;
> -BSD|SunOS4.x|Tru64UNIX|HPUX|Linux|AIX|MacOSX)
> +*BSD|SunOS4.x|Tru64UNIX|HPUX|Linux|AIX|MacOSX)
>  cat <<\EOF >>$Initfile
>  # Use this mount command if using:
>  #	BSD
> @@ -89,7 +89,7 @@ DASHN=
>  BLC=\\c
>  EOF
>  ;;
> -BSD|SunOS4.x|Linux|Tru64UNIX|MacOSX)
> +*BSD|SunOS4.x|Linux|Tru64UNIX|MacOSX)
>  cat <<\EOF >>$Initfile
>  # Use the next two lines if using:
>  #	BSD
> @@ -105,7 +105,7 @@ esac
>  
>  # set PATH
>  echo >>$Initfile
> -echo -e "# set PATH" >>$Initfile
> +echo "# set PATH" >>$Initfile
>  case $OS in
>  Solaris2.x)
>  cat <<\EOF >>$Initfile
> @@ -129,7 +129,7 @@ PATH=/bin:/usr/bin:/etc:/usr/etc:/usr/local/bin:/usr/contrib/bin:.
>  EOF
>  ;;
>  
> -BSD|SunOS4.x)
> +*BSD|SunOS4.x)
>  cat <<\EOF >>$Initfile
>  # Use this path for:
>  #	BSD
> @@ -211,10 +211,10 @@ LIBS=`echo -lrpc -lsocket`
>  EOF
>  ;;
>  
> -BSD)
> +*BSD)
>  cat <<\EOF >>$Initfile
>  # Use with BSD systems.
> -CC=gcc
> +CC=cc
>  CFLAGS=`echo -Duse_directs -DBSD`
>  MOUNT=/sbin/mount
>  UMOUNT=/sbin/umount
> @@ -375,7 +375,10 @@ LIBS=`echo -lnsl`
>  
>  EOF
>  
> -if [ glibc-2.26 = `{ rpm -qf /etc/ld.so.conf; echo glibc-2.26; } | sort | head -n1` ]; then
> +glibc_version_base=2.26
> +glibc_version_current=`ldd --version|sed -n '1{s/.* //;p}'`
> +glibc_version_older=`{ echo $glibc_version_base; echo $glibc_version_current; } | sort | head -n1`
> +if [ "$glibc_version_older" = "$glibc_version_base" ]; then
>  	cat <<\EOF >>$Initfile
>  # Use with Linux glibc > 2.26
>  CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
> @@ -387,4 +390,3 @@ fi
>  ;;
>  esac
>  
> -
> 
