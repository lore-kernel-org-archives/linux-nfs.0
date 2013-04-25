Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52548 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932257Ab3DYNtY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Apr 2013 09:49:24 -0400
Date: Thu, 25 Apr 2013 09:49:18 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: David Wysochanski <dwysocha@redhat.com>,
        Dave Chiluk <chiluk@canonical.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Use exponential backoff delay for NFS4_ERRDELAY
Message-ID: <20130425134918.GC31851@fieldses.org>
References: <1366836949-18465-1-git-send-email-chiluk@canonical.com>
 <1366838926.22397.25.camel@leira.trondhjem.org>
 <5178549A.7010402@canonical.com>
 <1366842905.22397.49.camel@leira.trondhjem.org>
 <1366892374.26249.294.camel@localhost.localdomain>
 <20130425132907.GB31851@fieldses.org>
 <1366896654.4719.18.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1366896654.4719.18.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 25, 2013 at 01:30:58PM +0000, Myklebust, Trond wrote:
> On Thu, 2013-04-25 at 09:29 -0400, bfields@fieldses.org wrote:
> 
> > My position is that we simply have no idea what order of magnitude even
> > delay should be.  And that in such a situation exponential backoff such
> > as implemented in the synchronous case seems the reasonable default as
> > it guarantees at worst doubling the delay while still bounding the
> > long-term average frequency of retries.
> 
> So we start with a 15 second delay, and then go to 60 seconds?

I agree that a server should normally be doing the wait on its own if
the wait would be on the order of an rpc round trip.

So I'd be inclined to start with a delay that was an order of magnitude
or two more than a round trip.

And I'd expect NFS isn't common on networks with 1-second latencies.

So the 1/10 second we're using in the synchronous case sounds closer to
the right ballpark to me.

--b.
