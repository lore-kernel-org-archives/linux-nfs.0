Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924Ab3KGQq7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Nov 2013 11:46:59 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rA7GkxMj019867
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 7 Nov 2013 11:46:59 -0500
Message-ID: <527BC43B.5070405@RedHat.com>
Date: Thu, 07 Nov 2013 11:47:55 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: cut down log chatter in gssd_search_krb5_keytab
References: <1383839253-8223-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1383839253-8223-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

My thoughts... 

On 07/11/13 10:47, Jeff Layton wrote:
> Because the kernel now looks for krb5 creds by default when mounting, we
> need to always have clients run rpc.gssd to avoid the 15s hang on the
> first mount attempt.
> 
> In situations however where people don't have krb5 set up, this leads to
> a lot of log spamming on mount attempts. Try to cut down on some of the
> log chatter by lowering the priority of the log messages in
> gssd_search_krb5_keytab().
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/gssd/krb5_util.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 697d1d2..2ca3adc 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -711,13 +711,13 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
>  	 */
>  	if ((code = krb5_kt_get_name(context, kt, kt_name, BUFSIZ))) {
>  		k5err = gssd_k5_err_msg(context, code);
> -		printerr(0, "ERROR: %s attempting to get keytab name\n", k5err);
> +		printerr(1, "ERROR: %s attempting to get keytab name\n", k5err);
>  		retval = code;
>  		goto out;
>  	}
>  	if ((code = krb5_kt_start_seq_get(context, kt, &cursor))) {
>  		k5err = gssd_k5_err_msg(context, code);
> -		printerr(0, "ERROR: %s while beginning keytab scan "
> +		printerr(1, "ERROR: %s while beginning keytab scan "
>  			    "for keytab '%s'\n", k5err, kt_name);
>  		retval = code;
>  		goto out;
I'm thinking these need to stay... I don't think is a good idea 
to mask out messages describing failures...
 
> @@ -727,7 +727,7 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
>  		if ((code = krb5_unparse_name(context, kte->principal,
>  					      &pname))) {
>  			k5err = gssd_k5_err_msg(context, code);
> -			printerr(0, "WARNING: Skipping keytab entry because "
> +			printerr(1, "WARNING: Skipping keytab entry because "
>  				 "we failed to unparse principal name: %s\n",
>  				 k5err);
>  			k5_free_kt_entry(context, kte);
> @@ -768,7 +768,7 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
>  
>  	if ((code = krb5_kt_end_seq_get(context, kt, &cursor))) {
>  		k5err = gssd_k5_err_msg(context, code);
> -		printerr(0, "WARNING: %s while ending keytab scan for "
> +		printerr(1, "WARNING: %s while ending keytab scan for "
>  			    "keytab '%s'\n", k5err, kt_name);
>  	}
I think warnings would be ok to mask out... 

steved.

>  
> 
