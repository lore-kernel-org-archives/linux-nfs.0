From: Dave Chinner <david@fromorbit.com>
Subject: Re: high latency NFS
Date: Mon, 4 Aug 2008 10:38:54 +1000
Message-ID: <20080804003854.GC6119@disturbed>
References: <200807241311.31457.shuey@purdue.edu> <20080730192110.GA17061@fieldses.org> <4890DFC7.3020309@cse.unsw.edu.au> <200807302235.50068.shuey@purdue.edu> <20080731031512.GA26203@fieldses.org> <18577.25513.494821.481623@notabene.brown> <20080801072320.GE6201@disturbed> <20080801192343.GJ7764@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>,
	Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl2.internode.on.net ([203.16.214.57]:25726 "EHLO
	ipmail04.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752106AbYHDAjC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2008 20:39:02 -0400
In-Reply-To: <20080801192343.GJ7764@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 01, 2008 at 03:23:43PM -0400, J. Bruce Fields wrote:
> On Fri, Aug 01, 2008 at 05:23:20PM +1000, Dave Chinner wrote:
> > Having implemented the second option on a different NUMA aware
> > OS and NFS server, I can say that it isn't that complex, nor that
> > hard to screw up.
> > 
> > 	1. spawn a new thread only if all NFSDs are busy and there
> > 	   are still requests queued to be serviced.
> > 	2. rate limit the speed at which you spawn new NFSD threads.
> > 	   About 5/s per node was about right.
> > 	3. define an idle time for each thread before they
> > 	   terminate. That is, is a thread has not been asked to
> > 	   do any work for 30s, exit.
> > 	4. use the NFSD thread pools to allow per-pool independence.
> 
> Actually, I lost you on #4.  You mean that you apply 1-3 independently
> on each thread pool?  Or something else?

The former. i.e when you have a NUMA machine with a pool-per-node or
an SMP machine with a pool-per-cpu configuration, you can configure
the pools the differently according to the hardware config and
interrupt vectoring. This is especially useful if want to prevent
NFSDs from dominating the CPU taking disk interrupts or running user
code....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
