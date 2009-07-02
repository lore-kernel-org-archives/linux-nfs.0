From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind registrations.
Date: Thu, 2 Jul 2009 16:04:12 -0400
Message-ID: <E4516F53-E0D1-494D-A62C-1035D3A8F1FB@oracle.com>
References: <20090528062730.15937.70579.stgit@notabene.brown> <20090528063303.15937.62423.stgit@notabene.brown> <A85051CB-18EB-4003-8DD6-26D3E9968543@oracle.com> <18992.35996.986951.556723@notabene.brown> <A51FBC9A-6B56-4DF3-A657-D1E6508F8FEE@oracle.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:29149 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049AbZGBUER (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2009 16:04:17 -0400
In-Reply-To: <A51FBC9A-6B56-4DF3-A657-D1E6508F8FEE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 11, 2009, at 11:44 AM, Chuck Lever wrote:
> On Jun 11, 2009, at 12:48 AM, Neil Brown wrote:
>> On Thursday May 28, chuck.lever@oracle.com wrote:
>>> On May 28, 2009, at 2:33 AM, NeilBrown wrote:
>>>>
>>>> [An alternate might be to make the sunrpc code always "connect"
>>>> udp sockets so that "port not reachable" errors would get reported
>>>> back.  This requires a more intrusive change though and might have
>>>> other consequences]
>>>
>>> We had discussed this about a year ago when I started adding IPv6
>>> support.  I had suggested switching the local rpc client to use TCP
>>> instead of UDP to solve exactly this time-out problem during start-
>>> up.  There was some resistance to the idea because TCP would leave
>>> privileged ports in TIMEWAIT (at shutdown, this is probably not a
>>> significant concern).
>>>
>>> Trond had intended to introduce connected UDP socket support to the
>>> RPC client, although we were also interested in someday having a
>>> single UDP socket for all RPC traffic... the design never moved on
>>> from there.
>>>
>>> My feeling at this point is that having a connected UDP socket
>>> transport would be simpler and have broader benefits than waiting  
>>> for
>>> an eventual design that can accommodate multiple transport instances
>>> sharing a single socket.
>>
>> The use of connected UDP would have to be limited to known-safe cases
>> such as contacting the local portmap.  I believe there are still NFS
>> servers out there that - if multihomed - can reply from a different
>> address to the one the request was sent to.
>
> I think I advocated for adding an entirely new transport capability  
> called CUDP at the time.  But this is definitely something to  
> remember as we test.
>
> If a new transport capability is added, at this point we would  
> likely need some additional logic in the NFS mount parsing logic to  
> expose such a transport to user space.  So, leaving that parsing  
> logic alone should insulate the NFS client from the new transport  
> until we have more confidence.
>
>> And we would need to check that rpcbind does the right thing.  I
>> recently discovered that rpcbind is buggy and will sometimes respond
>> from the wrong interface - I suspect localhost addresses are safe,  
>> but
>> we would need to check, or fix it (I fixed that bug in portmap (glibc
>> actually) 6 years ago and now it appears again in rpcbind - groan!).
>
> Details welcome.  We will probably need to fix libtirpc.
>
>> How hard would it be to add (optional) connected UDP support?  Would
>> we just make the code more like the TCP version, or are there any
>> gotchas that you know of that we would need to be careful of?
>
> The code in net/sunrpc/xprtsock.c is a bunch of transport methods,  
> many of which are shared between the UDP and TCP transport  
> capabilities.  You could probably do this easily by creating a new  
> xprt_class structure and a new ops vector, then reuse as many UDP  
> methods as possible.  The TCP connect method could be usable as is,  
> but it would be simple to copy-n-paste a new one if some variation  
> is required.  Then, define a new XPRT_ value, and use that in  
> rpcb_create_local().

I've thought about this some more...

It seems to me that you might be better off using the existing UDP  
transport code, but adding a new RPC_CLNT_CREATE_ flag to enable  
connected UDP semantics.  The two transports are otherwise exactly the  
same.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
