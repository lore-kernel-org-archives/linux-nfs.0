Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:41930 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756264Ab3DYOvz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2013 10:51:55 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH] NFSv4: Use exponential backoff delay for NFS4_ERRDELAY
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130425134918.GC31851@fieldses.org>
Date: Thu, 25 Apr 2013 10:51:42 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        David Wysochanski <dwysocha@redhat.com>,
        Dave Chiluk <chiluk@canonical.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Message-Id: <C56C9BFD-0B20-4F2B-B282-84566ACBF41B@oracle.com>
References: <1366836949-18465-1-git-send-email-chiluk@canonical.com> <1366838926.22397.25.camel@leira.trondhjem.org> <5178549A.7010402@canonical.com> <1366842905.22397.49.camel@leira.trondhjem.org> <1366892374.26249.294.camel@localhost.localdomain> <20130425132907.GB31851@fieldses.org> <1366896654.4719.18.camel@leira.trondhjem.org> <20130425134918.GC31851@fieldses.org>
To: bfields@fieldses.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 25, 2013, at 9:49 AM, bfields@fieldses.org wrote:

> On Thu, Apr 25, 2013 at 01:30:58PM +0000, Myklebust, Trond wrote:
>> On Thu, 2013-04-25 at 09:29 -0400, bfields@fieldses.org wrote:
>> 
>>> My position is that we simply have no idea what order of magnitude even
>>> delay should be.  And that in such a situation exponential backoff such
>>> as implemented in the synchronous case seems the reasonable default as
>>> it guarantees at worst doubling the delay while still bounding the
>>> long-term average frequency of retries.
>> 
>> So we start with a 15 second delay, and then go to 60 seconds?
> 
> I agree that a server should normally be doing the wait on its own if
> the wait would be on the order of an rpc round trip.
> 
> So I'd be inclined to start with a delay that was an order of magnitude
> or two more than a round trip.
> 
> And I'd expect NFS isn't common on networks with 1-second latencies.
> 
> So the 1/10 second we're using in the synchronous case sounds closer to
> the right ballpark to me.

The RPC layer already keeps RPC round trip statistics, so the client doesn't have to guess with a "one size fits all" number.

I'm all for keeping client recovery time short.  But after following this argument, I think 10xRTT is crazy short.  Aggressive retransmits can lead to data corruption, and RTT on a fast server is going to be on the order of a millisecond.  And what about RDMA, where RTT is about 20usecs? 

A better answer might be to start at one second then exponentially back off to the minimum of 0.25x the lease time and 0.25x the RPC retransmit time out.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




