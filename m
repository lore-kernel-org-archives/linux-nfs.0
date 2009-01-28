From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs-utils: support/nfs/rpcmisc.c
Date: Wed, 28 Jan 2009 12:59:15 -0500
Message-ID: <33CA49FD-8BC7-458A-BCEE-D264456F15BA@oracle.com>
References: <619E3D97-A202-4F6C-B308-B631F470A8E0@oracle.com> <49804DAC.2000309@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Olaf Kirch <okir@suse.de>, Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:56851 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbZA1R7o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 12:59:44 -0500
In-Reply-To: <49804DAC.2000309-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 28, 2009, at 7:21 AM, Steve Dickson wrote:
> Chuck Lever wrote:
>> Hi all-
>>
>> I've been stuck on updating the rpc_init() function in
>> support/nfs/rpcmisc.c to use TI-RPC functions for a while now.  This
>> week I found yet another issue, and would like to ask your opinion  
>> about
>> how to architect a solution.
>>
>> rpc_init() is used only by rpc.statd and rpc.mountd, to set up  
>> their RPC
>> listeners.  It has logic in it to detect the case where fd 0 is a  
>> socket
>> being passed in from inetd (I think that's what this does).
> I would have to agree... why else would a getsockname(0, ....) be  
> done?
>
>> It also has some statics to save the UDP and TCP listener xprt's  
>> from a
>> previous call, so it doesn't create these again.  Specifically for
>> rpc.statd, rpc_init() is called only once to set up the UDP and TCP
>> listeners, so I don't think those statics would ever be referenced  
>> after
>> being set during the first call.
>>
>> Does rpc_init() really need to save the xprts for rpc.statd?   
>> rpc_init()
>> peeks at xp_port in the returned SVC_XPRT to decide whether to use  
>> the
>> saved xprt, but TI-RPC's service creation API doesn't fill this field
>> in.  So this logic won't even work for xprts created with TI-RPC  
>> calls.
>> I seem to recall seeing some code in libtirpc that already checks a  
>> list
>> of xprts to prevent the creation of duplicates.
> I would say no... reusing connections is always a tricky proposition  
> at best
> and generally fairly error prone... but if we were going to reuse  
> connections
> I would like to see the logic broken out into to different routines,  
> similar
> to rpc_init() and rpc_reinit()...

Well, AFAICT it's not re-using the listeners, but allowing other  
versions of the RPC protocol to be handled by the same listener socket.

It looks to me like TI-RPC handles this automatically in the library  
already, but legacy RPC may have required some special logic to deal  
with registering multiple versions of the mountd protocol on the same  
port.

This saves a port number or two, but it means that all these mountd  
processes share the same socket, which may limit scalability somewhat.

>> I also notice that rpc_init() uses xlog() to report errors, whereas
>> rpc.statd uses note(), and does not initialize the xlog() reporting
>> framework.  So rpc.statd problems in this area are sporadically
>> reported, often without any identifying program name.
> This is one area that nfs-utils is a bit out of control... every
> daemon seems to have it own way of logging...
>
>> And, for rpc.statd, do the listener sockets need to be non-blocking?
>> There are four paths in rpc_init() that create listener sockets:   
>> one is
>> by passing RPC_ANYSOCK to the RPC library; one is using the pre- 
>> existing
>> fd 0 if it's a socket.  The other two are local implementations that
>> create a fresh socket, but one sets O_NONBLOCK, and the other  
>> doesn't.
>> As far as I can tell, O_NONBLOCK support was added just for  
>> rpc.mountd,
>> but three of these four paths probably do not create non-blocking
>> listener sockets.  What does rpc.statd need?
> I would say no... The O_NONBLOCK business seems to be needed for  
> mountd to
> run with multiple processes reading from the same socket... Since  
> statd
> does not do this, there is no needed for  O_NONBLOCK to be set...
>
>> I'm considering creating a version of rpc_init() under utils/statd  
>> that
>> strips out all of the unnecessary features, uses note() instead of
>> xlot(), and then adds support for AF_INET6.
> I would say... clean it up... esp when it comes to using the same  
> logging
> routines...

I'm working on this right now.  It seems the requirements for mountd  
and statd are different enough that it makes sense for each to have  
its own.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
