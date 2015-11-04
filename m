Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965410AbbKDVuB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 16:50:01 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id A222AC100450
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2015 21:50:01 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] gssd: Don't assume the machine account will be
 in uppercase
To: Scott Mayhew <smayhew@redhat.com>
References: <1443720677-11909-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <563A7D88.3060101@RedHat.com>
Date: Wed, 4 Nov 2015 16:50:00 -0500
MIME-Version: 1.0
In-Reply-To: <1443720677-11909-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/01/2015 01:31 PM, Scott Mayhew wrote:
> find_keytab_entry() first looks for an entry of the form
> <HOSTNAME>$@<DOMAIN>, which corresponds to the Active Directory machine
> account.  It assumes that <HOSTNAME> will be in uppercase because that's
> how the entry is created if the machine is joined to the domain using
> Samba.
> 
> But that's not necessarily the case if the another identity management
> solution is used... for example a keytab entry for a machine account
> created by Centrify will match the actual computer account in Active
> Directory, whether that be in upper case, lower case, or mixed case.
> 
> So first look for an entry that matches the unmodified hostname and then
> convert it to uppercase and try again only if that failed.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.

> ---
>  utils/gssd/krb5_util.c | 16 ++++++++++++++--
>  1 file changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index ecf17a2..f48de2c 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -801,7 +801,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>  	char *default_realm = NULL;
>  	char *realm;
>  	char *k5err = NULL;
> -	int tried_all = 0, tried_default = 0;
> +	int tried_all = 0, tried_default = 0, tried_upper = 0;
>  	krb5_principal princ;
>  	const char *notsetstr = "not set";
>  	char *adhostoverride;
> @@ -835,7 +835,6 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>  	        strcpy(myhostad, myhostname);
>  	        for (i = 0; myhostad[i] != 0; ++i) {
>  	          if (myhostad[i] == '.') break;
> -	          myhostad[i] = toupper(myhostad[i]);
>  	        }
>  	        myhostad[i] = '$';
>  	        myhostad[i+1] = 0;
> @@ -936,6 +935,19 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>  				k5err = gssd_k5_err_msg(context, code);
>  				printerr(3, "%s while getting keytab entry for '%s'\n",
>  					 k5err, spn);
> +				/*
> +				 * We tried the active directory machine account
> +				 * with the hostname part as-is and failed...
> +				 * convert it to uppercase and try again before
> +				 * moving on to the svcname
> +				 */
> +				if (strcmp(svcnames[j],"$") == 0 && !tried_upper) {
> +					for (i = 0; myhostad[i] != '$'; ++i) {
> +						myhostad[i] = toupper(myhostad[i]);
> +					}
> +					j--;
> +					tried_upper = 1;
> +				}
>  			} else {
>  				printerr(3, "Success getting keytab entry for '%s'\n",spn);
>  				retval = 0;
> 
