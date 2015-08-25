Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:39928 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755882AbbHYVGo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 17:06:44 -0400
Date: Tue, 25 Aug 2015 17:06:43 -0400
From: Paul Gortmaker <paul.gortmaker@windriver.com>
To: <linux-kernel@vger.kernel.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: don't WARN/backtrace for invalid container
 deployment.
Message-ID: <20150825210642.GG3560@windriver.com>
References: <1440536356-2634-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <1440536356-2634-1-git-send-email-paul.gortmaker@windriver.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[[PATCH] nfsd: don't WARN/backtrace for invalid container deployment.] On 25/08/2015 (Tue 16:59) Paul Gortmaker wrote:

> These messages, combined with the backtrace they trigger, makes it seem
> like a serious problem, though a quick search shows distros marking
> it as a "won't fix" non-issue when the problem is reported by users.

Ah crap, didn't notice I was on a slightly older kernel when generating
this ; it still applies to master with minor fuzz.  I can resend if need
be, and if folks are OK with the general approach.

Paul.
--

> 
> The backtrace is overkill, and only really manages to show that if
> you follow the code path, you can't really avoid it with bootargs
> or configuration settings in the container.
> 
> Given that, lets tone it down a bit and get rid of the WARN severity,
> and the associated backtrace, so people aren't needlessly alarmed.
> 
> Also, lets drop the split printk line, since they are grep unfriendly.
> 
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: linux-nfs@vger.kernel.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 9c271f42604a..fe8a3da5eb63 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -526,8 +526,7 @@ nfsd4_legacy_tracking_init(struct net *net)
>  
>  	/* XXX: The legacy code won't work in a container */
>  	if (net != &init_net) {
> -		WARN(1, KERN_ERR "NFSD: attempt to initialize legacy client "
> -			"tracking in a container!\n");
> +		pr_warn("NFSD: attempt to initialize legacy client tracking in a container ignored.\n");
>  		return -EINVAL;
>  	}
>  
> @@ -1191,8 +1190,7 @@ nfsd4_umh_cltrack_init(struct net __attribute__((unused)) *net)
>  {
>  	/* XXX: The usermode helper s not working in container yet. */
>  	if (net != &init_net) {
> -		WARN(1, KERN_ERR "NFSD: attempt to initialize umh client "
> -			"tracking in a container!\n");
> +		pr_warn("NFSD: attempt to initialize umh client tracking in a container ignored.\n");
>  		return -EINVAL;
>  	}
>  	return nfsd4_umh_cltrack_upcall("init", NULL, NULL);
> -- 
> 2.1.0
> 
