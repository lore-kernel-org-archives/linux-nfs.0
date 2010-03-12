From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: fix error path - actually return ERR_PTR() on
	error
Date: Fri, 12 Mar 2010 15:35:46 -0500
Message-ID: <20100312203546.GB13941@fieldses.org>
References: <1268401704-9034-1-git-send-email-ext-jani.1.nikula@nokia.com> <201003122314.IAD17160.OtJLHVMFOOSFFQ@I-love.SAKURA.ne.jp> <1268406591.3156.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	ext-jani.1.nikula@nokia.com, neilb@suse.de, davem@davemloft.net,
	batsakis@netapp.com, bhalevy@panasas.com,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37116 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934556Ab0CLUeX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Mar 2010 15:34:23 -0500
In-Reply-To: <1268406591.3156.18.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 12, 2010 at 10:09:51AM -0500, Trond Myklebust wrote:
> On Fri, 2010-03-12 at 23:14 +0900, Tetsuo Handa wrote: 
> > Jani Nikula wrote:
> > > Signed-off-by: Jani Nikula <ext-jani.1.nikula@nokia.com>
> > > 
> > > ---
> > > 
> > > NOTE: I'm afraid I'm unable to test this; please consider this more a
> > > bug report than a complete patch.
> > > ---
> > Indeed, it has to be "return ERR_PTR(-EINVAL);".
> > Otherwise, it will trigger NULL pointer dereference some lines later.
> > 
> >     bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
> >     bc_sock->sk_bc_xprt = xprt;
> > 
> > This bug was introduced by f300baba5a1536070d6d77bf0c8c4ca999bb4f0f
> > "nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel" and
> > exists in 2.6.32 and later.
> 
> Or it should just be dropped. I don't see any reason why nfsd should be
> trying to set up a callback channel if it doesn't already know that it
> has a socket. Returning an error value in that case would just be
> papering over a design bug.

Yup.  At most it could be a BUG_ON, but it's probably better just to
delete the check.

--b.
