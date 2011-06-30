Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:47312 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373Ab1F3AiD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2011 20:38:03 -0400
Received: by vws1 with SMTP id 1so1282216vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 17:38:02 -0700 (PDT)
In-Reply-To: <20110629183721.23198.57774.stgit@jazz.citi.umich.edu>
References: <20110629183721.23198.57774.stgit@jazz.citi.umich.edu>
Date: Wed, 29 Jun 2011 20:38:02 -0400
Message-ID: <BANLkTikn_jCcE3ND+KCdbDpfLyXYDEaD3Q@mail.gmail.com>
Subject: Re: [PATCH] Add requirement for newer libgssglue for svcgssd -n option
From: Kevin Coffman <kwc@citi.umich.edu>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jun 29, 2011 at 2:37 PM, Kevin Coffman <kwc@citi.umich.edu> wrote:
> SNAFU.  This came to my attention minutes after 1.2.4 was
> released...
>
> Changes in commit d6c1b35c require that gss_acquire_cred()
> is now called when the "-n" option is used.  This requires an
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
>
>  aclocal/rpcsec_vers.m4 |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/aclocal/rpcsec_vers.m4 b/aclocal/rpcsec_vers.m4
> index 25902ca..8218372 100644
> --- a/aclocal/rpcsec_vers.m4
> +++ b/aclocal/rpcsec_vers.m4
> @@ -1,7 +1,7 @@
>  dnl Checks librpcsec version
>  AC_DEFUN([AC_RPCSEC_VERSION], [
>
> -  PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.1])
> +  PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.3])
>
>   dnl TI-RPC replaces librpcsecgss
>   if test "$enable_tirpc" = no; then
>

I just realized that I failed to add a Signed-off-by: in both patches
I sent today.  Let me know if you need me to resend them...

K.C.
