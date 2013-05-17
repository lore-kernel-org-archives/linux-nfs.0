Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:22512 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756504Ab3EQR4t convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 May 2013 13:56:49 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] SUNRPC: Faster detection if gssd is actually running
Date: Fri, 17 May 2013 17:52:45 +0000
Message-ID: <1368813165.9073.3.camel@leira.trondhjem.org>
References: <1368647441-24815-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1368647441-24815-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1368647441-24815-3-git-send-email-Trond.Myklebust@netapp.com>
	 <20130516201954.GA3216@fieldses.org> <20130517010344.GA6579@fieldses.org>
In-Reply-To: <20130517010344.GA6579@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-16 at 21:03 -0400, J. Bruce Fields wrote:
> On Thu, May 16, 2013 at 04:19:54PM -0400, bfields wrote:
> > On Wed, May 15, 2013 at 12:50:40PM -0700, Trond Myklebust wrote:
> > > Recent changes to the NFS security flavour negotiation mean that
> > > we have a stronger dependency on rpc.gssd. If the latter is not
> > > running, because the user failed to start it, then we time out
> > > and mark the container as not having an instance. We then
> > > use that information to time out faster the next time.
> > > 
> > > If, on the other hand, the rpc.gssd successfully binds to an rpc_pipe,
> > > then we mark the container as having an rpc.gssd instance.
> > 
> > So it's still a 15 second delay on the first mount, then 7 on the
> > second, then 3, 1, and no delay thereafter.  Is that right?
> > 
> > Why not be harsher and go straight to 0 after the first failure?
> 
> Chuck points out I'm confused, it's actually 15s then 1/4s (why 1/4s?).

The timeout has to be non-zero, otherwise if you _do_ restart rpc.gssd,
it needs a certain time to actually connect to one of the gssd
rpc_pipes.

The 15 second initial timeout is there in order to deal with the fact
that it may take a moment or 2 for init to get round to starting
rpc.gssd. I didn't want to change that value right now.

> (Apologies, somehow I saw a ">> 2" in there and my brain shut down and
> jumped to the "exponential delay" conclusion.)
> 
> Still sort of curious how we're choosing these delays, though.
> 
> Hard to imagine people won't still notice the delay on first mount.
> Given there's a workaround (run gssd), maybe that's just good enough for
> now, I don't know.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
