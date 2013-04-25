Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:34653 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759126Ab3DYSvg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2013 14:51:36 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH] NFSv4: Use exponential backoff delay for NFS4_ERRDELAY
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130425184626.GC5049@fieldses.org>
Date: Thu, 25 Apr 2013 14:51:20 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        David Wysochanski <dwysocha@redhat.com>,
        Dave Chiluk <chiluk@canonical.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Message-Id: <04318EF4-375D-49FD-8DB0-2BC6429543A9@oracle.com>
References: <1366838926.22397.25.camel@leira.trondhjem.org> <5178549A.7010402@canonical.com> <1366842905.22397.49.camel@leira.trondhjem.org> <1366892374.26249.294.camel@localhost.localdomain> <20130425132907.GB31851@fieldses.org> <1366896654.4719.18.camel@leira.trondhjem.org> <20130425134918.GC31851@fieldses.org> <1366899034.6812.4.camel@leira.trondhjem.org> <20130425181932.GA5049@fieldses.org> <81BBEA25-CDE5-42B1-996D-90C26A43DEF6@oracle.com> <20130425184626.GC5049@fieldses.org>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 25, 2013, at 2:46 PM, "bfields@fieldses.org" <bfields@fieldses.org> wrote:

> On Thu, Apr 25, 2013 at 02:40:11PM -0400, Chuck Lever wrote:
>> 
>> On Apr 25, 2013, at 2:19 PM, "bfields@fieldses.org" <bfields@fieldses.org> wrote:
>> 
>>> On Thu, Apr 25, 2013 at 02:10:36PM +0000, Myklebust, Trond wrote:
>>>> On Thu, 2013-04-25 at 09:49 -0400, bfields@fieldses.org wrote:
>>>>> On Thu, Apr 25, 2013 at 01:30:58PM +0000, Myklebust, Trond wrote:
>>>>>> On Thu, 2013-04-25 at 09:29 -0400, bfields@fieldses.org wrote:
>>>>>> 
>>>>>>> My position is that we simply have no idea what order of magnitude even
>>>>>>> delay should be.  And that in such a situation exponential backoff such
>>>>>>> as implemented in the synchronous case seems the reasonable default as
>>>>>>> it guarantees at worst doubling the delay while still bounding the
>>>>>>> long-term average frequency of retries.
>>>>>> 
>>>>>> So we start with a 15 second delay, and then go to 60 seconds?
>>>>> 
>>>>> I agree that a server should normally be doing the wait on its own if
>>>>> the wait would be on the order of an rpc round trip.
>>>>> 
>>>>> So I'd be inclined to start with a delay that was an order of magnitude
>>>>> or two more than a round trip.
>>>>> 
>>>>> And I'd expect NFS isn't common on networks with 1-second latencies.
>>>>> 
>>>>> So the 1/10 second we're using in the synchronous case sounds closer to
>>>>> the right ballpark to me.
>>>> 
>>>> OK, then. Now all I need is actual motivation for changing the existing
>>>> code other than handwaving arguments about "polling is better than flat
>>>> waits".
>>>> What actual use cases are impacting us now, other than the AIX design
>>>> decision to force CLOSE to retry at least once before succeeding?
>>> 
>>> Nah, I've got nothing, and I agree that the AIX problem is there bug.
>>> 
>>> Just for fun I looked at re-checked the Linux server cases.  As far as I
>>> can tell they are:
>>> 
>>> 	- delegations: returned immediately on detection of any
>>> 	  conflict.  The current behavior in the sync case looks
>>> 	  reasonable to me.
>>> 	- allocation failures: not really sure it's the best error, but
>>> 	  it seems to be all the protocol offers.  We probably don't
>>> 	  care much what the client does in this case.
>>> 	- some rare cases that would probably indicate bugs (e.g.,
>>> 	  attempting to destroy a client while other rpc's from that
>>> 	  client are running.)  Again we don't care what the client does
>>> 	  here.
>>> 	- the 4.1 slot-inuse case.
>>> 
>>> We also by default map four errors (ETIMEDOUT, EAGAIN, EWOULDBLOCK,
>>> ENOMEM) to delay.  I thought I remembered one of those being used by
>>> some HFS system, but can't actually find an example now.  A quick grep
>>> doesn't show anything interesting.
>> 
>> It's worth mentioning that servers that have frozen state (say, in preparation for Transparent State Migration) may use NFS4ERR_DELAY to prevent clients from modifying open or lock state until that state has transitioned to a destination server.
> 
> I thought they'd decided they'll be forced to find a different way to do
> that?
> 
> (The issue being that it only works if you're using 4.1, and if the
> session state itself isn't part of the state to be transferred.
> Otherwise you're forced to modify the state anyway since NFS4ERR_DELAY
> is seqid-modifying.)

The answer is not to return NFS4ERR_DELAY on seqid-modifying operations.

The source server can return NFS4ERR_DELAY to the client's migration recovery operations (the GETATTR(fs_locations) request) for example.

Or, the server could return it on the initial PUTFH operation in a compound containing seqid-modifying operations.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




