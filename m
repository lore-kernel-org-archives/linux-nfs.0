Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15053 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755618Ab3DBSHo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 14:07:44 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r32I7i56008721
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 14:07:44 -0400
Subject: Re: Allow building nfs-utils directly against GSSAPI
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        =?ISO-8859-1?Q?G=FCnther?= Deschner <gdeschne@redhat.com>
In-Reply-To: <515B1C1F.6030907@RedHat.com>
References: <1364317202.2660.132.camel@willson.li.ssimo.org>
	 <515B1C1F.6030907@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Apr 2013 14:07:43 -0400
Message-ID: <1364926063.2660.1269.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-02 at 13:57 -0400, Steve Dickson wrote:
> Again using git send-email to post your patches would make this
> a lot easier... ;-) 

Will do from here on.

> On 26/03/13 13:00, Simo Sorce wrote:
> > Libgssglue is not really useful anymore, it is a sort of middleman that
> > wraps the actual GSSAPI that is already pluggable/extensible via shared
> > modules.
> > 
> > In particular libgssglue interferes with the workings of gss-proxy in my
> > case.
> > 
> > The attached patch makes building against libgssglue optional and
> > defaults to not build against libgssglue and instead builds directly
> > against the native GSSAPI.
> > 
> > ./configure --enable-gss
> > will now build against GSSAPI
> > 
> > ./configure --enable-gss --with-gssglue
> > will keep building against libgssglue in case someone still needs it for
> > whatever reason.
> >
> in he first patch you define HAVE_GSS_KRB5_FREE_LUCID_SEC_CONTEXT
> which is good:
> 
> --- a/aclocal/kerberos5.m4
> +++ b/aclocal/kerberos5.m4
> @@ -92,6 +92,8 @@ AC_DEFUN([AC_KERBEROS_V5],[
>      AC_DEFINE(HAVE_SET_ALLOWABLE_ENCTYPES, 1, [Define this if the Kerberos GSS library supports gss_krb5_set_allowable_enctypes]), ,$KRBLIBS)
>    AC_CHECK_LIB($gssapi_lib, gss_krb5_ccache_name,
>      AC_DEFINE(HAVE_GSS_KRB5_CCACHE_NAME, 1, [Define this if the Kerberos GSS library supports gss_krb5_ccache_name]), ,$KRBLIBS)
> +  AC_CHECK_LIB($gssapi_lib, gss_krb5_free_lucid_sec_context,
> +    AC_DEFINE(HAVE_GSS_KRB5_FREE_LUCID_SEC_CONTEXT, 1, [Define this if the Kerberos GSS library supports gss_krb5_free_lucid_sec_context]), ,$KRBLIBS)
> 
>    dnl Check for newer error message facility
>    AC_CHECK_LIB($gssapi_lib, krb5_get_error_message,
> 
> But in the second patch you use a non-existent define  HAVE_LIBGSSGLUE.
> Why not just use HAVE_GSS_KRB5_FREE_LUCID_SEC_CONTEXT?

Because the mere fact the native GSSAPI library have that function is
not the decisive factor we use to determine against what we want to
compile.

It's true that after I reordered patches the definition of
HAVE_LIBGSSGLUE ended up in the 3rd patch, but that is a venial problem
I hope.

> --- a/utils/gssd/gss_util.h
> +++ b/utils/gssd/gss_util.h
> @@ -42,4 +42,14 @@ void pgsserr(char *msg, u_int32_t maj_stat, u_int32_t min_stat,
>  	const gss_OID mech);
>  int gssd_check_mechs(void);
>  
> +#ifndef HAVE_LIBGSSGLUE
> +#include <gssapi/gssapi_krb5.h>
> +#define gss_free_lucid_sec_context(min, ctx, ret) \
> +		gss_krb5_free_lucid_sec_context(min, ret)
> +
> +#define gss_export_lucid_sec_context gss_krb5_export_lucid_sec_context
> +#define gss_set_allowable_enctypes(min, cred, oid, num, types) \
> +		gss_krb5_set_allowable_enctypes(min, cred, num, types)
> +#endif
> +
> Personally I like the way Alex handled this in his patch better..

The way Alex handled it makes it impossible to build against libgssglue,
and I have not removed libgssglue just made it optional.

This way is not pretty but allows to still compile against libgssglue if
needed.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

