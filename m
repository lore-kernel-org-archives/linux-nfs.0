Return-Path: <SteveD@redhat.com>
Subject: Re: [PATCH] gssd: Fix inner-loop variable reuse
To: Benjamin Coddington <bcodding@redhat.com>
References: <7c093a92c6c61de8d4bf0f9620aea9ada789fe75.1456785264.git.bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56E9A3DD.8050109@RedHat.com>
Date: Wed, 16 Mar 2016 14:20:13 -0400
MIME-Version: 1.0
In-Reply-To: <7c093a92c6c61de8d4bf0f9620aea9ada789fe75.1456785264.git.bcodding@redhat.com>
Content-Type: text/plain; charset=windows-1252
List-ID: <linux-nfs.vger.kernel.org>



On 02/29/2016 05:36 PM, Benjamin Coddington wrote:
> The var "i" is already in use iterating realmnames.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> Fixes: "6597e391 gssd:  Don't assume the machine account will be in uppercase"
Committed... 

steved.

> ---
>  utils/gssd/krb5_util.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 8ef8184..8dc64fe 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -796,7 +796,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>  	char **realmnames = NULL;
>  	char myhostname[NI_MAXHOST], targethostname[NI_MAXHOST];
>  	char myhostad[NI_MAXHOST+1];
> -	int i, j, retval;
> +	int i, j, k, retval;
>  	char *default_realm = NULL;
>  	char *realm;
>  	char *k5err = NULL;
> @@ -941,8 +941,8 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>  				 * moving on to the svcname
>  				 */
>  				if (strcmp(svcnames[j],"$") == 0 && !tried_upper) {
> -					for (i = 0; myhostad[i] != '$'; ++i) {
> -						myhostad[i] = toupper(myhostad[i]);
> +					for (k = 0; myhostad[k] != '$'; ++k) {
> +						myhostad[k] = toupper(myhostad[k]);
>  					}
>  					j--;
>  					tried_upper = 1;
> 
