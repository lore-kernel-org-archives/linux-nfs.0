From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] exportfs: do not warn if /etc/exports.d/ does not
 exist
Date: Thu, 01 Sep 2011 11:35:56 -0400
Message-ID: <4E5FA65C.6090201@RedHat.com>
References: <1314890192-11075-1-git-send-email-vapier@gentoo.org> <1314890192-11075-2-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932397Ab1IAPf5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Sep 2011 11:35:57 -0400
In-Reply-To: <1314890192-11075-2-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/01/2011 11:16 AM, Mike Frysinger wrote:
> It isn't uncommon for /etc/exports.d/ to not exist, and imo, it's not
> that big of a deal as often times, a simple /etc/exports is sufficient.
> So silently skip the case where the dir is missing.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Committed...

steved.

> ---
>  utils/exportfs/exportfs.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 986a272..7432a65 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -529,9 +529,12 @@ export_d_read(const char *dname)
>  
>  
>  	n = scandir(dname, &namelist, NULL, versionsort);
> -	if (n < 0)
> +	if (n < 0) {
> +		if (errno == ENOENT)
> +			/* Silently return */
> +			return;
>  		xlog(L_NOTICE, "scandir %s: %s", dname, strerror(errno));
> -	else if (n == 0)
> +	} else if (n == 0)
>  		return;
>  
>  	for (i = 0; i < n; i++) {
