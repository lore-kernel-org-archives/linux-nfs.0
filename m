Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485Ab2CVTVZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 15:21:25 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2MJLPlJ008079
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 22 Mar 2012 15:21:25 -0400
Message-ID: <4F6B7BAF.1070900@RedHat.com>
Date: Thu, 22 Mar 2012 15:21:19 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.gssd: Links directly with libgssapi_krb5 which not
 needed.
References: <1327608461-15305-1-git-send-email-steved@redhat.com>
In-Reply-To: <1327608461-15305-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/26/2012 03:07 PM, Steve Dickson wrote:
> rpc.gssd and rpc.svcgssd both link with the libgssapi_krb5 and
> libgssglue libraries which is not needed since libgssglue
> will dynamically load the gssapi interface defined in the
> /etc/gssapi_mech.conf. Most likely the libgssapi_krb5 library.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

> ---
>  aclocal/kerberos5.m4 |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/aclocal/kerberos5.m4 b/aclocal/kerberos5.m4
> index dfa5738..7574e2d 100644
> --- a/aclocal/kerberos5.m4
> +++ b/aclocal/kerberos5.m4
> @@ -31,7 +31,7 @@ AC_DEFUN([AC_KERBEROS_V5],[
>      fi
>      if test "$K5CONFIG" != ""; then
>        KRBCFLAGS=`$K5CONFIG --cflags`
> -      KRBLIBS=`$K5CONFIG --libs gssapi`
> +      KRBLIBS=`$K5CONFIG --libs`
>        K5VERS=`$K5CONFIG --version | head -n 1 | awk '{split($(4),v,"."); if (v@<:@"3"@:>@ == "") v@<:@"3"@:>@ = "0"; print v@<:@"1"@:>@v@<:@"2"@:>@v@<:@"3"@:>@ }'`
>        AC_DEFINE_UNQUOTED(KRB5_VERSION, $K5VERS, [Define this as the Kerberos version number])
>        if test -f $dir/include/gssapi/gssapi_krb5.h -a \
