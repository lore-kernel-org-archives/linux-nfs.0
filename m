Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47902 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754011Ab0K2U7l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 15:59:41 -0500
Date: Mon, 29 Nov 2010 15:59:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: Mark Hills <mark@pogo.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: Listen backlog set to 64
Message-ID: <20101129205935.GD9897@fieldses.org>
References: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz>
 <20101116182026.GA3971@fieldses.org>
 <20101117090826.4b2724da@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101117090826.4b2724da@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Nov 17, 2010 at 09:08:26AM +1100, Neil Brown wrote:
> On Tue, 16 Nov 2010 13:20:26 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Nov 15, 2010 at 06:43:52PM +0000, Mark Hills wrote:
> > > I am looking into an issue of hanging clients to a set of NFS servers, on 
> > > a large HPC cluster.
> > > 
> > > My investigation took me to the RPC code, svc_create_socket().
> > > 
> > > 	if (protocol == IPPROTO_TCP) {
> > > 		if ((error = kernel_listen(sock, 64)) < 0)
> > > 			goto bummer;
> > > 	}
> > > 
> > > A fixed backlog of 64 connections at the server seems like it could be too 
> > > low on a cluster like this, particularly when the protocol opens and 
> > > closes the TCP connection.
> > > 
> > > I wondered what is the rationale is behind this number, particuarly as it 
> > > is a fixed value. Perhaps there is a reason why this has no effect on 
> > > nfsd, or is this a FAQ for people on large systems?
> > > 
> > > The servers show overflow of a listening queue, which I imagine is 
> > > related.
> > > 
> > >   $ netstat -s
> > >   [...]
> > >   TcpExt:
> > >     6475 times the listen queue of a socket overflowed
> > >     6475 SYNs to LISTEN sockets ignored
> > > 
> > > The affected servers are old, kernel 2.6.9. But this limit of 64 is 
> > > consistent across that and the latest kernel source.
> > 
> > Looks like the last time that was touched was 8 years ago, by Neil (below, from
> > historical git archive).
> > 
> > I'd be inclined to just keep doubling it until people don't complain,
> > unless it's very expensive.  (How much memory (or whatever else) does a
> > pending connection tie up?)
> 
> Surely we should "keep multiplying by 13" as that is what I did :-)
> 
> There is a sysctl 'somaxconn' which limits what a process can ask for in the
> listen() system call, but as we bypass this syscall it doesn't directly
> affect nfsd.
> It defaults to SOMAXCONN == 128 but can be raised arbitrarily by the sysadmin.
> 
> There is another sysctl 'max_syn_backlog' which looks like a system-wide
> limit to the connect backlog.
> This defaults to 256.  The comment says it is
> adjusted between 128 and 1024 based on memory size, though that isn't clear
> in the code (to me at least).

This comment?:

/*
 * Maximum number of SYN_RECV sockets in queue per LISTEN socket.
 * One SYN_RECV socket costs about 80bytes on a 32bit machine.
 * It would be better to replace it with a global counter for all sockets
 * but then some measure against one socket starving all other sockets
 * would be needed.
 *
 * It was 128 by default. Experiments with real servers show, that
 * it is absolutely not enough even at 100conn/sec. 256 cures most
 * of problems. This value is adjusted to 128 for very small machines
 * (<=32Mb of memory) and to 1024 on normal or better ones (>=256Mb).
 * Note : Dont forget somaxconn that may limit backlog too.
 */
int sysctl_max_syn_backlog = 256;

Looks like net/ipv4/tcp.c:tcp_init() does the memory-based calculation.

80 bytes sounds small.

> So we could:
>   - hard code a new number
>   - make this another sysctl configurable
>   - auto-adjust it so that it "just works".
> 
> I would prefer the latter if it is possible.   Possibly we could adjust it
> based on the number of nfsd threads, like we do for receive buffer space.
> Maybe something arbitrary like:
>    min(16 + 2 * number of threads, sock_net(sk)->core.sysctl_somaxconn)
> 
> which would get the current 64 at 24 threads, and can easily push up to 128
> and beyond with more threads.
> 
> Or is that too arbitrary?

I kinda like the idea of piggybacking on an existing constant like
sysctl_max_syn_backlog.  Somebody else hopefully keeps it set to something
reasonable, and we as a last resort it gives you a knob to twiddle.

But number of threads would work OK too.

At a minimum we should make sure we solve the original problem....
Mark, have you had a chance to check whether increasing that number to
128 or more is enough to solve your problem?

--b.
