Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752001AbaATWCo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 17:02:44 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0KM2iru030823
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 17:02:44 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-58-78.rdu2.redhat.com [10.10.58.78])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id s0KM2hcf004008
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 17:02:43 -0500
Message-ID: <52DD9D74.5080805@RedHat.com>
Date: Mon, 20 Jan 2014 17:04:36 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: Removed supported flag from usage string
References: <1390240197-24908-1-git-send-email-steved@redhat.com>
In-Reply-To: <1390240197-24908-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 20/01/14 12:49, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/mount/utils.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/mount/utils.c b/utils/mount/utils.c
> index 2778ed7..ede77a8 100644
> --- a/utils/mount/utils.c
> +++ b/utils/mount/utils.c
> @@ -93,7 +93,7 @@ void print_one(char *spec, char *node, char *type, char *opts)
>  
>  void mount_usage(void)
>  {
> -	printf(_("usage: %s remotetarget dir [-rvVwfnsih] [-o nfsoptions]\n"),
> +	printf(_("usage: %s remotetarget dir [-rvVwfnsh] [-o nfsoptions]\n"),
>  		progname);
>  	printf(_("options:\n"));
>  	printf(_("\t-r\t\tMount file system readonly\n"));
> 
