Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:48475 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188AbbFHSMM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2015 14:12:12 -0400
Date: Mon, 8 Jun 2015 20:12:10 +0200
From: Guillaume Morin <guillaume@morinfr.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Guillaume Morin <guillaume@morinfr.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chris Mason <clm@fb.com>
Subject: Re: [BUG] nfs3 client stops retrying to connect
Message-ID: <20150608181210.GA18244@bender.morinfr.org>
References: <20150521012155.GA19680@bender.morinfr.org>
 <DAF3CB64-5777-4F74-A31E-4F3FE55D14AD@gmail.com>
 <20150604200621.GA10335@bender.morinfr.org>
 <1E6DAEB8-754B-4F88-8301-4A1A9134922A@gmail.com>
 <20150604221404.GA20363@bender.morinfr.org>
 <22109174-5489-46AB-8C0A-62840D63DC97@gmail.com>
 <20150608171006.GA13396@bender.morinfr.org>
 <21A8A567-1EB4-4E3A-8DB8-BD07212044D0@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <21A8A567-1EB4-4E3A-8DB8-BD07212044D0@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08 Jun 13:50, Chuck Lever wrote:
> The linger timer is started by FIN_WAIT1 or LAST_ACK, and
> xs_tcp_schedule_linger_timeout sets XPRT_CONNECTING and
> XPRT_CONNECTION_ABORT.
> 
> At a guess there could be a race between xs_tcp_cancel_linger_timeout
> and the connect worker clearing those flags.

The connect worker is xs_tcp_setup_socket().  It clears the connecting
bit in all code paths.  So the only kind of race I can see here is
another function cancelling it before it runs without clearing the bit.

xs_tcp_cancel_linger_timeout() does the right thing afaict.  It clears
the bit if cancel_delayed_work() returns a non-zero value.

The only other place where the worker is cancelled is xs_close() but it
does not clear the bit. So if it cancels the worker before it had
started running, the bit will stay up.

> AFAICT ->close is invoked when the transport is being shut down, in other
> words at umount time. It is also invoked when the autoclose timer fires.
> 
> Autoclose is simply a mechanism for reaping NFS sockets that are idle.
> I think the timer is 5 or 6 minutes.
> 
> Autoclose won't fire if there is frequent work being done on the mount
> point. If this is related to autoclose, then the workload on the client
> might need to be sparse (NFS requests only every few minutes or so) to
> reproduce it.
> 
> For example, autoclose fires and tries to shut down the socket after the
> server is no longer responding.

It does not seem that autoclose is the cause here since it has happened
only during server outages. 

If autoclose and umount are the only thing that can call xs_close(),
that seems unlikely to eb the problem.  But I see that xprt_connect()
can call it too so that gives me some hope

> > We had to move an nfs server on friday and I got a few machines that had
> > the same issue again?
> 
> That suggests one requirement for your reproducer: after clients have
> mounted it, the NFS server needs to be fully down for an extended period.

Yes, it seems to be the case but if it's a race this just gives more
opportunity to race.

> Since some clients recovered, I assume the server retained its IP address.
> Did the network route change?

No the route did not change

-- 
Guillaume Morin <guillaume@morinfr.org>
