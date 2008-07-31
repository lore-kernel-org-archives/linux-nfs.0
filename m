From: Neil Brown <neilb@suse.de>
Subject: Re: high latency NFS
Date: Thu, 31 Jul 2008 17:03:05 +1000
Message-ID: <18577.25513.494821.481623@notabene.brown>
References: <200807241311.31457.shuey@purdue.edu>
	<20080730192110.GA17061@fieldses.org>
	<4890DFC7.3020309@cse.unsw.edu.au>
	<200807302235.50068.shuey@purdue.edu>
	<20080731031512.GA26203@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>,
	Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59816 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632AbYGaHDP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2008 03:03:15 -0400
In-Reply-To: message from J. Bruce Fields on Wednesday July 30
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday July 30, bfields@fieldses.org wrote:
> > 
> > I was only using the default 8 nfsd threads on the server.  When I raised 
> > this to 256, the read bandwidth went from about 6 MB/sec to about 95 
> > MB/sec, at 100ms of netem-induced latency.
> 
> So this is yet another reminder that someone needs to implement some
> kind of automatic tuning of the number of threads.
> 
> I guess the first question is what exactly the policy for that should
> be?  How do we decide when to add another thread?  How do we decide when
> there are too many?

Or should the first question be "what are we trying to achieve?"?

Do we want to:
    Automatically choose a number of threads that would match what a
      well informed sysadmin might choose
or
    regularly adjust the number of threads to find an optimal balance
      between prompt request processing (minimal queue length),
      minimal resource usage (idle threads waste memory)
    and not overloading the filesystem (how much concurrency does the
        filesystem/storage subsystem realistically support.

And then we need to think about how this relates to NUMA situations
where we have different numbers of threads on each node.


I think we really want to aim for the first of the above options, but
that the result will end up looking a bit like a very simplistic
attempt at the second.  "simplicitic" is key - we don't want
"complex".

I think that in the NUMA case we probably want to balance each node
independently.

The difficulties - I think - are:
  - make sure we can handle a sudden surge of requests, certainly a
    surge up to levels that we have previously seen.
    I think the means we either don't kill excess threads, or
    only kill them up to a limit: e.g. never fewer than 50% of
    the maximum number of threads
  - make sure we don't create too many threads if something clags up
    and nothing is getting through.  This means we need to monitor the
    number of requests dequeued and not make new threads when that is
    zero.
 

So how about:
  For each node we watch the length of the queue of
  requests-awaiting-threads and the queue of threads
  awaiting requests and maintain these values:
    - max number of threads ever concurrently running
    - number of requests dequeued
    - min length request queue
    - min length of thread queue

  Then every few (5?) seconds we sample these numbers and reset them
     (except the first).
     If 
        the min request queue length is non-zero and 
        the number of requests dequeued is non-zero
     Then
        start a new thread
     If
        the number of threads exceeds half the maximum and
        the min length of the thread queue exceeds 0
     Then
        stop one (idle) thread

You might want to track the max length of the request queue too and
start more threads if the queue is long, to allow a quick ramp-up.

We could try this allow by allowing you to write "auto" to the
'threads' file, so people can experiment.


NeilBrown
