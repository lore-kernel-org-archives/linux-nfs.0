From: Peter Staubach <staubach@redhat.com>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 15:55:53 -0400
Message-ID: <487D00C9.1010305@redhat.com>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>	 <487CC928.8070908@redhat.com>	 <76bd70e30807150923r31027edxb0394a220bbe879b@mail.gmail.com>	 <487CE202.2000809@redhat.com>	 <76bd70e30807151117g520f22cj1dfe26b971987d38@mail.gmail.com>	 <1216147879.7981.44.camel@localhost>  <487CF8D6.2090908@redhat.com> <1216150552.7981.48.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: chucklever@gmail.com, Andrew Bell <andrew.bell.ia@gmail.com>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315AbYGOT4F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 15:56:05 -0400
In-Reply-To: <1216150552.7981.48.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2008-07-15 at 15:21 -0400, Peter Staubach wrote:
>   
>> The connection manager would seem to be a RPC level thing, although
>> I haven't thought through the ramifications of the NFSv4.1 stuff
>> and how it might impact a connection manager sufficiently.
>>     
>
> We already have the scheme that shuts down connections on inactive RPC
> clients after a suitable timeout period, so the only gains I can see
> would have to involve shutting down connections on active clients.
>
> At that point, the danger isn't with NFSv4.1, it is rather with
> NFSv2/3/4.0... Specifically, their lack of good replay cache semantics
> mean that you have to be very careful about schemes that involve
> shutting down connections on active RPC clients.

It seems to me that as long as we don't shut down a connection
which is actively being used for an outstanding request, then
we shouldn't have any larger problems with the duplicate caches
on servers than we do now.

We can do this easily enough by reference counting the connection
state and then only closing connections which are not being
referenced.

I definitely agree, shutting down a connection which is being used
is just inviting trouble.

A gain would be that we could reduce the numbers of connections on
active clients if we could disassociate a connection with a
particular mounted file system.  As long as we can achieve maximum
network bandwidth through a single connection, then we don't need
more than one connection per server.

We could handle the case where the client was talking to more
servers than it had connection space for by forcibly, but safely
closing connections to servers and then using the space for a
new connection to a server.  We could do this in the connection
manager by checking to see if there was an available connection
which was not marked as in the process of being closed.  If so,
then it just enters the fray as needing a connection and am
working like all of the others.

The algorithm could look something like:

top:
    Look for a connection to the right server which is not marked
        as being closed.
    If one was found, then increment its reference count and
       return it.
    Attempt to create a new connect,
    If this works, then increment its reference count and
       return it.
    Find a connection to be closed, either one not being currently
       used or via some heuristic like round-robin.
    If this connection is not actively being used, then close it
       and go to top.
    Mark the connection as being closed, wait until it is closed,
       and then go to top.

I know that this is rough and there are several races that I
glossed over, but hopefully, this will outline the general bones
of a solution.

When the system is having recycle connections, it may slow down,
but at least it will work and not have things just fail.

    Thanx...

       ps
