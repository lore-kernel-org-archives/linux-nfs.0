From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs-utils: support/nfs/rpcmisc.c
Date: Wed, 28 Jan 2009 07:21:00 -0500
Message-ID: <49804DAC.2000309@RedHat.com>
References: <619E3D97-A202-4F6C-B308-B631F470A8E0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Olaf Kirch <okir@suse.de>, Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42871 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212AbZA1MXb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2009 07:23:31 -0500
In-Reply-To: <619E3D97-A202-4F6C-B308-B631F470A8E0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> Hi all-
> 
> I've been stuck on updating the rpc_init() function in
> support/nfs/rpcmisc.c to use TI-RPC functions for a while now.  This
> week I found yet another issue, and would like to ask your opinion about
> how to architect a solution.
> 
> rpc_init() is used only by rpc.statd and rpc.mountd, to set up their RPC
> listeners.  It has logic in it to detect the case where fd 0 is a socket
> being passed in from inetd (I think that's what this does).
I would have to agree... why else would a getsockname(0, ....) be done?

> 
> It also has some statics to save the UDP and TCP listener xprt's from a
> previous call, so it doesn't create these again.  Specifically for
> rpc.statd, rpc_init() is called only once to set up the UDP and TCP
> listeners, so I don't think those statics would ever be referenced after
> being set during the first call.
> 
> Does rpc_init() really need to save the xprts for rpc.statd?  rpc_init()
> peeks at xp_port in the returned SVC_XPRT to decide whether to use the
> saved xprt, but TI-RPC's service creation API doesn't fill this field
> in.  So this logic won't even work for xprts created with TI-RPC calls. 
> I seem to recall seeing some code in libtirpc that already checks a list
> of xprts to prevent the creation of duplicates.
I would say no... reusing connections is always a tricky proposition at best
and generally fairly error prone... but if we were going to reuse connections
I would like to see the logic broken out into to different routines, similar
to rpc_init() and rpc_reinit()... 
  
> 
> I also notice that rpc_init() uses xlog() to report errors, whereas
> rpc.statd uses note(), and does not initialize the xlog() reporting
> framework.  So rpc.statd problems in this area are sporadically
> reported, often without any identifying program name.
This is one area that nfs-utils is a bit out of control... every 
daemon seems to have it own way of logging... 

> 
> And, for rpc.statd, do the listener sockets need to be non-blocking? 
> There are four paths in rpc_init() that create listener sockets:  one is
> by passing RPC_ANYSOCK to the RPC library; one is using the pre-existing
> fd 0 if it's a socket.  The other two are local implementations that
> create a fresh socket, but one sets O_NONBLOCK, and the other doesn't. 
> As far as I can tell, O_NONBLOCK support was added just for rpc.mountd,
> but three of these four paths probably do not create non-blocking
> listener sockets.  What does rpc.statd need?
I would say no... The O_NONBLOCK business seems to be needed for mountd to
run with multiple processes reading from the same socket... Since statd 
does not do this, there is no needed for  O_NONBLOCK to be set...

> 
> I'm considering creating a version of rpc_init() under utils/statd that
> strips out all of the unnecessary features, uses note() instead of
> xlot(), and then adds support for AF_INET6.
I would say... clean it up... esp when it comes to using the same logging
routines... 


steved.
