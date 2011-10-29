Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:33767 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323Ab1J2SX2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 14:23:28 -0400
Subject: Re: NFS4ERR_STALE_CLIENTID loop
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7475@SACMVEXC2-PRD.hq.netapp.com>
Date: Sat, 29 Oct 2011 14:23:16 -0400
Cc: "David Flynn" <davidf@rd.bbc.co.uk>, <linux-nfs@vger.kernel.org>
Message-Id: <3B165534-0846-4290-AB12-91E06FD8ED11@oracle.com>
References: <20111024104042.GD32587@rd.bbc.co.uk> <1319455367.8505.3.camel@lade.trondhjem.org> <20111024131734.GE32587@rd.bbc.co.uk> <1319463165.2734.1.camel@lade.trondhjem.org> <20111024145027.GF32587@rd.bbc.co.uk> <1319470302.2734.4.camel@lade.trondhjem.org> <20111027221742.GI32587@rd.bbc.co.uk> <20111029002500.GA2011@rd.bbc.co.uk> <1319909376.2760.11.camel@lade.trondhjem.org> <20111029180227.GC2011@rd.bbc.co.uk> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7475@SACMVEXC2-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2011, at 2:22 PM, Myklebust, Trond wrote:

>> -----Original Message-----
>> From: David Flynn [mailto:davidf@rd.bbc.co.uk]
>> Sent: Saturday, October 29, 2011 8:02 PM
>> To: Myklebust, Trond
>> Cc: David Flynn; linux-nfs@vger.kernel.org; Chuck Lever
>> Subject: Re: NFS4ERR_STALE_CLIENTID loop
>> 
>> * Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
>>>> Using the same kernel, same mountpoint as before, we're currently
>>>> experiencing a loop involving NFS4ERR_STALE_CLIENTID.
>> ...
>>> The problem seems like a split-brain issue on the server... On the
> one
>>> hand, it is happily telling us that our lease is OK when we RENEW.
>>> Then when we try to use said lease in an OPEN, it is replying with
>>> STALE_CLIENTID.
>> 
>> Thank you for the quick update, especially at the weekend.  I'm
> wondering if
>> it is possible that the STALE_CLIENTID issue is a by-product of the
>> BAD_STATEID issue from earlier.  We have observed several times the
>> BAD_STATEID loop, but the CLIENTID problem only seemed to occur when
> all
>> 40+ nodes were all showing problems.
>> 
>> After killing off sufficient processes, the some of the machines then
>> recovered of their own accord.  So your conclusion that there is a
> server issue
>> sounds reasonable.
>> 
>> On any such possible backoff, the previous case was with quite small
>> requests in quite a tight loop that seemed to cause the server grief.
>> This morning, a machine with a 10GbE interface had a BAD_STATEID issue
> but
>> involving some much larger writes[1], resulting in 1.6Gbit/sec from
> that
>> machine alone.  Thankfully there was only a second machine with 1GbE
>> interfaces bringing the total up to 2.5Gbit/sec.
>> 
>> It is this ability for a group of clients to make matters worse that
> is just as bad
>> as any fault with Solaris.
> 
> Sure, but gone are the days when NFS had "reference implementations"
> that everyone had to interoperate with. NFSv4 is a fully documented
> protocol which describes how both clients and servers are supposed to
> work. If either the client or server fail to work according to that
> documentation, then bad things will happen.
> 
> While I could litter the client code with lots of little tricks to be
> "defensive" in the face of buggy servers, that isn't going to solve
> anything: the server will still be buggy, and the client will still be
> faced with a situation that it cannot resolve.
> 
>> (In a similar vein, it can be just as frustrating trying to get a
> client to stop
>> looping like this - it is often impossible to kill the process that
> triggered the
>> problem; for these, we had to resort to deleting the files using NFSv3
> (which
>> was working quite happily))
> 
> 'kill -9' should in principle work to kill off the process. Was that
> failing to work?

The trick is knowing which process to kill.  Generally you have to kill the state manager thread in this case.


-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




