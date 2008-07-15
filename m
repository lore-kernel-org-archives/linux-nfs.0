From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 13:20:49 -0400
Message-ID: <76bd70e30807151020j6cefbe71p8ce156b1c8fb2d86@mail.gmail.com>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>
	 <487CC928.8070908@redhat.com>
	 <76bd70e30807150923r31027edxb0394a220bbe879b@mail.gmail.com>
	 <e80abd30807150934tc14e793ydd7aae44b4c3111b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "Andrew Bell" <andrew.bell.ia@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:34602 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbYGORUv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 13:20:51 -0400
Received: by yw-out-2324.google.com with SMTP id 9so2622456ywe.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2008 10:20:50 -0700 (PDT)
In-Reply-To: <e80abd30807150934tc14e793ydd7aae44b4c3111b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2008 at 12:34 PM, Andrew Bell <andrew.bell.ia@gmail.com> wrote:
> On Tue, Jul 15, 2008 at 11:23 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> On Tue, Jul 15, 2008 at 11:58 AM, Peter Staubach <staubach@redhat.com> wrote:
>>> If it is the notion described above, sometimes called head
>>> of line blocking, then we could think about ways to duplex
>>> operations over multiple TCP connections, perhaps with one
>>> connection for small, low latency operations, and another
>>> connection for larger, higher latency operations.
>>
>> I've dreamed about that for years.  I don't think it would be too
>> difficult, but one thing that has held it back is the shortage of
>> ephemeral ports on the client may reduce the number of concurrent
>> mount points we can support.
>
> Could one come up with a way to insert "small" ops somewhere in middle
> of the existing queue, or are the TCP send buffers typically too deep
> for this to do much good?  Seems like more than one connection would
> allow "good" servers to handle requests simultaneously anyway.

There are several queues inside the NFS client stack.

The underlying RPC client manages a slot table.  Each slot contains
one pending RPC request; ie an RPC has been sent and this slot held is
waiting for the reply.  The table contains 16 slots by default.  You
can adjust the size (up to 128 slots) via a sysctl, and that may help
your situation by allowing more reads or writes to go to the server at
once.

The RPC client allows a single RPC to be sent on the socket at a time.
 (Waiting for the reply is asynchronous, so the next request can be
sent on the socket as soon as this one is done being sent).

Especially for large requests, this may mean waiting for the socket
buffer to be emptied before more data can be sent.  The socket is held
for each each request until it is entirely sent so that data for
different requests are not intermingled.  If the network is not
congested, this is generally not a problem, but if the server is
backed up, it can take a while before the buffer is ready for more
data from a single large request.

Before an RPC gets into a slot, though, it waits on a backlog queue.
This queue can grow quite long in situations where there are a lot of
reads or writes and the server or network is slow.

The Python scripts I mentioned before have information about the
backlog queue size, slot table utilization, and per-operation average
latency.  So you can clearly determine what the client is waiting for.

> Is there really that big a shortage of ephemeral ports?

Yes.  The NFS client uses only privileged ports (although you can
optionally tell it to use non-privileged ports as well).  For
long-lived sockets (such as transport sockets for NFS), it is careful
to choose privileged ports that are not a "well known" service (eg
port 22 is the standard ssh service port).  So the default port range
is roughly between 670 and 1023.

>> One way to avoid the port issue is to construct an SCTP transport for
>> NFS.  SCTP allows multiple streams on the same connection, effectively
>> eliminating head of line blocking.
>
> Waiting for SCTP sounds like a long-term solution, as server vendors
> probably have little incentive.

Yep.

> Thanks for the ideas.  I'll have to see what kind of time I can get to
> investigate this stuff.

We neglected to mention that you can also increase the number of NFSD
threads on your server.  I think eight is the default, and often that
isn't enough.

-- 
Chuck Lever
