From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH v2] Update nfs(5) manpage - timeo for NFS/TCP
Date: Tue, 30 Aug 2011 08:41:26 -0400
Message-ID: <4E5CDA76.7020703@RedHat.com>
References: <201108300245.p7U2jN4j011424@ns3.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, rees@umich.edu
To: Max Matveev <makc@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752877Ab1H3Mla (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Aug 2011 08:41:30 -0400
In-Reply-To: <201108300245.p7U2jN4j011424-K5Dt2rfd30Yf7BdofF/totBPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/04/2011 01:47 AM, Max Matveev wrote:
> NFS/TCP does linear backoff then retransmiting - the manpage
> was mistakenly asserting the "no backoff" theory.
> 
> Signed-off-by: Max Matveev <makc@redhat.com>
> Signed-off-by: Jim Rees <rees@umich.edu>
Committed... 

steved.

> ---
>  utils/mount/nfs.man |   16 ++++++++++------
>  1 files changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index be91a25..ff0ed60 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -113,12 +113,16 @@ option may mitigate some of the risks of using the
>  option.
>  .TP 1.5i
>  .BI timeo= n
> -The time (in tenths of a second) the NFS client waits for a
> -response before it retries an NFS request. If this
> -option is not specified, requests are retried every
> -60 seconds for NFS over TCP.
> -The NFS client does not perform any kind of timeout backoff
> -for NFS over TCP.
> +The time in deciseconds (tenths of a second) the NFS client waits for a
> +response before it retries an NFS request.
> +.IP
> +For NFS over TCP the default
> +.B timeo
> +value is 600 (60 seconds).
> +The NFS client performs linear backoff: After each retransmission the 
> +timeout is increased by
> +.BR timeo 
> +up to the maximum of 600 seconds.
>  .IP
>  However, for NFS over UDP, the client uses an adaptive
>  algorithm to estimate an appropriate timeout value for frequently used
> -- 1.7.4.4 -- To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at http://vger.kernel.org/majordomo-info.html
