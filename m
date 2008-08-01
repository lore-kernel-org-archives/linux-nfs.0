From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: high latency NFS
Date: Fri, 1 Aug 2008 15:15:59 -0400
Message-ID: <20080801191559.GI7764@fieldses.org>
References: <200807241311.31457.shuey@purdue.edu> <20080730192110.GA17061@fieldses.org> <4890DFC7.3020309@cse.unsw.edu.au> <200807302235.50068.shuey@purdue.edu> <20080731031512.GA26203@fieldses.org> <18577.25513.494821.481623@notabene.brown> <20080801072320.GE6201@disturbed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Neil Brown <neilb@suse.de>, Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>,
	Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, a
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37596 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533AbYHATQG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Aug 2008 15:16:06 -0400
In-Reply-To: <20080801072320.GE6201@disturbed>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 01, 2008 at 05:23:20PM +1000, Dave Chinner wrote:
> On Thu, Jul 31, 2008 at 05:03:05PM +1000, Neil Brown wrote:
> > You might want to track the max length of the request queue too and
> > start more threads if the queue is long, to allow a quick ramp-up.
> 
> Right, but even request queue depth is not a good indicator. You
> need to leep track of how many NFSDs are actually doing useful
> work. That is, if you've got an NFSD on the CPU that is hitting
> the cache and not blocking, you don't need more NFSDs to handle
> that load because they can't do any more work than the NFSD
> that is currently running is. 
> 
> i.e. take the solution that Greg banks used for the CPU scheduler
> overload issue (limiting the number of nfsds woken but not yet on
> the CPU),

I don't remember that, or wasn't watching when it happened.... Do you
have a pointer?

> and apply that criteria to spawning new threads.  i.e.
> we've tried to wake an NFSD, but there are none available so that
> means more NFSDs are needed for the given load. If we've already
> tried to wake one and it hasn't run yet, then we've got enough
> NFSDs....

OK, so you do that instead of trying to directly measure 

> Also, NFSD scheduling needs to be LIFO so that unused NFSDs
> accumulate idle time and so can be culled easily. If you RR the
> nfsds, they'll all appear to be doing useful work so it's hard to
> tell if you've got any idle at all.

Those all sound like good ideas, thanks.

(Still waiting for a volunteer for now, alas.)

--b.
