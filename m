Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:48817 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933827Ab3ECR4U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 May 2013 13:56:20 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: long delay when mounting due to SETCLIENTID AUTH_GSS attempts
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130503132557.2fdf794d@tlielax.poochiereds.net>
Date: Fri, 3 May 2013 13:56:13 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <AE700845-4032-4BEC-817C-97EB08A831E8@oracle.com>
References: <20130503132557.2fdf794d@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 3, 2013, at 1:25 PM, Jeff Layton <jlayton@redhat.com> wrote:

> I've noticed that when running a 3.10-pre kernel that if I try to mount
> up a NFSv4 filesystem that it now takes ~15s for the mount to complete.
> 
> Here's a little rpcdebug output:
> 
> [ 3056.385078] svc: server ffff8800368fc000 waiting for data (to = 9223372036854775807)
> [ 3056.392056] RPC:       new task initialized, procpid 2471
> [ 3056.392758] RPC:       allocated task ffff88010cd90100
> [ 3056.393303] RPC:    42 __rpc_execute flags=0x1280
> [ 3056.393630] RPC:    42 call_start nfs4 proc SETCLIENTID (sync)
> [ 3056.394056] RPC:    42 call_reserve (status 0)
> [ 3056.394368] RPC:    42 reserved req ffff8801019f9600 xid 21ad6c40
> [ 3056.394783] RPC:       wake_up_first(ffff88010a989990 "xprt_sending")
> [ 3056.395252] RPC:    42 call_reserveresult (status 0)
> [ 3056.395595] RPC:    42 call_refresh (status 0)
> [ 3056.395901] RPC:       gss_create_cred for uid 0, flavor 390004
> [ 3056.396361] RPC:       gss_create_upcall for uid 0
> [ 3071.396134] RPC: AUTH_GSS upcall timed out.
> Please check user daemon is running.
> [ 3071.397374] RPC:       gss_create_upcall for uid 0 result -13
> [ 3071.398192] RPC:    42 call_refreshresult (status -13)
> [ 3071.398873] RPC:    42 call_refreshresult: refresh creds failed with error -13
> [ 3071.399881] RPC:    42 return 0, status -13
> 
> The problem is that we're now trying to upcall for GSS creds to do the
> SETCLIENTID call, but this host isn't running rpc.gssd. Not running
> rpc.gssd is pretty common for people not using kerberized NFS. I think
> we'll see a lot of complaints about this.
> 
> Is this expected?

Yes.

There are operations like SETCLIENTID and GETATTR(fs_locations) which should always use an integrity-checking security flavor, even if particular mount points use sec=sys.

There are cases where GSS is not available, and we fall back to using AUTH_SYS.  That should happen as quickly as possible, I agree.

> If so, what's the proposed remedy?
> Simply have everyone run rpc.gssd even if they're not using kerberized NFS?


That's one possibility.  Or we could shorten the upcall timeout.  Or, add a mechanism by which rpc.gssd can provide a positive indication to the kernel that it is running.

It doesn't seem like an intractable problem.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




