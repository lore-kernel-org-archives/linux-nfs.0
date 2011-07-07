Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:60397 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755764Ab1GGOpH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 10:45:07 -0400
Subject: Re: NFS/TCP timeout sequence
Content-Type: text/plain; charset=utf-8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1310048213.3863.37.camel@lade.trondhjem.org>
Date: Thu, 7 Jul 2011 10:44:54 -0400
Cc: Max Matveev <makc@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <7464E63E-E02E-4E4F-95A4-D4CF235DAFB3@oracle.com>
References: <19989.27202.793003.725608@regina.usersys.redhat.com> <1310046439.3863.30.camel@lade.trondhjem.org> <5F749FAD-94B0-4D9D-84F6-F7D9662A1CF6@oracle.com> <1310048213.3863.37.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jul 7, 2011, at 10:16 AM, Trond Myklebust wrote:

> On Thu, 2011-07-07 at 10:04 -0400, Chuck Lever wrote: 
>> On Jul 7, 2011, at 9:47 AM, Trond Myklebust wrote:
>> 
>>> On Thu, 2011-07-07 at 18:11 +1000, Max Matveev wrote: 
>>>> I've had to look at the way NFS/TCP does its timeouts and backoff
>>>> and it does not make a lot of sense to me: according to the
>>>> following paragram from nfs(5) on Fedora 14 (I'm using Fedora 14
>>>> because it has more text then the same page in nfs-utils):
>>>> 
>>>>     timeo=n    The time (in tenths of a second) the  NFS  client  waits
>>>>                for a response before it retries an NFS request. If this
>>>>                option is not specified, requests are retried  every  60
>>>>                seconds  for NFS over TCP.  The NFS client does not per‐
>>>>                form any kind of timeout backoff for NFS over TCP.
>>>> 
>>>> but if I try the mount with timeo=20,retrans=7 then I'm getting
>>>> retransmits which are 2, 4, 6, 8, 2, 4, 6, 8 seconds apart, i.e.
>>>> there is a) linear backoff and b) the backoff is not long enough to
>>>> let the complete sequence of 7 retransmits run its course.
>>> 
>>> Sigh... Firstly, 2 second timeouts are complete lunacy when using a
>>> protocol that guarantees reliable delivery, such as TCP does. Anyone who
>>> tries it deserves exactly what they get: poor unreliable performance.
>> 
>> We shouldn't allow such low settings.
>> 
>>> Secondly, the _other_ fix for this problem is to fix the documentation.
>> 
>> How is the documentation incorrect?  We do not want any kind of back-off for stream transports.
> 
> The documentation states that we don't do back off, but as Max points
> out, in practice the kernel does a linear back off (and has always done
> so).

I question that parenthetical assertion.  When I've looked at this behavior in the past, it has not backed off.  It has retried every 60 seconds.  That's why I wrote that in nfs(5).  I've had many discussions about this with you in the past.  We agreed: no back-off for TCP.  The default settings for TCP transports are timeo=600,retrans=2, which means try three times at fixed 60 second intervals.

So it seems to me the kernel has diverged (perhaps long ago) from the documentation, not the other way around.

> Anyway, why shouldn't we back off if the server is failing to respond?

Because the Solaris NFS client behaves this way, and we want to keep the syntax and semantics of our admin interfaces aligned between these implementations unless there is a good reason not to, because these mount options are published in automounter maps.

More importantly, a 60 second wait is not an onerous workload for either the network or the server.  Back-offs are usually used to provide quick recovery but then reduce network traffic if the server is down for a long while.  If we start at 60 seconds, there's already no onerous workload; plus we already have a slow recovery anyway...

In fact, for a long time we've wanted to make server restart recovery _faster_ not slower.  Thus using back-off with already lengthy retransmit timeouts seems like a step in the wrong direction.  After a server restart, our users want the client talking to the server again as quickly as possible.  At a guess, quicker recovery time after a server reboot is probably the number one reason why people try using a smaller timeo= setting for TCP.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



