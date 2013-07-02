Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1116 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641Ab3GBM31 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jul 2013 08:29:27 -0400
Message-ID: <51D2C79D.5010504@RedHat.com>
Date: Tue, 02 Jul 2013 08:29:17 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/3] krb5_util: don't give up on machine credential if
 hostname not available.
References: <20130603005219.20080.1927.stgit@notabene.brown> <20130603010021.20080.11239.stgit@notabene.brown>
In-Reply-To: <20130603010021.20080.11239.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/06/13 21:00, Neil Brown wrote:
> krb5_util tries various different credential names in order to find
> the machine credential, not all of them use the full host name of the
> current host.
> 
> So if getting the full host name fails, don't give up completely,
> still try the other options.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed! 

steved.

> ---
>  utils/gssd/krb5_util.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 9ef80f0..5e84481 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -825,8 +825,10 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>  	myhostad[i+1] = 0;
>  
>  	retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
> -	if (retval)
> -		goto out;
> +	if (retval) {
> +		/* Don't use myhostname */
> +		myhostname[0] = 0;
> +	}
>  
>  	code = krb5_get_default_realm(context, &default_realm);
>  	if (code) {
> @@ -883,6 +885,8 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>  								myhostad,
>  								NULL);
>  			} else {
> +				if (!myhostname[0])
> +					continue;
>  				snprintf(spn, sizeof(spn), "%s/%s@%s",
>  					 svcnames[j], myhostname, realm);
>  				code = krb5_build_principal_ext(context, &princ,
> 
> 
