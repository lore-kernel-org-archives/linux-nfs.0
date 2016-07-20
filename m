Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753212AbcGTPNi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jul 2016 11:13:38 -0400
Subject: Re: [PATCH] Gssd: Avoid compiling warning and simplify codes
To: Kinglong Mee <kinglongmee@gmail.com>
References: <839f5fbe-0dea-ea36-d38f-15d0a997edbb@gmail.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <fea18044-645d-b3ff-1cbe-2f41ec374374@RedHat.com>
Date: Wed, 20 Jul 2016 11:13:36 -0400
MIME-Version: 1.0
In-Reply-To: <839f5fbe-0dea-ea36-d38f-15d0a997edbb@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/13/2016 10:44 PM, Kinglong Mee wrote:
> gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I/usr/include/tirpc -D_GNU_SOURCE -Wall -Wextra -Wstrict-prototypes  -pipe -g -O2    -g -O2 -MT gssd-krb5_util.o -MD -MP -MF .deps/gssd-krb5_util.Tpo -c -o gssd-krb5_util.o `test -f 'krb5_util.c' || echo './'`krb5_util.c
> krb5_util.c: In function ‘gssd_acquire_user_cred’:
> krb5_util.c:1389:4: warning: this ‘if’ clause does not guard... [-Wmisleading-indentation]
>     if (get_verbosity() > 0)
>     ^~
> krb5_util.c:1392:5: note: ...this statement, but the latter is misleadingly indented as if it is guarded by the ‘if’
>      ret = -1;
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Committed... 

steved.
> ---
>  utils/gssd/krb5_util.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index c1e4d2b..b64818a 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1380,17 +1380,17 @@ gssd_acquire_user_cred(gss_cred_id_t *gss_cred)
>  	int ret;
>  
>  	ret = gssd_acquire_krb5_cred(gss_cred);
> +	if (ret)
> +		return ret;
>  
>  	/* force validation of cred to check for expiry */
> -	if (ret == 0) {
> -		maj_stat = gss_inquire_cred(&min_stat, *gss_cred, 
> +	maj_stat = gss_inquire_cred(&min_stat, *gss_cred,
>  			NULL, NULL, NULL, NULL);
> -		if (maj_stat != GSS_S_COMPLETE) {
> -			if (get_verbosity() > 0)
> -				pgsserr("gss_inquire_cred",
> -					maj_stat, min_stat, &krb5oid);
> -				ret = -1;
> -			}
> +	if (maj_stat != GSS_S_COMPLETE) {
> +		if (get_verbosity() > 0)
> +			pgsserr("gss_inquire_cred",
> +				maj_stat, min_stat, &krb5oid);
> +		ret = -1;
>  	}
>  
>  	return ret;
> 
