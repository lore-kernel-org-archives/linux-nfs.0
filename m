From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Mon, 30 Jun 2008 11:35:41 -0400
Message-ID: <20080630153541.GD29011@fieldses.org>
References: <48652C24.6030409@gmail.com> <OF20F6A497.A6F52D0F-ON65257478.00377AB6-65257478.0037E4AE@in.ibm.com> <20080630112654.012ce3e4@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Dean Hildebrand <seattleplus@gmail.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, Peter Staubach <staubach@redhat.com>,
	aglo@citi.umich.edu
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53630 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758626AbYF3Pgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jun 2008 11:36:53 -0400
In-Reply-To: <20080630112654.012ce3e4-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 11:26:54AM -0400, Jeff Layton wrote:
> Recently I spent some time with others here at Red Hat looking
> at problems with nfs server performance. One thing we found was that
> there are some problems with multiple nfsd's. It seems like the I/O
> scheduling or something is fooled by the fact that sequential write
> calls are often handled by different nfsd's. This can negatively
> impact performance (I don't think we've tracked this down completely
> yet, however).

Yes, we've been trying to see how close to full network speed we can get
over a 10 gig network and have run into situations where increasing the
number of threads (without changing anything else) seems to decrease
performance of a simple sequential write.

And the hypothesis that the problem was randomized IO scheduling was the
first thing that came to mind.  But I'm not sure what the easiest way
would be to really prove that that was the problem.

And then once we really are sure that's the problem, I'm not sure what
to do about it.  I suppose it may depend partly on exactly where the
reordering is happening.

--b.

> 
> Since you're just doing some single-threaded testing on the client
> side, it might be interesting to try running a single nfsd and testing
> performance with that. It might provide an interesting data point.
> 
> Some other thoughts of things to try:
> 
> 1) run the tests against an exported tmpfs filesystem to eliminate
> underlying disk performance as a factor.
> 
> 2) test nfsv4 -- nfsd opens and closes the file for each read/write.
> nfsv4 is statelful, however, so I don't believe it does that there.
> 
> As others have pointed out though, testing with client and server on
> the same machine is not necessarily eliminating performance
> bottlenecks. You may want to test with dedicated clients and servers
> (maybe on a nice fast network or with a gigE crossover cable or
> something).
