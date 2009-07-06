From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind
 registrations.
Date: Mon, 06 Jul 2009 21:38:30 +0530
Message-ID: <4A52217E.9050207@suse.de>
References: <20090528062730.15937.70579.stgit@notabene.brown> <20090528063303.15937.62423.stgit@notabene.brown> <A85051CB-18EB-4003-8DD6-26D3E9968543@oracle.com> <18992.35996.986951.556723@notabene.brown> <A51FBC9A-6B56-4DF3-A657-D1E6508F8FEE@oracle.com> <E4516F53-E0D1-494D-A62C-1035D3A8F1FB@oracle.com> <4A51F125.5080709@suse.de> <A8A87823-B37B-43ED-82A1-5A822C9C880C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:53282 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197AbZGFQIg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jul 2009 12:08:36 -0400
In-Reply-To: <A8A87823-B37B-43ED-82A1-5A822C9C880C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Jul 6, 2009, at 8:42 AM, Suresh Jayaraman wrote:
>> Chuck Lever wrote:
>>> On Jun 11, 2009, at 11:44 AM, Chuck Lever wrote:
>>>> On Jun 11, 2009, at 12:48 AM, Neil Brown wrote:
>>
>>>>
>>>>> How hard would it be to add (optional) connected UDP support?  Would
>>>>> we just make the code more like the TCP version, or are there any
>>>>> gotchas that you know of that we would need to be careful of?
>>>>
>>>> The code in net/sunrpc/xprtsock.c is a bunch of transport methods,
>>>> many of which are shared between the UDP and TCP transport
>>>> capabilities.  You could probably do this easily by creating a new
>>>> xprt_class structure and a new ops vector, then reuse as many UDP
>>>> methods as possible.  The TCP connect method could be usable as is,
>>>> but it would be simple to copy-n-paste a new one if some variation is
>>>> required.  Then, define a new XPRT_ value, and use that in
>>>> rpcb_create_local().
>>
>> I attempted a patch based on your suggestions, while the socket seems
>> to be getting the -ECONNREFUSED error, but it isn't propagating all the
>> way up (yet to debug, why)
> 
> I suspect it's because a while ago Trond changed the connect logic to
> retry everything, including ECONNREFUSED.

> I've hit this problem recently as well.  The kernel's NFS mount client
> needs rpcbind to recognize when a port is not active so it can stop
> retrying that port and switch to a different transport, just as
> mount.nfs does.
> 
> We will need to add a mechanism to allow ECONNREFUSED to be propagated
> up the stack again.  Trond suggested adding a per-RPC flag (on
> rpc_call_sync()) to do this.  Connection semantics seem to me to be an
> attribute of the transport, not of a single RPC, though.  And, the
> protocol where we really need this is rpcbind, which usually creates a
> transport to send just a single RPC.
> 

Ah ok, good to know this.

BTW, it seems my questions on using RPC_CLNT_CREATE_ flag and using
AF_LOCAL sockets got overshadowed (seen below) by the patch. Would
making rpcbind using AF_LOCAL sockets a good idea or connected UDP still
seems a better solution?

>>
>>> I've thought about this some more...
>>>
>>> It seems to me that you might be better off using the existing UDP
>>> transport code, but adding a new RPC_CLNT_CREATE_ flag to enable
>>> connected UDP semantics.  The two transports are otherwise exactly the
>>> same.
>>>
>>
>> It doesn't seem that there is a clean way of doing this. The function
>> xs_setup_udp() sets up the corresponding connect_worker function which
>> actually sets up the UDP socket. There doesn't seem to be a way to check
>> whether this flag (or a new rpc_clnt->cl_ flag) is set or not in
>> either of
>> the functions.
>>
>> OTOH, why not use AF_LOCAL sockets since it's for local communication
>> only?
>>

Thanks,

-- 
Suresh Jayaraman
