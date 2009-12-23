From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] libexport.a: fix a long-standing typo in name_cmp()
Date: Wed, 23 Dec 2009 14:40:07 -0500
Message-ID: <4B327217.6070001@RedHat.com>
References: <20091211212608.29241.27167.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889AbZLWTkS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Dec 2009 14:40:18 -0500
In-Reply-To: <20091211212608.29241.27167.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/11/2009 04:27 PM, Chuck Lever wrote:
> Not sure what "(!*a || !a == ',')" means... but just a few lines later is
> "(!*a || *a == ',')".  I think "a is '\0' or ','" is what was intended.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Neil --
> 
> Looks like a typo.  Comments?
> 
>  support/export/client.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/support/export/client.c b/support/export/client.c
> index b08dda2..cb6e659 100644
> --- a/support/export/client.c
> +++ b/support/export/client.c
> @@ -266,7 +266,7 @@ name_cmp(char *a, char *b)
>  	/* compare strings a and b, but only upto ',' in a */
>  	while (*a && *b && *a != ',' && *a == *b)
>  		a++, b++;
> -	if (!*b && (!*a || !a == ',') )
> +	if (!*b && (!*a || *a == ','))
>  		return 0;
>  	if (!*b) return 1;
>  	if (!*a || *a == ',') return -1;
> 
Committed...

steved.
