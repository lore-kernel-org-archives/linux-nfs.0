Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750725Ab1IZN05 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 09:26:57 -0400
Message-ID: <4E807D9D.30607@RedHat.com>
Date: Mon, 26 Sep 2011 09:26:53 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] Add a check for libdevmapper.h
References: <1317037317-4329-1-git-send-email-steved@redhat.com> <20110926122355.GB12412@umich.edu>
In-Reply-To: <20110926122355.GB12412@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/26/2011 08:23 AM, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   When NFS v4.1 is enable, the libdevemapp.h header file has to exist.
>   
>   Signed-off-by: Steve Dickson <steved@redhat.com>
>   ---
>    configure.ac |    1 +
>    1 files changed, 1 insertions(+), 0 deletions(-)
>   
>   diff --git a/configure.ac b/configure.ac
>   index 80fb39d..572b33d 100644
>   --- a/configure.ac
>   +++ b/configure.ac
>   @@ -80,6 +80,7 @@ AC_ARG_ENABLE(nfsv41,
>    			AC_MSG_ERROR([NFS v4.1 is enabled but NFS v4 is not. Use --disable-nfsv41])
>    		fi
>    		BLKMAPD=blkmapd
>   +   		AC_CHECK_HEADER(libdevmapper.h, , AC_MSG_ERROR([Cannot find libdevmapper.h header file. Try installing device-mapper-devel]))
>    	else
>    		enable_nfsv41=
>    		BLKMAPD=
> 
> On Debian based systems it's libdevmapper-dev.
> 
> Did you get the patch I sent?  I added the check farther down, with the
> other checks, and also checked for the library.
ah... no I did not but I do now... Lets go with your patch...

steved.

