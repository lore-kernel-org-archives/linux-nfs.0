Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab1IQNZV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Sep 2011 09:25:21 -0400
Message-ID: <4E749FBC.5090609@RedHat.com>
Date: Sat, 17 Sep 2011 09:25:16 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] nfs-utils/blkmapd: Add complex block layout discovery
 and mapping daemon
References: <1313086848-7435-1-git-send-email-rees@umich.edu>
In-Reply-To: <1313086848-7435-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Jim,

My apologies for taking so long to get to this... For some
reason I never added to my TODO list... That problem has
been resolved... 
 

On 08/11/2011 02:20 PM, Jim Rees wrote:
> This daemon is required to handle upcalls from the kernel pnfs block layout
> driver.
> 
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  .gitignore                       |    1 +
>  configure.ac                     |    4 +
>  utils/Makefile.am                |    4 +
>  utils/blkmapd/Makefile.am        |   19 ++
>  utils/blkmapd/blkmapd.man        |   54 ++++
>  utils/blkmapd/device-discovery.c |  453 +++++++++++++++++++++++++++++++++
>  utils/blkmapd/device-discovery.h |  162 ++++++++++++
>  utils/blkmapd/device-inq.c       |  233 +++++++++++++++++
>  utils/blkmapd/device-process.c   |  407 ++++++++++++++++++++++++++++++
>  utils/blkmapd/dm-device.c        |  518 ++++++++++++++++++++++++++++++++++++++
>  10 files changed, 1855 insertions(+), 0 deletions(-)
>  create mode 100644 utils/blkmapd/Makefile.am
>  create mode 100644 utils/blkmapd/blkmapd.man
>  create mode 100644 utils/blkmapd/device-discovery.c
>  create mode 100644 utils/blkmapd/device-discovery.h
>  create mode 100644 utils/blkmapd/device-inq.c
>  create mode 100644 utils/blkmapd/device-process.c
>  create mode 100644 utils/blkmapd/dm-device.c
> 
> diff --git a/.gitignore b/.gitignore
> index f5b5cf0..7bd9921 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -36,6 +36,7 @@ support/include/stamp-h1
>  lib*.a
>  tools/rpcgen/rpcgen
>  tools/rpcdebug/rpcdebug
> +utils/blkmapd/blkmapd
>  utils/exportfs/exportfs
>  utils/idmapd/idmapd
>  utils/lockd/lockd
> diff --git a/configure.ac b/configure.ac
> index c9fb27b..08ef029 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -64,11 +64,14 @@ AC_ARG_ENABLE(nfsv4,
>  	enable_nfsv4=yes)
>  	if test "$enable_nfsv4" = yes; then
>  		AC_DEFINE(NFS4_SUPPORTED, 1, [Define this if you want NFSv4 support compiled in])
> +		BLKMAPD=blkmapd
>  		IDMAPD=idmapd
>  	else
>  		enable_nfsv4=
> +		BLKMAPD=
>  		IDMAPD=
>  	fi
> +	AC_SUBST(BLKMAPD)
You are adding the BLKMAPD to the "if nfsv4 is enabled" clause but it really
should be added to the "if nfsv41 is enabled" clause. Currently that option 
controls v4.1 support in the server, which is off by default since the 
v4.1 server code is not quite ready for prime time... 

So what I would like to do is create a "if nfsdv41 is enabled" clause
that will enable/disable the v4.1 server, which will be off by default. 
Then have the blkmapd code enable/disable by the current "if nfsv41 
is enabled" clause, which will be on my default.

So I will make the enable_nfsv41 ==> enable_nfsdv41 change in 
the next rc release, alone with some other outstanding changes.
After that rc release, I'll commit this code and then make a minor 
release, 1.2.5, that will have this code on by default.

Sound reasonable?

Again, my apologizes for the delay... 

steved.

