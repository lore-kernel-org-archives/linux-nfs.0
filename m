From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: fix error path - actually return ERR_PTR() on
 error
Date: Fri, 12 Mar 2010 10:09:51 -0500
Message-ID: <1268406591.3156.18.camel@localhost.localdomain>
References: <1268401704-9034-1-git-send-email-ext-jani.1.nikula@nokia.com>
	 <201003122314.IAD17160.OtJLHVMFOOSFFQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: ext-jani.1.nikula@nokia.com, bfields@fieldses.org, neilb@suse.de,
	davem@davemloft.net, batsakis@netapp.com, bhalevy@panasas.com,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17635 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934020Ab0CLPKe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Mar 2010 10:10:34 -0500
In-Reply-To: <201003122314.IAD17160.OtJLHVMFOOSFFQ@I-love.SAKURA.ne.jp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-03-12 at 23:14 +0900, Tetsuo Handa wrote: 
> Jani Nikula wrote:
> > Signed-off-by: Jani Nikula <ext-jani.1.nikula@nokia.com>
> > 
> > ---
> > 
> > NOTE: I'm afraid I'm unable to test this; please consider this more a
> > bug report than a complete patch.
> > ---
> Indeed, it has to be "return ERR_PTR(-EINVAL);".
> Otherwise, it will trigger NULL pointer dereference some lines later.
> 
>     bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
>     bc_sock->sk_bc_xprt = xprt;
> 
> This bug was introduced by f300baba5a1536070d6d77bf0c8c4ca999bb4f0f
> "nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel" and
> exists in 2.6.32 and later.

Or it should just be dropped. I don't see any reason why nfsd should be
trying to set up a callback channel if it doesn't already know that it
has a socket. Returning an error value in that case would just be
papering over a design bug.

   Trond
