From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: Problem with 2.6.33-rc1 and insecure flag
Date: Sun, 20 Dec 2009 10:41:22 -0500
Message-ID: <20091220154122.GA2841@fieldses.org>
References: <20091220094625.GA2159@trillian.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49333 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754576AbZLTPlK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Dec 2009 10:41:10 -0500
In-Reply-To: <20091220094625.GA2159-8FIgwK2HfyKMj3X28ACnv+Tv7YV0F9Eg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 20, 2009 at 10:46:26AM +0100, Michael Guntsche wrote:
> I think I figured out the problem. 
> 
> Apparently the code checked if insecure was set, while it should check if it was NOT set.

Thanks!  And apologies, I ran across this too a couple days ago, left it
in -next, and forgot to send it upstream....  I'll do that now.

--b.

> 
> Kind regards,
> Michael
> 
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index 1c12177..55c8e63 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -89,7 +89,7 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
>         int flags = nfsexp_flags(rqstp, exp);
>  
>         /* Check if the request originated from a secure port. */
> -       if (!rqstp->rq_secure && (flags & NFSEXP_INSECURE_PORT)) {
> +       if (!rqstp->rq_secure && !(flags & NFSEXP_INSECURE_PORT)) {
>                 RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
>                 dprintk(KERN_WARNING
>                        "nfsd: request from insecure port %s!\n",
> 
> 
> 
