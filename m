Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15680 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756358Ab3CYOQh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 10:16:37 -0400
Message-ID: <51505C0C.7080906@RedHat.com>
Date: Mon, 25 Mar 2013 10:15:40 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>, Leonardo Chiquitto <lchiquitto@suse.com>
Subject: Re: [PATCH - nfs-utils] gssd:  use correct test for success of getrlimit()
References: <20130219113102.265d9d03@notabene.brown>
In-Reply-To: <20130219113102.265d9d03@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 18/02/13 19:31, NeilBrown wrote:
> 
> commit 7c5cb5e732a4b8704f8c79ec819c5d271e040339
>     gssd: base the size of the fd array on the RLIMIT_NOFILE limit.
> 
> didn't actually work as claimed.  It only uses the returned value
> if getrlimit() returns -1  -- which of course it only does when
> there was an error.
> 
> So change the test to "== 0".
> 
> Reported-by: Leonardo Chiquitto< lchiquitto@suse.com>
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> --
> hangs head in shame .... NeilBrown
Committed... 

steved.

> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index c17ab3b..e10bda6 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -477,7 +477,7 @@ init_client_list(void)
>  	TAILQ_INIT(&clnt_list);
>  	/* Eventually plan to grow/shrink poll array: */
>  	pollsize = FD_ALLOC_BLOCK;
> -	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0 &&
> +	if (getrlimit(RLIMIT_NOFILE, &rlim) == 0 &&
>  	    rlim.rlim_cur != RLIM_INFINITY)
>  		pollsize = rlim.rlim_cur;
>  	pollarray = calloc(pollsize, sizeof(struct pollfd));
> 
