From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: add testing infrastructure to nfs-utils
 (try #3)
Date: Fri, 8 Jan 2010 09:51:46 -0500
Message-ID: <20100108095146.2060832b@tlielax.poochiereds.net>
References: <1262706035-4929-1-git-send-email-jlayton@redhat.com>
	<20100106191706.GE6612@fieldses.org>
	<20100106144247.18dc10de@tlielax.poochiereds.net>
	<20100106195819.GH6612@fieldses.org>
	<77AF3FCC-A3BF-49C6-BF21-B1C38FD867AB@oracle.com>
	<20100106203312.GL6612@fieldses.org>
	<20100107091832.687cb7eb@barsoom.rdu.redhat.com>
	<20100108050556.GB4984@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Chuck Lever <chuck.lever@oracle.com>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18703 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab0AHOvv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jan 2010 09:51:51 -0500
In-Reply-To: <20100108050556.GB4984@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 8 Jan 2010 00:05:56 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> > 
> > The root privs problem is definitely a valid concern.
> > 
> > After thinking about this problem I think the thing to do is
> > probably to create a "run as root" script that starts up statd (for
> > now) and other daemons (eventually). make check can then prompt the
> > user to inspect and run that script as root and then hit return when
> > it's ok to proceed.
> > 
> > That should allow someone to run most of the actual test code as an
> > unprivileged user. I'll plan to incorporate something like this in the
> > next respin.
> 
> That sounds complicated.  And, as I said above, we might some day like
> to include tests where the privileged stuff makes up the body of the
> test.
> 
> Why not just "the tests you are about to run need root privileges, and
> will start and stop statd; continue (y/n)?"
> 

It turns out that this is a little tricky to do within "make check".
The tests are all run as individual scripts, so it's not
straightforward to have one do this check and force all of the others
to exit.

It also seems like a useless question. If we have root privileges,
there's no point in asking. If we don't have them, we just have to exit
anyway. I don't see any point in prompting...

What I can do fairly easily is add a check to the individual test that
makes sure the euid is 0, and then exits with a "skip this test" error
code if it's not. After some consideration, I like that better anyway
since it will make it possible to run a subset of the tests as an
unprivileged user.

I'll post a new set with this change in a bit...

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
