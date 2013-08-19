Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030Ab3HSS0U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Aug 2013 14:26:20 -0400
Message-ID: <5212634C.5050801@RedHat.com>
Date: Mon, 19 Aug 2013 14:26:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] idmapd: silence pointless EOF warning
References: <20130812164144.GC2395@fieldses.org>
In-Reply-To: <20130812164144.GC2395@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/08/13 12:41, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> RH bz 831455 has a report that repeatedly mounting and unmounting over
> lo can hit this warning in the EOF case.  I suspect that's just
> normal--I'm not sure of the details, but probably idmapd gets woken up
> to check for an upcall and then the upcall gets yanked away before
> idmapd gets a chance to read it.
> 
> So just skip the warning in that case.  I also can't see a reason to
> reopen.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed... 

steved.

> ---
>  utils/idmapd/idmapd.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index beba9c4..cc4ba9a 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -511,10 +511,14 @@ nfsdcb(int UNUSED(fd), short which, void *data)
>  	if (which != EV_READ)
>  		goto out;
>  
> -	if ((len = read(ic->ic_fd, buf, sizeof(buf))) <= 0) {
> +	len = read(ic->ic_fd, buf, sizeof(buf));
> +	if (len == 0)
> +		/* No upcall to read; not necessarily a problem: */
> +		return;
> +	if (len < 0) {
>  		xlog_warn("nfsdcb: read(%s) failed: errno %d (%s)",
> -			     ic->ic_path, len?errno:0, 
> -			     len?strerror(errno):"End of File");
> +			     ic->ic_path, errno,
> +			     strerror(errno));
>  		nfsdreopen_one(ic);
>  		return;
>  	}
> 
