From: Neil Brown <neilb@suse.de>
Subject: Re: Invisible files and input/output errors
Date: Thu, 6 Dec 2007 10:31:17 +1100
Message-ID: <18263.13509.397157.489566@notabene.brown>
References: <200712040037.36598.bartoschek@or.uni-bonn.de>
	<18260.40472.276614.78174@notabene.brown>
	<200712041106.56189.bartoschek@or.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Christoph Bartoschek <bartoschek-eefaeeawk+jFLWzOrOlZPg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51645 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbXLEXbX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Dec 2007 18:31:23 -0500
In-Reply-To: message from Christoph Bartoschek on Tuesday December 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday December 4, bartoschek-eefaeeawk+jFLWzOrOlZPg@public.gmane.org wrote:
> 
> > Sounds a lot like directory cookie problems.
> >
> > Can you get a network trace of the NFS packets.
> > Something like
> >
> >     tcpdump -s 0 -w /tmp/trace host NAME-OF-SERVER
> >
> > then cause the failure while that is running.
> > Either compress and attach the result to an Email, or if it is too
> > big, stick it on a website somewhere.
> 
> I have attached a trace of a "ls" that does not show some directories.

There is one interesting feature of this trace.

The 'cookie' assigned to each directory entry normally is 32 more than
the previous entry, though in some places the gap is 64 or another
large multiple of 32.

The whole directory is fetched in three requests - each request
sending the cookie from the last name in the previous reply.

For the last request, the cookie for the first entry returned is 992
more than that last cookie in the previous reply.
This is by far that largest gap, and that fact that it aligns with a
break between two requests seems a little suspicious.

It might be interesting to remove some of the files that appear early
in the list, e.g.

 COUNT8SF manga.tcl test-run tanga.tcl flex sopec mopec thumper 

and see how that affects the returned list of files.

In any case, it looks from the trace that the Linux client so doing
the right thing based on the information returned, so I would
suggested reporting this to whoever provided your NFS-DFS gateway.

NeilBrown

