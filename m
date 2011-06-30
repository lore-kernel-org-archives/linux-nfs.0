Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751115Ab1F3PYZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 11:24:25 -0400
Message-ID: <4E0C9527.9060503@RedHat.com>
Date: Thu, 30 Jun 2011 11:24:23 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Add requirement for newer libgssglue for svcgssd -n option
References: <20110629183721.23198.57774.stgit@jazz.citi.umich.edu>
In-Reply-To: <20110629183721.23198.57774.stgit@jazz.citi.umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/29/2011 02:37 PM, Kevin Coffman wrote:
> SNAFU.  This came to my attention minutes after 1.2.4 was
> released...
> 
> Changes in commit d6c1b35c require that gss_acquire_cred()
> is now called when the "-n" option is used.  This requires an
> updated libgssglue which properly handles name GSS_C_NO_NAME
> as input to gss_import_name()/gss_acquire_cred().
> 
> Add a requirement for the newer version.
> 
> Without the newer libgssglue, when svcgssd is started with "-n"
> you will see the error message, "ERROR: GSS-API: error in
> gss_acquire_cred(): GSS_S_BAD_NAME (An invalid name was supplied)
> - Unknown error"
> ---
Committed.. Unfortunately post 1.2.4 release... 

steved.

> 
>  aclocal/rpcsec_vers.m4 |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/aclocal/rpcsec_vers.m4 b/aclocal/rpcsec_vers.m4
> index 25902ca..8218372 100644
> --- a/aclocal/rpcsec_vers.m4
> +++ b/aclocal/rpcsec_vers.m4
> @@ -1,7 +1,7 @@
>  dnl Checks librpcsec version
>  AC_DEFUN([AC_RPCSEC_VERSION], [
>  
> -  PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.1])
> +  PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.3])
>  
>    dnl TI-RPC replaces librpcsecgss
>    if test "$enable_tirpc" = no; then
> 
