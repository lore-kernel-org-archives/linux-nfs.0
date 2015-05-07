Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60136 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282AbbEGORX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 10:17:23 -0400
Message-ID: <554B73D8.40007@RedHat.com>
Date: Thu, 07 May 2015 10:16:56 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>
Subject: Re: [PATCH 3/3] osd_login: add --disable-osdlogin for configure osd_login
References: <552E8FE8.1070601@gmail.com>
In-Reply-To: <552E8FE8.1070601@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/15/2015 12:20 PM, Kinglong Mee wrote:
> Eino reports, 
> Configure using the following command
> 
>     ./configure --prefix=/home/username/installs/tmp --exec-prefix=/home/username/installs/tmp
> 
> When running "make install" most of the packages are put under /home/username/installs/tmp, but for some reason the install script tries to put osd_login under /sbin, which results in an error:
> 
>     Making install in osd_login
>     make[2]: Entering directory `/home/username/installs/nfs-utils-1.3.2/utils/osd_login'
>     make[3]: Entering directory `/home/username/installs/nfs-utils-1.3.2/utils/osd_login'
>         /usr/bin/mkdir -p '/sbin'
>         /usr/bin/install -c osd_login '/sbin'
>         /usr/bin/install: cannot remove ‘/sbin/osd_login’: Permission denied
>         make[3]: *** [install-dist_sbinSCRIPTS] Error 1 
> 
> Reported-by: Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
I changed this just a bit... Instead of disabling it, I change
it to enable the installation which is 'no' by default.

Committed... 

steved.
 
> ---
>  configure.ac      | 7 +++++++
>  utils/Makefile.am | 5 ++++-
>  2 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/configure.ac b/configure.ac
> index d4301a2..33a2f57 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -216,6 +216,13 @@ AC_ARG_ENABLE(nfsdcltrack,
>  	enable_nfsdcltrack=$enableval,
>  	enable_nfsdcltrack="yes")
>  
> +AC_ARG_ENABLE(osdlogin,
> +	[AC_HELP_STRING([--disable-osdlogin],
> +			[disable osd_login scripts @<:@default=no@:>@])],
> +	enable_osdlogin=$enableval,
> +	enable_osdlogin="yes")
> +	AM_CONDITIONAL(CONFIG_OSD_LOGIN, [test "$enable_osdlogin" = "yes" ])
> +
>  dnl Check for TI-RPC library and headers
>  AC_LIBTIRPC
>  
> diff --git a/utils/Makefile.am b/utils/Makefile.am
> index b892dc8..6dd4a57 100644
> --- a/utils/Makefile.am
> +++ b/utils/Makefile.am
> @@ -25,6 +25,10 @@ if CONFIG_NFSDCLTRACK
>  OPTDIRS += nfsdcltrack
>  endif
>  
> +if CONFIG_OSD_LOGIN
> +OPTDIRS += osd_login
> +endif
> +
>  SUBDIRS = \
>  	exportfs \
>  	mountd \
> @@ -32,7 +36,6 @@ SUBDIRS = \
>  	nfsstat \
>  	showmount \
>  	statd \
> -	osd_login \
>  	$(OPTDIRS)
>  
>  MAINTAINERCLEANFILES = Makefile.in
> 
