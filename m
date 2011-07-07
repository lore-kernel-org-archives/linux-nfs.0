Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61771 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756267Ab1GGOQu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 10:16:50 -0400
Subject: Re: NFS/TCP timeout sequence
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Max Matveev <makc@redhat.com>, linux-nfs@vger.kernel.org
Date: Thu, 07 Jul 2011 10:16:53 -0400
In-Reply-To: <5F749FAD-94B0-4D9D-84F6-F7D9662A1CF6@oracle.com>
References: <19989.27202.793003.725608@regina.usersys.redhat.com>
	 <1310046439.3863.30.camel@lade.trondhjem.org>
	 <5F749FAD-94B0-4D9D-84F6-F7D9662A1CF6@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1310048213.3863.37.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-07-07 at 10:04 -0400, Chuck Lever wrote: 
> On Jul 7, 2011, at 9:47 AM, Trond Myklebust wrote:
> 
> > On Thu, 2011-07-07 at 18:11 +1000, Max Matveev wrote: 
> >> I've had to look at the way NFS/TCP does its timeouts and backoff
> >> and it does not make a lot of sense to me: according to the
> >> following paragram from nfs(5) on Fedora 14 (I'm using Fedora 14
> >> because it has more text then the same page in nfs-utils):
> >> 
> >>      timeo=n    The time (in tenths of a second) the  NFS  client  waits
> >>                 for a response before it retries an NFS request. If this
> >>                 option is not specified, requests are retried  every  60
> >>                 seconds  for NFS over TCP.  The NFS client does not per‐
> >>                 form any kind of timeout backoff for NFS over TCP.
> >> 
> >> but if I try the mount with timeo=20,retrans=7 then I'm getting
> >> retransmits which are 2, 4, 6, 8, 2, 4, 6, 8 seconds apart, i.e.
> >> there is a) linear backoff and b) the backoff is not long enough to
> >> let the complete sequence of 7 retransmits run its course.
> > 
> > Sigh... Firstly, 2 second timeouts are complete lunacy when using a
> > protocol that guarantees reliable delivery, such as TCP does. Anyone who
> > tries it deserves exactly what they get: poor unreliable performance.
> 
> We shouldn't allow such low settings.
> 
> > Secondly, the _other_ fix for this problem is to fix the documentation.
> 
> How is the documentation incorrect?  We do not want any kind of back-off for stream transports.

The documentation states that we don't do back off, but as Max points
out, in practice the kernel does a linear back off (and has always done
so).

Anyway, why shouldn't we back off if the server is failing to respond?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

