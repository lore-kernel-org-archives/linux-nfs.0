Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27092 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754655Ab2EQM2P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 08:28:15 -0400
Message-ID: <4FB4EEBF.3040005@RedHat.com>
Date: Thu, 17 May 2012 08:27:43 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] osd_login: fix DESTDIR install
References: <1337232243-18088-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1337232243-18088-1-git-send-email-vapier@gentoo.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/17/2012 01:24 AM, Mike Frysinger wrote:
> If the destination dir doesn't exist, the current install fails:
> make  install-data-hook
> make[4]: Entering directory `/var/tmp/portage/net-fs/nfs-utils-1.2.6/work/nfs-utils-1.2.6/utils/osd_login'
> /usr/bin/install -c --mode 755 osd_login /var/tmp/portage/net-fs/nfs-utils-1.2.6/image//sbin/osd_login
> /usr/bin/install: cannot create regular file ‘/var/tmp/portage/net-fs/nfs-utils-1.2.6/image//sbin/osd_login’: No such file or directory
> make[4]: *** [install-data-hook] Error 1
> 
> Rewrite the code to use automake's existing script support rather
> than trying to install the file by hand.
> 
> Reported-by: Branko BAdrljica <brankob@avtomatika.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>I
I took Neil's patch... commit d4d3920 which basically does
the same thing... (I believe)...  

steved.
 
> ---
>  utils/osd_login/Makefile.am |   11 +++++------
>  1 files changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/utils/osd_login/Makefile.am b/utils/osd_login/Makefile.am
> index adc493a..c85584c 100644
> --- a/utils/osd_login/Makefile.am
> +++ b/utils/osd_login/Makefile.am
> @@ -1,12 +1,11 @@
>  ## Process this file with automake to produce Makefile.in
>  
> -OSD_LOGIN_FILES= osd_login
> -
> -EXTRA_DIST= $(OSD_LOGIN_FILES)
> +# These scripts go in /sbin (not /usr/sbin), and that cannot be
> +# overriden at config time.
> +sbindir = /sbin
>  
> -all-local: $(OSD_LOGIN_FILES)
> +OSD_LOGIN_FILES= osd_login
>  
> -install-data-hook:
> -	$(INSTALL) --mode 755 osd_login $(DESTDIR)/sbin/osd_login
> +sbin_SCRIPTS= osd_login
>  
>  MAINTAINERCLEANFILES = Makefile.in
