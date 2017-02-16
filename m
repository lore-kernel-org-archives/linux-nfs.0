Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39818 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753747AbdBPKYC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Feb 2017 05:24:02 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4060D4E4D9
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2017 10:24:03 +0000 (UTC)
Subject: Re: [nfs-utils PATCH V2 2/2] Duplicate upcall string for use in error
 messages
To: Frank Sorenson <sorenson@redhat.com>, linux-nfs@vger.kernel.org
References: <778cd9e3-7b3a-654d-5fdd-bc0f63743041@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <a5ea5c21-178d-4cd6-baf5-086db3c39542@RedHat.com>
Date: Thu, 16 Feb 2017 05:24:02 -0500
MIME-Version: 1.0
In-Reply-To: <778cd9e3-7b3a-654d-5fdd-bc0f63743041@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/09/2017 06:04 PM, Frank Sorenson wrote:
> Author: Frank Sorenson <sorenson@redhat.com>
> Date:   2017-02-09 16:51:44 -0600
>
>     gssd:  Duplicate the upcall string for error messages
>     
>     strsep() modifies the input string, so error messages
>     may output only part of the upcall string.
>     
>     Make a copy of the upcall string, and use that in any
>     error messages.
>     
>     Signed-off-by: Frank Sorenson <sorenson@redhat.com>
Committed...

steved.
>
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 30c6ace..4fc81c3 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -729,10 +729,17 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
>  	char			*target = NULL;
>  	char			*service = NULL;
>  	char			*enctypes = NULL;
> +	char			*upcall_str;
>  	char			*pbuf = info->lbuf;
>  
>  	printerr(2, "\n%s: '%s' (%s)\n", __func__, info->lbuf, clp->relpath);
>  
> +	upcall_str = strdup(info->lbuf);
> +	if (upcall_str == NULL) {
> +		printerr(0, "ERROR: malloc failure\n");
> +		goto out_nomem;
> +	}
> +
>  	while ((p = strsep(&pbuf, " "))) {
>  		if (!strncmp(p, "mech=", strlen("mech=")))
>  			mech = p + strlen("mech=");
> @@ -749,7 +756,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
>  	if (!mech || strlen(mech) < 1) {
>  		printerr(0, "WARNING: handle_gssd_upcall: "
>  			    "failed to find gss mechanism name "
> -			    "in upcall string '%s'\n", info->lbuf);
> +			    "in upcall string '%s'\n", upcall_str);
>  		goto out;
>  	}
>  
> @@ -762,7 +769,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
>  	if (!uidstr) {
>  		printerr(0, "WARNING: handle_gssd_upcall: "
>  			    "failed to find uid "
> -			    "in upcall string '%s'\n", info->lbuf);
> +			    "in upcall string '%s'\n", upcall_str);
>  		goto out;
>  	}
>  
> @@ -775,7 +782,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
>  	if (target && strlen(target) < 1) {
>  		printerr(0, "WARNING: handle_gssd_upcall: "
>  			 "failed to parse target name "
> -			 "in upcall string '%s'\n", info->lbuf);
> +			 "in upcall string '%s'\n", upcall_str);
>  		goto out;
>  	}
>  
> @@ -790,7 +797,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
>  	if (service && strlen(service) < 1) {
>  		printerr(0, "WARNING: handle_gssd_upcall: "
>  			 "failed to parse service type "
> -			 "in upcall string '%s'\n", info->lbuf);
> +			 "in upcall string '%s'\n", upcall_str);
>  		goto out;
>  	}
>  
> @@ -803,6 +810,8 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
>  		do_error_downcall(clp->gssd_fd, uid, -EACCES);
>  	}
>  out:
> +	free(upcall_str);
> +out_nomem:
>  	free(info);
>  	return;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

