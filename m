From: Peter Staubach <staubach@redhat.com>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 13:44:34 -0400
Message-ID: <487CE202.2000809@redhat.com>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>	 <487CC928.8070908@redhat.com> <76bd70e30807150923r31027edxb0394a220bbe879b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Andrew Bell <andrew.bell.ia@gmail.com>, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43829 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755526AbYGORog (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 13:44:36 -0400
In-Reply-To: <76bd70e30807150923r31027edxb0394a220bbe879b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Tue, Jul 15, 2008 at 11:58 AM, Peter Staubach <staubach@redhat.com> wrote:
>   
>> If it is the notion described above, sometimes called head
>> of line blocking, then we could think about ways to duplex
>> operations over multiple TCP connections, perhaps with one
>> connection for small, low latency operations, and another
>> connection for larger, higher latency operations.
>>     
>
> I've dreamed about that for years.  I don't think it would be too
> difficult, but one thing that has held it back is the shortage of
> ephemeral ports on the client may reduce the number of concurrent
> mount points we can support.
>
> One way to avoid the port issue is to construct an SCTP transport for
> NFS.  SCTP allows multiple streams on the same connection, effectively
> eliminating head of line blocking.

I like the idea of combining this work with implementing a proper
connection manager so that we don't need a connection per mount.
We really only need one connection per client and server, no matter
how many individual mounts there might be from that single server.
(Or two connections, if we want to do something like this...)

We could also manage the connection space and thus, never run into
the shortage of ports ever again.  When the port space is full or
we've run into some other artificial limit, then we simply close
down some other connection to make space.

       ps
