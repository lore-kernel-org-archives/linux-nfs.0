From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Date: Fri, 19 Aug 2011 18:43:11 -0700
Message-ID: <20110819184311.b094d6b7.rdunlap@xenotime.net>
References: <20101018223540.GA20730@gradator.net>
	<20110819230344.GA24784@gradator.net>
	<20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
	<20110820012943.GD2203@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jamie Lokier <jamie@shareable.org>,
	Sylvain Rochet <gradator@gradator.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110820012943.GD2203@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 20 Aug 2011 02:29:43 +0100 Al Viro wrote:

> On Sat, Aug 20, 2011 at 12:37:56AM +0100, Jamie Lokier wrote:
> 
> > Possible solution:
> 
> > Then this can be solved, in principle (if there's no better way), by
> > watching a "virtual directory" that gets all events for when the
> > access doesn't have a parent directory.  There needs to be some way to
> > watch it, and some way to get the appropriate file from the event (as
> > there is no real directory.  Or maybe there could be a virtual
> > filesystem (like /proc, /sys etc.) containing a magic directory that
> > receives these inode-only events, such that lookups in that directory
> > yield the affected file.  Exactly as if the directory contains a hard
> > link to every file, perhaps a text encoding of the handles passed
> > through sys_open_by_handle_at.
> 
> There is a better way - stop using idiotify...  It has always been a
> mistake, driven down our throats by filemangler and desktop crowd.
> Broken in many, _many_ respects...  Deprecate that crap, remove it
> completely in a couple of revisions, let these clowns cope.  Yeah,
> yeah, I know...  Not going to happen ;-/  One can dream, though...

What do you suggest as a functioning alternative to inotify?

---
~Randy
