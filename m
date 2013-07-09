Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:48900 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820Ab3GIOV3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jul 2013 10:21:29 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH - RFC]  new "nosharetransport" option for NFS mounts.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130709132253.3dd4f90a@notabene.brown>
Date: Tue, 9 Jul 2013 10:21:20 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Message-Id: <1F5C5B8C-9D29-445D-A8E5-E1AB4E86339C@oracle.com>
References: <20130708095812.355d7cfc@notabene.brown> <1373309499.2231.46.camel@leira.trondhjem.org> <20130709132253.3dd4f90a@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 8, 2013, at 11:22 PM, NeilBrown <neilb@suse.de> wrote:

> On Mon, 8 Jul 2013 18:51:40 +0000 "Myklebust, Trond"
> <Trond.Myklebust@netapp.com> wrote:
> 
>> On Mon, 2013-07-08 at 09:58 +1000, NeilBrown wrote:
>>> 
>>> This patch adds a "nosharetransport" option to allow two different
>>> mounts from the same server to use different transports.
>>> If the mounts use NFSv4, or are of the same filesystem, then
>>> "nosharecache" must be used as well.
>> 
>> Won't this interfere with the recently added NFSv4 trunking detection?
> 
> Will it?  I googled around a bit but couldn't find anything that tells me
> what trunking really was in this context.  Then I found commit 05f4c350ee02 
> which makes it quite clear (thanks Chuck!).
> 
> Probably the code I wrote could interfere.
> 
>> 
>> Also, how will it work with NFSv4.1 sessions? The server will usually
>> require a BIND_CONN_TO_SESSION when new TCP connections attempt to
>> attach to an existing session.
> 
> Why would it attempt to attach to an existing session?  I would hope there
> the two different mounts with separate TCP connections would look completely
> separate - different transport, different cache, different session.
> ??
> 
>> 
>>> There are at least two circumstances where it might be desirable
>>> to use separate transports:
>>> 
>>> 1/ If the NFS server can get into a state where it will ignore
>>>  requests for one filesystem while servicing request for another,
>>>  then using separate connections for the separate filesystems can
>>>  stop problems with one affecting access to the other.
>>> 
>>>  This is particularly relevant for NetApp filers where one filesystem
>>>  has been "suspended".  Requests to that filesystem will be dropped
>>>  (rather than the more correct NFS3ERR_JUKEBOX).  This currently
>>>  interferes with other filesystems.
>> 
>> This is a known issue that really needs to be fixed on the server, not
>> on the client. As far as I know, work is already underway to fix this.
> 
> I wasn't aware of this, nor were our support people.  I've passed it on so
> maybe they can bug Netapp....
> 
>> 
>>> 2/ If a very fast network is used with a many-processor client, a
>>>  single TCP connection can present a bottle neck which reduces total
>>>  throughput.  Using multiple TCP connections (one per mount) removes
>>>  the bottleneck.
>>>  An alternate workaround is to configure multiple virtual IP
>>>  addresses on the server and mount each filesystem from a different
>>>  IP.  This is effective (throughput goes up) but an unnecessary
>>>  administrative burden.
>> 
>> As I understand it, using multiple simultaneous TCP connections between
>> the same endpoints also adds a risk that the congestion windows will
>> interfere. Do you have numbers to back up the claim of a performance
>> improvement?
> 
> A customer upgraded from SLES10 (2.6.16 based) to SLES11 (3.0 based) and saw
> a slowdown on some large DB jobs of between 1.5 and 2 times (i.e. total time
> 150% to 200% of what is was before).
> After some analysis they created multiple virtual IPs on the server and
> mounted the several filesystem each from different IPs and got the
> performance back (they see this as a work-around rather than a genuine
> solution).
> Numbers are like "500MB/s on a single connection, 850MB/sec peaking to
> 1000MB/sec on multiple connections".
> 
> If I can get something more concrete I'll let you know.
> 
> As this worked well in 2.6.16 (which doesn't try to share connections) this
> is seen as a regression.
> 
> On links that are easy to saturate, congestion windows are important and
> having a single connection is probably a good idea - so the current default
> is certainly correct.
> On a 10G ethernet or infiniband connection (where the issue has been
> measured) congestion just doesn't seem to be an issue.

We've toyed with the idea of using multiple TCP connections per mount for years.  The choice was made to stick with one connection (and one session on NFSv4.1) for each server.

The main limitation has been having a single RPC slot table for the transport, allowing only 16 concurrent RPC requests per server at a time.  Andy and Trond did some good work making the slot table widen itself dynamically as the TCP window opens.

A secondary concern is head-of-queue blocking.  The server end can certainly stall a client by not taking the top request off the socket queue, and thereby delay any requests that are behind that one in the queue.  I think the preferred solution there is to build out support for RPC over SCTP, and use SCTP's multi-stream feature.  Alternately we might choose to try out M-TCP. Server implementations can also be made sensitive to this issue to help prevent delays.

A tertiary issue is contention for the transport on multi-socket systems.  For a long while I've suspected it may occur, but I've never measured it in practice.

Re: the problem at hand: You've definitely measured a performance regression.  However, I don't think those numbers explain _why_ it is occurring.

The first thing to check is whether SuSE11 has the dynamic RPC slot table logic I mentioned above.  I think it starts with upstream commit d9ba131d, but someone should correct me if I'm wrong.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




