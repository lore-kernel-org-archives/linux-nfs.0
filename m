From: Steve Dickson <SteveD@redhat.com>
Subject: Re: gssd picking wrong creds
Date: Mon, 19 Jul 2010 11:10:04 -0400
Message-ID: <4C446ACC.8090305@RedHat.com>
References: <4C300049.7040603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Doug Nazar <nazard.michi@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935158Ab0GSPKH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 11:10:07 -0400
In-Reply-To: <4C300049.7040603@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/03/2010 11:30 PM, Doug Nazar wrote:
>  I'm running rpc.gssd with the the -n option. Noticed that with the new
> version it's now creating the machine cache file which is also owned by
> root so when it scans the cache files it matches the root user and then
> depending on the timestamp it can grab the wrong file.
> 
> Doug
> 
> 
> nfs-utils-ignore-machine-cred.diff
> 

Committed...

steved.

> 
> commit 891bf46cd23dbbb24188456aad29ac0ead2bc31f
> Author: Doug Nazar <nazard.michi@gmail.com>
> Date:   Sat Jul 3 23:12:27 2010 -0400
> 
>     When not using machine credentials for root, if the machine
>     credential cache file is newer than the root credential file
>     the wrong file will get picked. Ignore the machine file in this
>     case.
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index dccbeb6..d23654f 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -224,6 +224,13 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
>  				free(namelist[i]);
>  				continue;
>  			}
> +			if (uid == 0 && !root_uses_machine_creds && 
> +				strstr(namelist[i]->d_name, "_machine_")) {
> +				printerr(3, "CC file '%s' not available to root\n",
> +					 statname);
> +				free(namelist[i]);
> +				continue;
> +			}
>  			if (!query_krb5_ccache(buf, &princname, &realm)) {
>  				printerr(3, "CC file '%s' is expired or corrupt\n",
>  					 statname);
