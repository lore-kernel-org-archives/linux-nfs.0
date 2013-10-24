Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58750 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753940Ab3JXUGs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 16:06:48 -0400
Message-ID: <52697DFB.7030107@RedHat.com>
Date: Thu, 24 Oct 2013 16:07:23 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Wangminlan <wangminlan@huawei.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - nfs-utils] Stop Treat IP addresses a FQDN rather than
 SUBNETs.
References: <20131022101754.462d3f8b@notabene.brown>
In-Reply-To: <20131022101754.462d3f8b@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 21/10/13 19:17, NeilBrown wrote:
> 
> 
> I think there was a reason for this many years ago,
> but I can not find any evidence that it ever really did
> anything useful and it certainly doesn't seem to now.
> 
> And the documentation suggests that IP address take precedence over
> SUBNETs, and that can only happen if they are treated as MCL_FQDN.
> 
> So remove this apparently pointless code.
> 
> Reported-and-tested-by: Wangminlan <wangminlan@huawei.com>
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed...

steved.

> 
> diff --git a/support/export/client.c b/support/export/client.c
> index ba2db8f..adbeed8 100644
> --- a/support/export/client.c
> +++ b/support/export/client.c
> @@ -767,15 +767,5 @@ client_gettype(char *ident)
>  			sp++;
>  	}
>  
> -	/*
> -	 * Treat unadorned IP addresses as MCL_SUBNETWORK.
> -	 * Everything else is MCL_FQDN.
> -	 */
> -	ai = host_pton(ident);
> -	if (ai != NULL) {
> -		freeaddrinfo(ai);
> -		return MCL_SUBNETWORK;
> -	}
> -
>  	return MCL_FQDN;
>  }
> 
