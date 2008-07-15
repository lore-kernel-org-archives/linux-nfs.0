From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 14:17:26 -0400
Message-ID: <76bd70e30807151117g520f22cj1dfe26b971987d38@mail.gmail.com>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>
	 <487CC928.8070908@redhat.com>
	 <76bd70e30807150923r31027edxb0394a220bbe879b@mail.gmail.com>
	 <487CE202.2000809@redhat.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Andrew Bell" <andrew.bell.ia@gmail.com>, linux-nfs@vger.kernel.org
To: "Peter Staubach" <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:44485 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762186AbYGOSRg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 14:17:36 -0400
Received: by yw-out-2324.google.com with SMTP id 9so2627143ywe.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2008 11:17:27 -0700 (PDT)
In-Reply-To: <487CE202.2000809@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2008 at 1:44 PM, Peter Staubach <staubach@redhat.com> wrote:
> Chuck Lever wrote:
>>
>> On Tue, Jul 15, 2008 at 11:58 AM, Peter Staubach <staubach@redhat.com>
>> wrote:
>>
>>>
>>> If it is the notion described above, sometimes called head
>>> of line blocking, then we could think about ways to duplex
>>> operations over multiple TCP connections, perhaps with one
>>> connection for small, low latency operations, and another
>>> connection for larger, higher latency operations.
>>>
>>
>> I've dreamed about that for years.  I don't think it would be too
>> difficult, but one thing that has held it back is the shortage of
>> ephemeral ports on the client may reduce the number of concurrent
>> mount points we can support.
>>
>> One way to avoid the port issue is to construct an SCTP transport for
>> NFS.  SCTP allows multiple streams on the same connection, effectively
>> eliminating head of line blocking.
>
> I like the idea of combining this work with implementing a proper
> connection manager so that we don't need a connection per mount.
> We really only need one connection per client and server, no matter
> how many individual mounts there might be from that single server.
> (Or two connections, if we want to do something like this...)
>
> We could also manage the connection space and thus, never run into
> the shortage of ports ever again.  When the port space is full or
> we've run into some other artificial limit, then we simply close
> down some other connection to make space.

I think we should do this for text-based mounts; however this would
mean the connection management would happen in the kernel, which (only
slightly) complicates things.

I was thinking about this a little last week when Trond mentioned
implementing a connected UDP socket transport...

It would be nice if all the kernel RPC services that needed to send a
single RPC request (like mount, rpcbind, and so on) could share a
small managed pool of sockets (a pool of TCP sockets, or a pool of
connected UDP sockets).  Connected sockets have the ostensible
advantage that they can quickly detect the absence of a remote
listener.  But such a pool would be a good idea because multiple mount
requests to the same server could all flow over the same set of
connections.

But we might be able to get away with something nearly as efficient if
the RPC client would always invoke a connect(AF_UNSPEC) before
destroying the socket.  Wouldn't that free the ephemeral port
immediately?  What are the risks of trying something like this?

-- 
 "Alright guard, begin the unnecessarily slow-moving dipping mechanism."
--Dr. Evil
