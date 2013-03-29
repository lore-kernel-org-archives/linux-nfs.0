Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755094Ab3C2New (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Mar 2013 09:34:52 -0400
Subject: Re: [PATCH] Fix compilation against Heimdal kerberos implementation
From: Simo Sorce <simo@redhat.com>
To: oakad@yahoo.com
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <1364550512-14832-1-git-send-email-oakad@yahoo.com>
References: <1364550512-14832-1-git-send-email-oakad@yahoo.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Mar 2013 09:34:50 -0400
Message-ID: <1364564090.2660.303.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-03-29 at 20:48 +1100, oakad@yahoo.com wrote:
> From: Alex Dubov <oakad@yahoo.com>
> 
> There appear to be only 3 issues remaining with Heimdal after removal of
> compulsory dependency on libgssglue:
> 
> 1. On some systems, only libroken.so is available (small fix to kerberos5.m4)
> 
> 2. krb5_util.c:check_for_target - Heimdal variant constructs a "pattern"
>    principal and uses krb5_cc_retrieve_cred to get a matching credential.
>    This should work on mit-krb5, so old method of iterating over every
>    credential in cache may possibly be dropped outright and "#$if" guard
>    omitted.
>    For the sake of the above I reformatted the old approach to make it a bit
>    more clear what's going on there.
> 
> 3. krb5_util.c:gssd_k5_err_msg - krb5_get_err_text is marked as deprecated,
>    at least on Heimdal. If krb5_get_error_message is available, it should not
>    be reached at all, thus "#elif" guard.
> 
> Signed-off-by: Alex Dubov <oakad@yahoo.com>
> ---
>  aclocal/kerberos5.m4   |    7 +++--
>  utils/gssd/krb5_util.c |   55 ++++++++++++++++++++++++++++++++++++-----------
>  2 files changed, 46 insertions(+), 16 deletions(-)
> 
> diff --git a/aclocal/kerberos5.m4 b/aclocal/kerberos5.m4
> index 0bf35d3..ebf6f20 100644
> --- a/aclocal/kerberos5.m4
> +++ b/aclocal/kerberos5.m4
> @@ -56,9 +56,10 @@ AC_DEFUN([AC_KERBEROS_V5],[
>           break
>        dnl The following ugly hack brought on by the split installation
>        dnl of Heimdal Kerberos on SuSe
> -      elif test \( -f $dir/include/heim_err.h -o\
> -      		 -f $dir/include/heimdal/heim_err.h \) -a \
> -                -f $dir/lib/libroken.a; then
> +      elif test \( \( -f $dir/include/heim_err.h -o\
> +                      -f $dir/include/heimdal/heim_err.h \) -a \
> +                   \( -f $dir/lib/libroken.a -o\
> +                      -f $dir/lib/libroken.so \) \) ; then
>           AC_DEFINE(HAVE_HEIMDAL, 1, [Define this if you have Heimdal Kerberos libraries])
>           KRBDIR="$dir"
>           gssapi_lib=gssapi

This hunk looks good.

> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 20b55b3..adef268 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -958,29 +958,57 @@ check_for_tgt(krb5_context context, krb5_ccache ccache,
>  {
>  	krb5_error_code ret;
>  	krb5_creds creds;
> -	krb5_cc_cursor cur;
>  	int found = 0;
>  
> +#if HAVE_HEIMDAL
> +	krb5_creds pattern;
> +	krb5_const_realm client_realm;
> +
> +	krb5_cc_clear_mcred(&pattern);
> +
> +	client_realm = krb5_principal_get_realm(context, principal);
> +
> +	ret = krb5_make_principal(context, &pattern.server,
> +				  client_realm, KRB5_TGS_NAME, client_realm,
> +				  NULL);
> +	if (ret) {
> +		krb5_err(context, 1, ret, "krb5_make_principal");
> +		return 0;
> +	}
> +
> +	pattern.client = principal;
> +
> +	ret = krb5_cc_retrieve_cred(context, ccache, 0, &pattern, &creds);
> +	krb5_free_principal(context, pattern.server);
> +
> +	if (ret) {
> +		if (ret != KRB5_CC_END)
> +			krb5_err(context, 1, ret, "krb5_cc_retrieve_cred");
> +	} else
> +		found = creds.times.endtime > time(NULL);
> +
> +	krb5_free_cred_contents(context, &creds);
> +#else
> +	krb5_cc_cursor cur;
>  	ret = krb5_cc_start_seq_get(context, ccache, &cur);
>  	if (ret) 
>  		return 0;

krb5_cc_retrieve_cred is available in MIT too, I would try to avoid
using ifedfs here and come up with common code that works for both to
avoid bugs that may cause different behavior in parallel code paths
depending on which library is used.

 
>  	while (!found &&
>  		(ret = krb5_cc_next_cred(context, ccache, &cur, &creds)) == 0) {
> -		if (creds.server->length == 2 &&
> -				data_is_equal(creds.server->realm,
> -					      principal->realm) &&
> -				creds.server->data[0].length == 6 &&
> -				memcmp(creds.server->data[0].data,
> -						"krbtgt", 6) == 0 &&
> -				data_is_equal(creds.server->data[1],
> -					      principal->realm) &&
> -				creds.times.endtime > time(NULL))
> -			found = 1;
> +		if (
> +			creds.server->length == 2
> +			&& data_is_equal(creds.server->realm, principal->realm)
> +			&& creds.server->data[0].length == 6
> +			&& memcmp(creds.server->data[0].data, "krbtgt", 6) == 0
> +			&& data_is_equal(creds.server->data[1],
> +					 principal->realm)
> +			&& creds.times.endtime > time(NULL)
> +		) found = 1;

This looks like just gratuitous re-indentation, I would drop it it's not
needed and makes the patch bigger.

>  		krb5_free_cred_contents(context, &creds);
>  	}
>  	krb5_cc_end_seq_get(context, ccache, &cur);
> -
> +#endif
>  	return found;
>  }
>  
> @@ -1326,12 +1354,13 @@ gssd_k5_err_msg(krb5_context context, krb5_error_code code)
>  		return msg;
>  #if HAVE_KRB5
>  	return strdup(error_message(code));
> -#else
> +#elif !HAVE_KRB5_GET_ERROR_MESSAGE
>  	if (context != NULL)
>  		return strdup(krb5_get_err_text(context, code));
>  	else
>  		return strdup(error_message(code));
>  #endif
> +	return NULL;

MIT doesn't have krb5_get_err_text at all so it shouldn't be tried out
at all if MIT is available.

I think you should ratrher add a keberos.m4 macro to check for
krb5_get_err_text then change this to something like:

char *msg = NULL;

#if HAVE_KRB5_GET_ERROR_MESSAGE
	... <- same code as in the current tree
#elif HAVE_KRB_GET_ERR_TEXT
	... <- code in current else branch of 'if HAVE_KRB5'
#else
	msg = strdup(error_message(code));
#endif
	return msg;

>  }
>  
>  /*


HTH,
Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

