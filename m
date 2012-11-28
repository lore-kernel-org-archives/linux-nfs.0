Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35132 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932083Ab2K1NLF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 08:11:05 -0500
Date: Wed, 28 Nov 2012 08:10:55 -0500
To: Neil Brown <neilb@suse.de>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] gssd: base the size of the fd array on the
 RLIMIT_NOFILE limit.
Message-ID: <20121128131054.GB11651@fieldses.org>
References: <20121128010939.2475.13123.stgit@notabene.brown>
 <20121128011123.2475.13691.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121128011123.2475.13691.stgit@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 28, 2012 at 12:11:23PM +1100, Neil Brown wrote:
> We have previously raised the size of the 'pollarray' once (32 -> 256)
> and I have had another request to make it bigger.
> Rather than changing the hard-coded value, make it depend on
> RLIMIT_NOFILE.  This is an upper limit on the size of the array
> that can be passed to poll() anyway.

Sounds like a good idea.

Just out of curiosity: how does it fail?  I guess mounts just start
failing at some point--how do people find the workaround?

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  utils/gssd/gssd_proc.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 425b582..e32b2f0 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -52,6 +52,7 @@
>  #include <sys/socket.h>
>  #include <arpa/inet.h>
>  #include <sys/fsuid.h>
> +#include <sys/resource.h>
>  
>  #include <stdio.h>
>  #include <stdlib.h>
> @@ -483,9 +484,13 @@ fail_keep_client:
>  void
>  init_client_list(void)
>  {
> +	struct rlimit rlim;
>  	TAILQ_INIT(&clnt_list);
>  	/* Eventually plan to grow/shrink poll array: */
>  	pollsize = FD_ALLOC_BLOCK;
> +	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0 &&
> +	    rlim.rlim_cur != RLIM_INFINITY)
> +		pollsize = rlim.rlim_cur;
>  	pollarray = calloc(pollsize, sizeof(struct pollfd));
>  }
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
