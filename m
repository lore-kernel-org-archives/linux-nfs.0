From: Jeff Layton <jlayton@redhat.com>
Subject: Re: nfs-utils: support/nfs/rpcmisc.c
Date: Wed, 28 Jan 2009 11:37:49 -0500
Message-ID: <20090128113749.7893533a@tleilax.poochiereds.net>
References: <619E3D97-A202-4F6C-B308-B631F470A8E0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Olaf Kirch <okir@suse.de>, Neil Brown <neilb@suse.de>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50256 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbZA1QiF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2009 11:38:05 -0500
In-Reply-To: <619E3D97-A202-4F6C-B308-B631F470A8E0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 27 Jan 2009 15:20:02 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi all-
> 
> I've been stuck on updating the rpc_init() function in support/nfs/ 
> rpcmisc.c to use TI-RPC functions for a while now.  This week I found  
> yet another issue, and would like to ask your opinion about how to  
> architect a solution.
> 
> rpc_init() is used only by rpc.statd and rpc.mountd, to set up their  
> RPC listeners.  It has logic in it to detect the case where fd 0 is a  
> socket being passed in from inetd (I think that's what this does).
> 

Weird. That would be my guess too...

> It also has some statics to save the UDP and TCP listener xprt's from  
> a previous call, so it doesn't create these again.  Specifically for  
> rpc.statd, rpc_init() is called only once to set up the UDP and TCP  
> listeners, so I don't think those statics would ever be referenced  
> after being set during the first call.
> 
> Does rpc_init() really need to save the xprts for rpc.statd?   
> rpc_init() peeks at xp_port in the returned SVC_XPRT to decide whether  
> to use the saved xprt, but TI-RPC's service creation API doesn't fill  
> this field in.  So this logic won't even work for xprts created with  
> TI-RPC calls.  I seem to recall seeing some code in libtirpc that  
> already checks a list of xprts to prevent the creation of duplicates.
> 

It doesn't look like this is necessary for statd. rpc_init looks like
it's only called once from main() before you enter the service loop,
so I don't think statd will ever have the opportunity to create a
duplicate xprt.

> I also notice that rpc_init() uses xlog() to report errors, whereas  
> rpc.statd uses note(), and does not initialize the xlog() reporting  
> framework.  So rpc.statd problems in this area are sporadically  
> reported, often without any identifying program name.
> 
> And, for rpc.statd, do the listener sockets need to be non-blocking?   
> There are four paths in rpc_init() that create listener sockets:  one  
> is by passing RPC_ANYSOCK to the RPC library; one is using the pre- 
> existing fd 0 if it's a socket.  The other two are local  
> implementations that create a fresh socket, but one sets O_NONBLOCK,  
> and the other doesn't.  As far as I can tell, O_NONBLOCK support was  
> added just for rpc.mountd, but three of these four paths probably do  
> not create non-blocking listener sockets.  What does rpc.statd need?
> 

Not sure on this. My gut feeling says that blocking sockets are OK
for statd given that it's single threaded (right?), but I've not walked
through the code carefully enough to be sure.

> I'm considering creating a version of rpc_init() under utils/statd  
> that strips out all of the unnecessary features, uses note() instead  
> of xlot(), and then adds support for AF_INET6.
> 

Is there some reason to not just convert statd to use xlog()? It
seems like that would be a better long term solution.

For a proof-of-concept sort of thing, that might be reasonable though.

-- 
Jeff Layton <jlayton@redhat.com>
