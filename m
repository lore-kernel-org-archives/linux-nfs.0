Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44171 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443Ab2AZUaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 15:30:06 -0500
Date: Thu, 26 Jan 2012 15:30:06 -0500
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.gssd: Links directly with libgssapi_krb5 which not
 needed.
Message-ID: <20120126203006.GD31531@fieldses.org>
References: <1327608461-15305-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1327608461-15305-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 26, 2012 at 03:07:41PM -0500, Steve Dickson wrote:
> rpc.gssd and rpc.svcgssd both link with the libgssapi_krb5 and
> libgssglue libraries which is not needed since libgssglue
> will dynamically load the gssapi interface defined in the
> /etc/gssapi_mech.conf. Most likely the libgssapi_krb5 library.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
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

OK, so that's gathering krb5-config output which gives us the list of -l
switches we need to link in kerberos libraries, and removing the
"gssapi" argument has the effect of removing "-lgssapi_krb5" from the
output.

Ack, I guess, except: I'm a little confused why we want to link with
*any* kerberos libraries, if rpc.gssd and rpc.svcgssd are supposed to
themselves be completely mechanism-independent and are supposed to
dlopen() aything they need for kerberos.

--b.

>        K5VERS=`$K5CONFIG --version | head -n 1 | awk '{split($(4),v,"."); if (v@<:@"3"@:>@ == "") v@<:@"3"@:>@ = "0"; print v@<:@"1"@:>@v@<:@"2"@:>@v@<:@"3"@:>@ }'`
>        AC_DEFINE_UNQUOTED(KRB5_VERSION, $K5VERS, [Define this as the Kerberos version number])
>        if test -f $dir/include/gssapi/gssapi_krb5.h -a \
> -- 
> 1.7.7.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
