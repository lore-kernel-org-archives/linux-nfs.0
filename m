From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NLM: hold BKL when clearing global lockd task and serv
 vars
Date: Tue, 8 Apr 2008 15:16:18 -0400
Message-ID: <20080408151618.0c4bdfb0@tleilax.poochiereds.net>
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
Received: from mx1.redhat.com ([66.187.233.31]:40478 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752295AbYDHTQX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 15:16:23 -0400
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

This turns out to be rather difficult. SELinux apparently doesn't have
much support for restricting kernel threads. I ended up hacking
together the following fault-injection patch to unit test this:

--------[snip]--------
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 10709cb..3e86cba 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -24,6 +24,7 @@
 #define RPCDBG_SVCDSP		0x0200
 #define RPCDBG_MISC		0x0400
 #define RPCDBG_CACHE		0x0800
+#define RPCDBG_BREAKME		0x1000
 #define RPCDBG_ALL		0x7fff
 
 #ifdef __KERNEL__
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d8e8d79..0333c64 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -569,6 +569,9 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	struct xdr_buf		*arg;
 	DECLARE_WAITQUEUE(wait, current);
 
+	if (rpc_debug & RPCDBG_BREAKME)
+		return -EACCES;
+
 	dprintk("svc: server %p waiting for data (to = %ld)\n",
 		rqstp, timeout);
--------[snip]--------


...with that, I can see the new code working as expected, but I think
you have a point that those printk's could get to be rather annoying.
I've got a new set of patches that I'll send out that has it only print
the warning on the first unexpected error, or if the error changes.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
