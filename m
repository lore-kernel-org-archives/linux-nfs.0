Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6168 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753467Ab0JTTRE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 15:17:04 -0400
Date: Wed, 20 Oct 2010 15:16:57 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>, chuck.lever@oracle.com
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 mounts take longer the fail from ENETUNREACH than NFSv3
 mounts.
Message-ID: <20101020151657.42bc53f7@tlielax.poochiereds.net>
In-Reply-To: <20101020135525.22977d8d@tlielax.poochiereds.net>
References: <20101020181701.232dbeea@notabene>
	<20101020135525.22977d8d@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 20 Oct 2010 13:55:25 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 20 Oct 2010 18:17:01 +1100
> Neil Brown <neilb@suse.de> wrote:
> 
> > 
> > 
> > If I don't have any network configured (except loop-back), and try an NFSv3
> > mount, then it fails quickly:
> > 
> > 
> > ....
> > mount.nfs: portmap query failed: RPC: Remote system error - Network is unreachable
> > mount.nfs: Network is unreachable
> > 
> > 
> > If I try the same thing with a NFSv4 mount, it times out before it fails,
> > making a much longer delay.
> > 
> > This is because mount.nfs doesn't do a portmap lookup but just leaves
> > everything to the kernel.
> > The kernel does an 'rpc_ping()' which sets RPC_TASK_SOFTCONN.
> > So at least it doesn't retry after the timeout.  But given that we have a
> > clear error, we shouldn't timeout at all.
> > 
> > Unfortunately I cannot see an easy way to fix this.
> > 
> > The place where ENETUNREACH is in xs_tcp_setup_socket.  The comment there
> > says "Retry with the same socket after a delay".  The "delay" bit is correct,
> > the "retry" isn't.
> > 
> > It would seem that we should just add a 'goto out' there if RPC_TASK_SOFTCONN
> > was set.  However we cannot see the task at this point - in fact it seems
> > that there could be a queue of tasks waiting on this connection.  I guess
> > some could be soft, and some not. ???
> > 
> > So: An suggestions how to get a ENETUNREACH (or ECONNREFUSED or similar) to
> > fail immediately when  RPC_TASK_SOFTCONN is set ???
> > 
> > 
> > This affects people who upgrade from openSUSE11.2 (which didn't support v4
> > mounts) to openSUSE11.3 (which defaults to v4) and who use network-manager
> > (which configures networks late) and have NFS mounts in /etc/fstab with
> > either explicit IP addresses or host names that can be resolved without the
> > network.
> > This config will work because when the network comes up, network-manager will
> > re-run the 'init.d/nfs' script.  However since 11.3 there is an unpleasant
> > pause before boot completes.
> > 
> 
> Took me a few tries to get an ENETUNREACH error but I see the same hang
> you do. For the record I was able to get one by not configuring an IPv6
> addr on the box and attempting to mount an IPv6 address.
> 
> Interestingly while I was trying to reproduce it, I ended up
> reproducing an EHOSTUNREACH error by trying to mount a IPv6 host to
> which I didn't have a route. That error returns quickly from the
> kernel. Maybe we can solve this simply by treating ENETUNREACH the same
> as EHOSTUNREACH in this situation?
> 
> I'm not quite sure exactly how to make that happen, but it seems like
> reasonable behavior.
> 

Sigh, nothing's ever easy in the RPC layer. Please bear with my
scatterbrained analysis...

There's a bit of difference at the socket layer between those two cases.
xs_tcp_finish_connecting calls this to connect the socket:

    kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);

...in the ENETUNREACH case, this returns immediately with the error. In
EHOSTUNREACH case, it returns EINPROGRESS and then the sk_error_report
handles the rest. Fine...we can emulate the similar behavior, but...

Then what happens is that xs_tcp_send_request gets called again to try
to resend the packet. In the EHOSTUNREACH case, that returns
EHOSTUNREACH which eventually causes an rpc_exit with that error. In
the ENETUNREACH case that returns EPIPE, which makes the state machine
move next to call_bind and the whole thing starts over again.

I'm still not sure what the right approach is here. The fact that
attempting to send on the socket in this case gives us an EPIPE makes
it tough to handle this case the same way as EHOSTUNREACH.

-- 
Jeff Layton <jlayton@redhat.com>
