Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44213 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966753AbcCPOqN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 10:46:13 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id CFEF8219C
	for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2016 14:46:12 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-57-45.rdu2.redhat.com [10.10.57.45])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u2GEkBIh024178
	for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2016 10:46:12 -0400
Subject: Re: [PATCH] nfsidmapd: Let verbose determent whether stderr logging
 should be done
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1455367330-14781-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56E971B3.1060509@RedHat.com>
Date: Wed, 16 Mar 2016 10:46:11 -0400
MIME-Version: 1.0
In-Reply-To: <1455367330-14781-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/13/2016 07:42 AM, Steve Dickson wrote:
> Use the verbose command flag to turn on or off
> logging to stderr.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/nfsidmap/nfsidmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index 15b4a51..d980c68 100644
> --- a/utils/nfsidmap/nfsidmap.c
> +++ b/utils/nfsidmap/nfsidmap.c
> @@ -428,7 +428,7 @@ int main(int argc, char **argv)
>  		return keyring_clear(DEFAULT_KEYRING);
>  	}
>  
> -	xlog_stderr(0);
> +	xlog_stderr(verbose);
>  	if ((argc - optind) != 2) {
>  		xlog_err("Bad arg count. Check /etc/request-key.conf");
>  		xlog_warn(usage, progname);
> 
