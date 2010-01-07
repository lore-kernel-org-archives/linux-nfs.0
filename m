From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: add testing infrastructure to nfs-utils
 (try #3)
Date: Thu, 7 Jan 2010 09:18:32 -0500
Message-ID: <20100107091832.687cb7eb@barsoom.rdu.redhat.com>
References: <1262706035-4929-1-git-send-email-jlayton@redhat.com>
	<20100106191706.GE6612@fieldses.org>
	<20100106144247.18dc10de@tlielax.poochiereds.net>
	<20100106195819.GH6612@fieldses.org>
	<77AF3FCC-A3BF-49C6-BF21-B1C38FD867AB@oracle.com>
	<20100106203312.GL6612@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Chuck Lever <chuck.lever@oracle.com>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893Ab0AGOSn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 09:18:43 -0500
In-Reply-To: <20100106203312.GL6612@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 6 Jan 2010 15:33:13 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jan 06, 2010 at 03:22:55PM -0500, Chuck Lever wrote:
> > My original idea was that this facility would be a set of smaller unit  
> > tests.  Since some of statd/sm-notify is now broken out into libraries, I 
> > think that makes it a little easier to craft targeted tests that don't 
> > require a full-blown statd running to carry out (Of course, that's 
> > speculation; I could be wrong, and Jeff has kindly set up the code for us 
> > to test this theory!).
> >
> > The old code has a statd simulator that doesn't require root, and uses  
> > its own RPC program number.  It might be reasonable to adopt that  
> > approach instead of using the real statd, for some test cases.
> 
> Like I say, it might be nice to be able to add even more intrusive tests
> (e.g. that modify the exports and then test the results over "lo" with
> the kernel client), so I'm actually happy Jeff says he's not bending
> over backwards to make the tests unprivileged.
> 

The root privs problem is definitely a valid concern.

After thinking about this problem I think the thing to do is
probably to create a "run as root" script that starts up statd (for
now) and other daemons (eventually). make check can then prompt the
user to inspect and run that script as root and then hit return when
it's ok to proceed.

That should allow someone to run most of the actual test code as an
unprivileged user. I'll plan to incorporate something like this in the
next respin.

> > Another way to set this up might be to use a container, or run it under a 
> > lightweight kvm.
> 
> Sounds ambitious for now.
> 

Agreed. That would be hard to implement across different distros (at
least until the virt stuff is more standardized).

-- 
Jeff Layton <jlayton@redhat.com>
