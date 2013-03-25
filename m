Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757934Ab3CYOQm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 10:16:42 -0400
Message-ID: <51505C21.4010006@RedHat.com>
Date: Mon, 25 Mar 2013 10:16:01 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - nfs-utils] gssd: don't krb5_free_context if krb5_init_context
 fails
References: <20130305085700.56921777@notabene.brown>
In-Reply-To: <20130305085700.56921777@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/03/13 16:57, NeilBrown wrote:
> 
> Most places that call krb5_init_context() abort cleanly on failure.
> However these two then try to free the non-existent context, which
> doesn't end well.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed....

steved.
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index aeb8f70..4befa72 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1212,9 +1212,9 @@ gssd_destroy_krb5_machine_creds(void)
>  				    "cache '%s'\n", k5err, ple->ccname);
>  		}
>  	}
> +	krb5_free_context(context);
>    out:
>  	free(k5err);
> -	krb5_free_context(context);
>  }
>  
>  /*
> @@ -1257,7 +1257,7 @@ gssd_refresh_krb5_machine_credential(char *hostname,
>  		k5err = gssd_k5_err_msg(context, code);
>  		printerr(0, "ERROR: %s: %s while resolving keytab '%s'\n",
>  			 __func__, k5err, keytabfile);
> -		goto out;
> +		goto out_free_context;
>  	}
>  
>  	if (ple == NULL) {
> @@ -1272,7 +1272,7 @@ gssd_refresh_krb5_machine_credential(char *hostname,
>  				 "in keytab %s for connection with host %s\n",
>  				 __FUNCTION__, keytabfile, hostname);
>  			retval = code;
> -			goto out;
> +			goto out_free_kt;
>  		}
>  
>  		ple = get_ple_by_princ(context, kte.principal);
> @@ -1288,14 +1288,15 @@ gssd_refresh_krb5_machine_credential(char *hostname,
>  				 __FUNCTION__, pname ? pname : "<unparsable>",
>  				 hostname);
>  			if (pname) k5_free_unparsed_name(context, pname);
> -			goto out;
> +			goto out_free_kt;
>  		}
>  	}
>  	retval = gssd_get_single_krb5_cred(context, kt, ple, 0);
> -out:
> -	if (kt)
> -		krb5_kt_close(context, kt);
> +out_free_kt:
> +	krb5_kt_close(context, kt);
> +out_free_context:
>  	krb5_free_context(context);
> +out:
>  	free(k5err);
>  	return retval;
>  }
> 
