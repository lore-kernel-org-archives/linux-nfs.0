Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3786 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757668Ab0JUOGj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 10:06:39 -0400
Subject: Re: NFSv4 mounts take longer the fail from ENETUNREACH than NFSv3
 mounts.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Neil Brown <neilb@suse.de>
Cc: Jeff Layton <jlayton@redhat.com>, chuck.lever@oracle.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20101021142518.3934ae17@notabene>
References: <20101020181701.232dbeea@notabene>
	 <20101020135525.22977d8d@tlielax.poochiereds.net>
	 <20101020151657.42bc53f7@tlielax.poochiereds.net>
	 <20101021074028.44bca336@notabene>
	 <20101020204532.2019eb93@corrin.poochiereds.net>
	 <20101021142518.3934ae17@notabene>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Oct 2010 10:05:39 -0400
Message-ID: <1287669939.3645.12.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-10-21 at 14:25 +1100, Neil Brown wrote:
> On Wed, 20 Oct 2010 20:45:32 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Thu, 21 Oct 2010 07:40:28 +1100
> > Neil Brown <neilb@suse.de> wrote:
> > 
> > > > 
> > > > Then what happens is that xs_tcp_send_request gets called again to try
> > > > to resend the packet. In the EHOSTUNREACH case, that returns
> > > > EHOSTUNREACH which eventually causes an rpc_exit with that error. In
> > > > the ENETUNREACH case that returns EPIPE, which makes the state machine
> > > > move next to call_bind and the whole thing starts over again.
> > > 
> > > This confuses me.  Why would  xs_tcp_send_request (aka ->send_request) get
> > > called before the connect has succeeded?  Can you make sense of that?
> > > 
> > 
> > It confuses me too. I suspect that this may actually be a bug...
> > 
> > So EINPROGRESS makes the connect_worker task clear the connecting bit
> > and return. Eventually, the EHOSTUNREACH error is reported to
> > xs_error_report. That function does this:
> > 
> >         xprt_wake_pending_tasks(xprt, -EAGAIN);
> > 
> > The task that was waiting on the connect_worker is then woken up.
> > call_connect_status does this:
> > 
> >         if (status >= 0 || status == -EAGAIN) {
> >                 clnt->cl_stats->netreconn++;
> >                 task->tk_action = call_transmit;
> >                 return;
> >         }
> > 
> > ...and we end up in call_transmit without the socket being connected.
> > 
> > So I understand how this happened, but I don't really understand the
> > design of the connect mechanism well enough to know whether this is
> > by design or not.
> > 
> 
> Now that *is* interesting.....
> 
> I thought that code in call_connect_status was hard to understand too, so I
> asked git who to blame it on. It said:
> 
> commit 2a4919919a97911b0aa4b9f5ac1eab90ba87652b
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Wed Mar 11 14:38:00 2009 -0400
> 
>     SUNRPC: Return EAGAIN instead of ENOTCONN when waking up xprt->pending
>     
>     While we should definitely return socket errors to the task that is
>     currently trying to send data, there is no need to propagate the same error
>     to all the other tasks on xprt->pending. Doing so actually slows down
>     recovery, since it causes more than one tasks to attempt socket recovery.
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> 
> 
> That commit not only adds the "status == -EAGAIN" test, but also introduced
> some of the xprtsock.c code that I suggested changing in a previous patch.

That is because ENOTCONN was trying to report the current state of the
socket to a bunch of tasks on the 'pending' list. The problem is that
because none of those tasks hold any form of lock, then by the time they
get round to processing that ENOTCONN, the state of the socket can (and
usually will) have changed.

> So there seem to be some correlation between that commit and the present
> problem.
> 
> I tried compiling the kernel just prior to that commit, and 
>   mount -t nfs4 unrouteable.ip.addres:/ /mnt
> 
> took 3 seconds to time fail.
> 
> I then stepped forward to that commit and the same command took 3 *minutes* to
> time out.  So something isn't right there.  Unfortunately I don't know what.
> 
> Trond: can you comment on this - maybe explain the reasoning behind that
> commit better, and suggest how we can get ENOTCONN to fail SOFTCONN
> connections faster without undoing the things this patch tried to achieve?

It seems to me that the problem is basically that RPC_IS_SOFTCONN is
poorly defined. IMO, the definition should really be that
'RPC_IS_SOFTCONN' tasks MUST exit with an error if they ever have to run
call_bind or a call_connect more than once (i.e. if they ever have to
loop back).

With that in mind, I really don't see why the RPC_IS_SOFTCONN case is
being handled in call_transmit_status() instead of in call_status().
I furthermore don't see why ECONNRESET, ENOTCONN and EPIPE should be
treated any differently from ECONNREFUSED, EHOSTDOWN, EHOSTUNREACH and
ENETUNREACH.

Cheers
  Trond
