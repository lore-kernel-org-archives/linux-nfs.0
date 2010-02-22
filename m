From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH][nfs-utils] configuration: Fix a typo in configure.ac
Date: Mon, 22 Feb 2010 13:22:02 -0500
Message-ID: <20100222182202.GB11356@fieldses.org>
References: <1266709510.3507.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Mr. Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60443 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152Ab0BVSVK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2010 13:21:10 -0500
In-Reply-To: <1266709510.3507.1.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 20, 2010 at 03:45:10PM -0800, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Fix a typo in commit 6d5ac3fa (nfsd: Disble NFS 4.1 functionality by default).

Better: please just rever 6d5ac3fa and apply
http://marc.info/?l=linux-nfs&m=126540028610022&w=2

	- distributions shouldn't be turning on 4.1 by default yet.
	  Even if no clients *use* it by default, future clients will,
	  even with older servers that shouldn't have had 4.1 on yet.
	- In addition to the bug Trond found, 6d5ac3fa also
	  inadvertently disables -N4 in the disable_nfsv41 case.

--b.

> 
> We did not really intend to make NFSv4.0 support conditional on NFSv4.1
> being enabled.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  configure.ac |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/configure.ac b/configure.ac
> index b7520d8..518b6d8 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -81,7 +81,7 @@ AC_ARG_ENABLE(nfsv41,
>  	if test "$enable_nfsv41" = yes; then
>  		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv41 support compiled in])
>  	else
> -		enable_nfsv4=
> +		enable_nfsv41=
>  	fi
>  	AC_SUBST(enable_nfsv41)
>  	AM_CONDITIONAL(CONFIG_NFSV41, [test "$enable_nfsv41" = "yes"])
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
