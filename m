Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128AbaATWBV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 17:01:21 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0KM1L1X002485
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 17:01:21 -0500
Message-ID: <52DD9D20.8040105@RedHat.com>
Date: Mon, 20 Jan 2014 17:03:12 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>, jlayton@redhat.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] Improve first attempt at acquiring GSS credentials
References: <1389931919-4801-1-git-send-email-simo@redhat.com> <1389977800-10922-1-git-send-email-simo@redhat.com> <1389977800-10922-2-git-send-email-simo@redhat.com>
In-Reply-To: <1389977800-10922-2-git-send-email-simo@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 17/01/14 11:56, Simo Sorce wrote:
> Since now rpc.gssd is swithing uid before attempting to acquire
> credentials, we do not need to pass in the special uid-as-a-string name
> to gssapi, because the process is already running under the user's
> credentials.
> 
> By removing this code we can fix a class of false negatives where the
> user name does not match the actual ccache credentials and the ccache
> type used is not one of the only 2 supported explicitly by rpc.gssd by the
> fallback trolling done later.
> 
> Signed-off-by: Simo Sorce <simo@redhat.com>
Committed...

steved

> ---
>  utils/gssd/krb5_util.c |   24 ++----------------------
>  1 files changed, 2 insertions(+), 22 deletions(-)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 697d1d2e79db0cc38160ea4772d3af3a9b7d6c21..230b909b14d244f832c0b5dd62e600cf8db4f80b 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1381,29 +1381,10 @@ gssd_acquire_krb5_cred(gss_name_t name, gss_cred_id_t *gss_cred)
>  int
>  gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred)
>  {
> -	OM_uint32 maj_stat, min_stat;
> -	gss_buffer_desc name_buf;
> -	gss_name_t name;
> -	char buf[11];
> +	OM_uint32 min_stat;
>  	int ret;
>  
> -	ret = snprintf(buf, 11, "%u", uid);
> -	if (ret < 1 || ret > 10) {
> -		return -1;
> -	}
> -	name_buf.value = buf;
> -	name_buf.length = ret + 1;
> -
> -	maj_stat = gss_import_name(&min_stat, &name_buf,
> -				   GSS_C_NT_STRING_UID_NAME, &name);
> -	if (maj_stat != GSS_S_COMPLETE) {
> -		if (get_verbosity() > 0)
> -			pgsserr("gss_import_name",
> -				maj_stat, min_stat, &krb5oid);
> -		return -1;
> -	}
> -
> -	ret = gssd_acquire_krb5_cred(name, gss_cred);
> +	ret = gssd_acquire_krb5_cred(GSS_C_NO_NAME, gss_cred);
>  
>  	/* force validation of cred to check for expiry */
>  	if (ret == 0) {
> @@ -1412,7 +1393,6 @@ gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred)
>  			ret = -1;
>  	}
>  
> -	maj_stat = gss_release_name(&min_stat, &name);
>  	return ret;
>  }
>  
> 
