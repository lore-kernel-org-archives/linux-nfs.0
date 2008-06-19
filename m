From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: CONFIG_DEBUG_SLAB_LEAK omits size-4096 and larger?
Date: Thu, 19 Jun 2008 14:46:26 -0400
Message-ID: <20080619184626.GH18557@fieldses.org>
References: <20080611205749.GA25194@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DAA@hoexmb9.conoco.net> <20080611225431.GD25194@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DAE@hoexmb9.conoco.net> <20080613201552.GH8501@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DB6@hoexmb9.conoco.net> <20080613220422.GC14338@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DB7@hoexmb9.conoco.net> <20080616174340.GA27083@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DD4@hoexmb9.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@poochiereds.net>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Neil Brown <neilb@suse.de>
To: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57739 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753034AbYFSSqa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2008 14:46:30 -0400
In-Reply-To: <0122F800A3B64C449565A9E8C297701002D75DD4-zIGg2qceuZx7uNL6xugVa6xOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 19, 2008 at 10:53:28AM -0500, Weathers, Norman R. wrote:
> The kernel that we were really seeing the problem with was 2.6.25.4, but
> I think we may have figured out the 4096 problem, and it was probably a
> mistake on my part, but it is important for the NFS users to see it so
> they don't make the same mistake.  I had found some performance tuning
> guides, and in trying some of the suggestions, found that the setting
> changes did seem to help on some things, but of course I never got to
> run a check under full load (800 + clients).  A suggestion was to change
> the tcp_reordering tunable under /proc/sys/net/ipv4 from the default 3
> to 127.  We think that this was actually causing the issue.  I was able
> to trace back through all of the changes, and I changed this setting
> back to the default 3, and it immediately fixed the size-4096 hell.  It
> appears that the reordering just eats into the memory, especially in
> high demand situations, and I guess that should make perfect sense if we
> are actually buffering up packets for reorder, and we are slamming the
> box with thousands of requests per minute.

OK, sounds plausible, though I won't pretend to understand exactly how
that reordering code is using memory.

> We still have other performance issues now, but it appears to be more of
> a bottleneck, the nodes do not appear to be backing off when the servers
> are becoming congested.
...
> > So with that many clients all making requests to the server at once,
> > we'd start hitting that (serv->sv_nrthreads+3)*20 limit when 
> > the number
> > of threads was set to less than 30-50.  That doesn't seem to be the
> > point where you're seeing a change in behavior, though.
> > 
> 
> We were estimating between 40 and 50 threads was the cut off for being
> able to service all of the (current) requests at once.  I haven't ramped
> back up to that level yet.  I wasn't comfortable yet with letting it all
> hang back out just in case we get into that hellish mode again, it can
> be a pain to try and get into those systems once they are overloaded
> (even over serial, sometimes it can just timeout the login).  We had to
> actually bring online a second option to help alleviate some of the back
> congestion because the servers couldn't handle the workload.  

Thanks for the update, and let us know if you figure out anything more.

--b.
