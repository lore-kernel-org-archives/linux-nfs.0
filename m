Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42919 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458Ab0HGCex (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 22:34:53 -0400
Date: Fri, 6 Aug 2010 22:33:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
Message-ID: <20100807023321.GH29536@fieldses.org>
References: <20100805204612.GA13821@fieldses.org>
 <20100805213107.GB13821@fieldses.org>
 <20100806212727.GC29536@fieldses.org>
 <20100806220537.GE29536@fieldses.org>
 <20100806221000.GF29536@fieldses.org>
 <201008071048.AGD12971.FOFQLtSJFMOVHO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201008071048.AGD12971.FOFQLtSJFMOVHO@I-love.SAKURA.ne.jp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 07, 2010 at 10:48:02AM +0900, Tetsuo Handa wrote:
> Applying commit 4cd7eb015e92f7cefb43eaab3e111d1b3c7b3cbf (with below patch)
> and commit e844a7b9805a2b74cfd34c8604f5bba3e0869305 and
> commit 7fa53cc872332b265bc5ba1266f39586f218ad4a on linux-2.6.35-next-20100802
> solved all problems found in my environment.
> 
> Thank you.

Thank you for the confirmation.

> --------------------
> 
> Fix build error by commit 4cd7eb015e92f7cefb43eaab3e111d1b3c7b3cbf
> "nfsd: fix startup/shutdown order bug".

Yes, apologies for that--I was compiling as sent that out!

--b.

> 
> ---
>  fs/nfsd/nfssvc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.35-next.orig/fs/nfsd/nfssvc.c
> +++ linux-2.6.35-next/fs/nfsd/nfssvc.c
> @@ -444,7 +444,7 @@ nfsd_svc(unsigned short port, int nrserv
>  	error = nfsd_startup(port, nrservs);
>  	if (error)
>  		goto out_destroy;
> -	}
> +
>  	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
>  	if (error)
>  		goto out_shutdown;
