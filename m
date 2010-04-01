From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: lockd and lock cancellation
Date: Thu, 1 Apr 2010 11:56:03 -0400
Message-ID: <20100401155603.GA19937@fieldses.org>
References: <1270124202.3354.40.camel@localhost> <4BB4945B.4040106@hp.com> <1270127630.3354.52.camel@localhost> <4BB4A884.4080901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Whitehouse <swhiteho@redhat.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"eshel@almaden.ibm.com" <eshel@almaden.ibm.com>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33501 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756658Ab0DAPxy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Apr 2010 11:53:54 -0400
In-Reply-To: <4BB4A884.4080901@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 01, 2010 at 03:07:00PM +0100, Rob Gardner wrote:
> If the lock were actually granted, then unlocking in lieu of a cancel  
> can potentially leave a range unlocked that should be left locked. This  
> can happen in the case of a lock upgrade or a coalesce operation; For  
> instance, suppose the client holds a lock on bytes 0-100, then issues  
> another lock request for bytes 50-150, but sends a cancel just after the  
> lock is actually granted. If you now simply unlock 50-150, then the  
> client is left holding only 0-50, and has "lost" the lock on bytes  
> 51-100. In other words, the client will *believe* that he has 0-100  
> locked, but in reality, only 0-50 are locked.
>
> As for what to do in this situation... well it would be nice if the  
> filesystem treated the cancel request as an "undo" if the grant won the  
> race. But seriously, I think this is just one of the (many) flaws in the  
> protocol and we probably have to live with it. My personal feeling is  
> that it's safer to leave bytes locked rather than have a client believe  
> it holds a lock when it doesn't.

I wrote some code to address this sort of problem a long time ago, and
didn't submit it:

	http://git.linux-nfs.org/?p=bfields/linux-topics.git;a=shortlog;h=refs/heads/fair-queueing

The idea was to support correct cancelling by introducing a new type of
lock.  Let's call it a "provisional lock".  It behaves in every way like
a posix lock, *except* that it doesn't combine with (or downgrade)
existing locks.  This allows a provisional lock to be cancelled--by just
removing it from the lock list--or to be "upgraded" to a normal posix
lock.  (Note if you're looking at the code above, "provisional locks"
are identified with the FL_BLOCK flag.)

We should probably look back at that idea at some point.

The original motivation was to implement "fair queuing" for NFSv4 locks.
(Since NFSv4 clients wait on blocking locks by polling the server, a
server is supposed to be willing to temporarily hold a lock on a polling
client's behalf.  But since posix locks aren't really guaranteed to be
granted to waiters in any particular order, I don't know how much that
matters.)

A side-effect was to eliminate a potential thundering-herd problem by
allowing the lock code to immediately grant a single process a
provisional lock, wake up just that process, and allow it to upgrade the
provisional lock to a normal posix lock, instead of waking up all the
waiters.  I was never able to figure out how to measure any benefit from
that, though!

You could push the same "provisional lock" idea down into GFS2, and I
suspect it would make it easier to avoid some races.  But I haven't
thoguht that through.

--b.
