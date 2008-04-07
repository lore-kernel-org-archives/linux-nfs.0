From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: hold BKL when clearing global lockd task and serv
	vars
Date: Mon, 7 Apr 2008 16:50:27 -0400
Message-ID: <20080407205027.GE11219@fieldses.org>
References: <1207575514-6703-1-git-send-email-jlayton@redhat.com>
	<1207575514-6703-2-git-send-email-jlayton@redhat.com>
	<20080407164500.GA17728@infradead.org>
	<20080407175615.GD3305@fieldses.org>
	<20080407162241.0a06fd6f@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080407162241.0a06fd6f@tleilax.poochiereds.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 07, 2008 at 04:22:41PM -0400, Jeff Layton wrote:
> On Mon, 7 Apr 2008 13:56:15 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Apr 07, 2008 at 12:45:01PM -0400, Christoph Hellwig wrote:
> > > On Mon, Apr 07, 2008 at 09:38:34AM -0400, Jeff Layton wrote:
> > > > The global task and serv pointers for lockd are normally protected by
> > > > the nlmsvc_mutex. The exception is when the lockd exits abnormally. When
> > > > this occurs, these variables are cleared without any locking.
> > > 
> > > Shouldn't we get rid of the case where it exits abnormally instead?
> > 
> > I tried to figure out when this could actually occur (when can
> > svc_recv() return an error other than -EINTR or -EAGAIN?), and got lost
> > in sock_recvmsg():
> > 
> > 	- svc_recv() itself returns only -EAGAIN or the return from
> > 	  ->xpo_recvfrom().
> > 	- the only xpo_recvfrom() that's interesting is
> > 	  svc_tcp_recvfrom(), which can return the error it gets from
> > 	  svc_recvfrom(), which can return the error from
> > 	  kernel_recvmsg(), which gets its return from sock_recvmsg().
> > 
> > Since __sock_recvmsg() has a security hook, it looks like we can end up
> > with an -EACCES from selinux?
> > 
> > So one case would be selinux deciding we weren't allowed to receive
> > packets from this socket.  Huh.
> 
> I got lost there too, but I would suspect that there are other errors
> that can bubble up from the lower networking layers as well. Even if
> there aren't currently, it's probably still prudent to assume that it's
> a possibility and code for it.
> 
> I tend to think the safest thing is probably to do a long sleep (1s or
> so and retry when we get an error (maybe also a ratelimited printk?).

Yeah, I guess I can't think of anything better.

--b.

> It's unlikely to do any harm (other than a few wasted CPU cycles), and
> if the error is transient then we have the possibility to recover and
> continue normal operation.
