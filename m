Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763087Ab3ECSYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 May 2013 14:24:24 -0400
Date: Fri, 3 May 2013 14:24:21 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: long delay when mounting due to SETCLIENTID AUTH_GSS attempts
Message-ID: <20130503142421.19fb3ca6@tlielax.poochiereds.net>
In-Reply-To: <AE700845-4032-4BEC-817C-97EB08A831E8@oracle.com>
References: <20130503132557.2fdf794d@tlielax.poochiereds.net>
	<AE700845-4032-4BEC-817C-97EB08A831E8@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 3 May 2013 13:56:13 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On May 3, 2013, at 1:25 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > I've noticed that when running a 3.10-pre kernel that if I try to mount
> > up a NFSv4 filesystem that it now takes ~15s for the mount to complete.
> > 
> > Here's a little rpcdebug output:
> > 
> > [ 3056.385078] svc: server ffff8800368fc000 waiting for data (to = 9223372036854775807)
> > [ 3056.392056] RPC:       new task initialized, procpid 2471
> > [ 3056.392758] RPC:       allocated task ffff88010cd90100
> > [ 3056.393303] RPC:    42 __rpc_execute flags=0x1280
> > [ 3056.393630] RPC:    42 call_start nfs4 proc SETCLIENTID (sync)
> > [ 3056.394056] RPC:    42 call_reserve (status 0)
> > [ 3056.394368] RPC:    42 reserved req ffff8801019f9600 xid 21ad6c40
> > [ 3056.394783] RPC:       wake_up_first(ffff88010a989990 "xprt_sending")
> > [ 3056.395252] RPC:    42 call_reserveresult (status 0)
> > [ 3056.395595] RPC:    42 call_refresh (status 0)
> > [ 3056.395901] RPC:       gss_create_cred for uid 0, flavor 390004
> > [ 3056.396361] RPC:       gss_create_upcall for uid 0
> > [ 3071.396134] RPC: AUTH_GSS upcall timed out.
> > Please check user daemon is running.
> > [ 3071.397374] RPC:       gss_create_upcall for uid 0 result -13
> > [ 3071.398192] RPC:    42 call_refreshresult (status -13)
> > [ 3071.398873] RPC:    42 call_refreshresult: refresh creds failed with error -13
> > [ 3071.399881] RPC:    42 return 0, status -13
> > 
> > The problem is that we're now trying to upcall for GSS creds to do the
> > SETCLIENTID call, but this host isn't running rpc.gssd. Not running
> > rpc.gssd is pretty common for people not using kerberized NFS. I think
> > we'll see a lot of complaints about this.
> > 
> > Is this expected?
> 
> Yes.
> 
> There are operations like SETCLIENTID and GETATTR(fs_locations) which should always use an integrity-checking security flavor, even if particular mount points use sec=sys.
> 
> There are cases where GSS is not available, and we fall back to using AUTH_SYS.  That should happen as quickly as possible, I agree.
> 
> > If so, what's the proposed remedy?
> > Simply have everyone run rpc.gssd even if they're not using kerberized NFS?
> 
> 
> That's one possibility.  Or we could shorten the upcall timeout.  Or, add a mechanism by which rpc.gssd can provide a positive indication to the kernel that it is running.
> 
> It doesn't seem like an intractable problem.
> 

Nope, it's not intractable at all...

Currently, the gssd upcall uses the RPC_PIPE_WAIT_FOR_OPEN flag to
allow you to queue upcalls to be processed when the daemon isn't up
yet. When the daemon starts, it processes that queue. The caller gives
up after 15s (which is what's happening here), and the upcall
eventually gets scraped out of the queue after 30s.

We could stop using that flag on this rpc_pipe and simply require that
the daemon be up and running before attempting any sort of AUTH_GSS
rpc. That might be a little less friendly in the face of boot-time
ordering problems, but it should presumably make this problem go away.

-- 
Jeff Layton <jlayton@redhat.com>
