Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43243 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964900AbcCPOqq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 10:46:46 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 3B304627D6
	for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2016 14:46:46 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-57-45.rdu2.redhat.com [10.10.57.45])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u2GEkjiK012301
	for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2016 10:46:45 -0400
Subject: Re: [PATCH] nfsidmapd: allow the usage message to be displayed
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1455368071-15198-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56E971D5.5010205@RedHat.com>
Date: Wed, 16 Mar 2016 10:46:45 -0400
MIME-Version: 1.0
In-Reply-To: <1455368071-15198-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/13/2016 07:54 AM, Steve Dickson wrote:
> xlog_err() never returns. Change the xlog_err(),
> when invalid arguments are use, to xlog_warn()
> so the second xlog_warn, displaying the usage,
> will be called.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/nfsidmap/nfsidmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index d980c68..2abefe9 100644
> --- a/utils/nfsidmap/nfsidmap.c
> +++ b/utils/nfsidmap/nfsidmap.c
> @@ -430,7 +430,7 @@ int main(int argc, char **argv)
>  
>  	xlog_stderr(verbose);
>  	if ((argc - optind) != 2) {
> -		xlog_err("Bad arg count. Check /etc/request-key.conf");
> +		xlog_warn("Bad arg count. Check /etc/request-key.conf");
>  		xlog_warn(usage, progname);
>  		return EXIT_FAILURE;
>  	}
> 
