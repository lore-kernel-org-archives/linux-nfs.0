From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] Nfs4 over Ipv6 patch to fix ipv6 subnetting in
	/etc/exports
Date: Fri, 11 Dec 2009 13:19:55 -0500
Message-ID: <4B228D4B.7000007@RedHat.com>
References: <4B16EF49.8040106@silka.with-linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kelly Anderson <kelly-lACMDn57031vQQPgy9v2K1aTQe2KTcn/@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34803 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753432AbZLKSUe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 13:20:34 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NJA6Z-0005qg-Oc
	for linux-nfs@vger.kernel.org; Sat, 12 Dec 2009 05:20:39 +1100
In-Reply-To: <4B16EF49.8040106-lACMDn57031vQQPgy9v2K1aTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 12/02/2009 05:50 PM, Kelly Anderson wrote:
> --- ./support/export/client.c.orig	2009-11-30 08:06:18.000000000 -0700
> +++ ./support/export/client.c	2009-12-02 15:16:55.361725808 -0700
> @@ -505,16 +505,16 @@ check_subnet_v6(const struct sockaddr_in
>  			continue;
>  
>  		if (mask_match(address->sin6_addr.s6_addr32[0],
> -				sin6->sin6_addr.s6_addr[0],
> +				sin6->sin6_addr.s6_addr32[0],
>  		      		mask->sin6_addr.s6_addr32[0]) &&
>  		    mask_match(address->sin6_addr.s6_addr32[1],
> -				sin6->sin6_addr.s6_addr[1],
> +				sin6->sin6_addr.s6_addr32[1],
>  		      		mask->sin6_addr.s6_addr32[1]) &&
>  		    mask_match(address->sin6_addr.s6_addr32[2],
> -				sin6->sin6_addr.s6_addr[2],
> +				sin6->sin6_addr.s6_addr32[2],
>  		      		mask->sin6_addr.s6_addr32[2]) &&
>  		    mask_match(address->sin6_addr.s6_addr32[3],
> -				sin6->sin6_addr.s6_addr[3],
> +				sin6->sin6_addr.s6_addr32[3],
>  		      		mask->sin6_addr.s6_addr32[3]))
>  			return 1;
>  	}
I'm a bit confused here... I don't see a check_subnet_v6() routine
in support/export/client.c and from the git logs says there never
was a routine called check_subnet_v6()... what am I missing?

In the future, please add the Signed-off-by: label to the bottom
of the patch description... thanks!


steved.

------------------------------------------------------------------------------
Return on Information:
Google Enterprise Search pays you back
Get the facts.
http://p.sf.net/sfu/google-dev2dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

