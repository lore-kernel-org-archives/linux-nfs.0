From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NLM: hold BKL when clearing global lockd task and serv
 vars
Date: Tue, 8 Apr 2008 13:02:26 -0400
Message-ID: <20080408130226.3def8241@tleilax.poochiereds.net>
References: <1207575514-6703-1-git-send-email-jlayton@redhat.com>
	<1207575514-6703-2-git-send-email-jlayton@redhat.com>
	<20080407164500.GA17728@infradead.org>
	<20080407175615.GD3305@fieldses.org>
	<20080407162241.0a06fd6f@tleilax.poochiereds.net>
	<20080407205027.GE11219@fieldses.org>
	<20080408092102.2404f5ee@tleilax.poochiereds.net>
	<20080408162821.GA8994@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbYDHRCa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 13:02:30 -0400
In-Reply-To: <20080408162821.GA8994@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Apr 2008 12:28:21 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Apr 08, 2008 at 09:21:02AM -0400, Jeff Layton wrote:
> > On Mon, 7 Apr 2008 16:50:27 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Mon, Apr 07, 2008 at 04:22:41PM -0400, Jeff Layton wrote:
> > > > On Mon, 7 Apr 2008 13:56:15 -0400
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > On Mon, Apr 07, 2008 at 12:45:01PM -0400, Christoph Hellwig wrote:
> > > > > > On Mon, Apr 07, 2008 at 09:38:34AM -0400, Jeff Layton wrote:
> > > > > > > The global task and serv pointers for lockd are normally protected by
> > > > > > > the nlmsvc_mutex. The exception is when the lockd exits abnormally. When
> > > > > > > this occurs, these variables are cleared without any locking.
> > > > > > 
> > > > > > Shouldn't we get rid of the case where it exits abnormally instead?
> > > > > 
> > > > > I tried to figure out when this could actually occur (when can
> > > > > svc_recv() return an error other than -EINTR or -EAGAIN?), and got lost
> > > > > in sock_recvmsg():
> > > > > 
> > > > > 	- svc_recv() itself returns only -EAGAIN or the return from
> > > > > 	  ->xpo_recvfrom().
> > > > > 	- the only xpo_recvfrom() that's interesting is
> > > > > 	  svc_tcp_recvfrom(), which can return the error it gets from
> > > > > 	  svc_recvfrom(), which can return the error from
> > > > > 	  kernel_recvmsg(), which gets its return from sock_recvmsg().
> > > > > 
> > > > > Since __sock_recvmsg() has a security hook, it looks like we can end up
> > > > > with an -EACCES from selinux?
> > > > > 
> > > > > So one case would be selinux deciding we weren't allowed to receive
> > > > > packets from this socket.  Huh.
> > > > 
> > > > I got lost there too, but I would suspect that there are other errors
> > > > that can bubble up from the lower networking layers as well. Even if
> > > > there aren't currently, it's probably still prudent to assume that it's
> > > > a possibility and code for it.
> > > > 
> > > > I tend to think the safest thing is probably to do a long sleep (1s or
> > > > so and retry when we get an error (maybe also a ratelimited printk?).
> > > 
> > > Yeah, I guess I can't think of anything better.
> > > 
> > 
> > Ok, I went ahead and did patches for this and gave them a quick test
> > this morning. Obviously, these are hard to fully unit test since this
> > seems to be a very uncommon occurrence.
> 
> I suppose this could probably be reproduced with some selinux magic.
> 

Good idea. I'll chat with our SELinux guys and see if they can point me
in the right direction on this.

> > Any thoughts?
> 
> If anyone does ever hit this and it doesn't go away, the printk (even
> with the ratelimiting) could be pretty annoying, so it might be worth
> arranging to print this just once.  But perhaps we can wait and see if
> that actually happens.
> 

I tend to think that this is most likely to happen when there's a
significant problem in lower level networking (or maybe a VM problem?).
SELinux is also a possibility, as you pointed out, but I'm not sure how
much kernel threads are affected by SELinux...

In any case, if this happens, then we're probably going to have bigger
problems than a printk every second. My suggestion would be that we keep
it like this for now, and reconsider it if it turns out to be a
problem...

> Given what appears to be a very unusual crash, and what I'm assuming is
> an impending release, I suppose we should wait for the merge window (but
> possibly also submit to 2.6.25.x).
> 

Yes. I was thinking that all of this should probably be 2.6.26
material (along with all of the kthread conversion patches). Aside from
this possibly happening in Michael's crash, I've never seen lockd exit
abnormally like this.

-- 
Jeff Layton <jlayton@redhat.com>
