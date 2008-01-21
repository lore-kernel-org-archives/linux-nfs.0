From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: atimes not updated over NFS
Date: Mon, 21 Jan 2008 16:09:25 -0500
Message-ID: <20080121210925.GQ17468@fieldses.org>
References: <1199892437.11141.2.camel@heimdal.trondhjem.org> <20080109223748.GH9212@aym.net2.nerim.net> <1199920996.7638.3.camel@heimdal.trondhjem.org> <20080109235153.GI9212@aym.net2.nerim.net> <20080114083435.GA24215@janus> <1200325393.7470.6.camel@heimdal.trondhjem.org> <20080114175122.GB2768@janus> <20080121190638.GL17468@fieldses.org> <1200943865.25562.56.camel@heimdal.trondhjem.org> <20080121210230.GA22046@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52955 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490AbYAUVJb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2008 16:09:31 -0500
In-Reply-To: <20080121210230.GA22046@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 21, 2008 at 10:02:30PM +0100, Frank van Maarseveen wrote:
> On Mon, Jan 21, 2008 at 02:31:05PM -0500, Trond Myklebust wrote:
> > 
> > On Mon, 2008-01-21 at 14:06 -0500, J. Bruce Fields wrote:
> > > > > > Commands to reproduce this problem on the client:
> > > > > > 
> > > > > > 	dd </dev/zero >testfile count=1
> > > > > > 	ls -l --time=atime --full-time testfile
> > > > > > 	sleep 2
> > > > > > 	wc testfile
> > > > > > 	ls -l --time=atime --full-time testfile
> > > > > > 		(same atime, not good)
> > > > > 
> > > > > Can you confirm that it does not change on the server? If so, then we
> > > > > need to look at the server for a fix. The client should only be
> > > > > mirroring the server's idea of the correct atime.
> > > > 
> > > > It doesn't change on the server (2.6.23.12)
> > > 
> > > That still leaves open the question as to whether this is due to changes
> > > in the client that are causing it not to issue a read to the server when
> > > it would have before, or whether the server is just refusing to update
> > > the atime on read for some reason....
> > 
> > A script of the form
> 
> "rm -f testfile" and at least one "touch ." in advance to get deterministic behavior.
> 
> > 
> >                 ssh server 'dd </dev/zero >testfile count=1; ls -l --time=atime --full-time testfile'
> 
> put a sleep 2 here.
> 
> >                 
> >                 cat testfile >/dev/null
> 
> put a sleep 2 here just in case we would race with something in flight
> 
> >                 
> >                 ssh server 'ls -l --time=atime --full-time testfile'
> >                 ls -l --time=atime --full-time testfile
> > 
> 
> I tried some kernels (same on client and server). There are three atimes
> after each experiment.
> 
> 2.6.21.7:
> 	t
> 	t + 2
> 	t + 2
> 
> This seems to work but it doesn't: only the first "cat testfile" will
> update the atime. Subsequent cat commands will not update atime unless
> "cat" is executed on the server.

I think that's just the expected result of client caching, so all you
can do in that case is add "set check_mbox_size=yes" to your .muttrc or
something.....

> 
> 2.6.22.10:
> 	t
> 	t + 2
> 	t + 2
> 
> (same behavior)
> 
> 2.6.23.12:
> 	t
> 	t
> 	t
> 
> definately not good. "cat" on the server updates atime again.

Yes, that looks like a server bug, and this:...

> 
> 
> Trying a different combination of kernels:
> 
> server 2.6.23.12, client 2.6.22.10:
> 	t
> 	t
> 	t
> 
> server 2.6.22.10, client 2.6.23.12:
> 	t
> 	t + 2
> 	t + 2

...confirms that since the results appear to depend only on the server
version, not on the client version.

--b.

> 
> so, there are 2 phenomena and one has been introduced with 2.6.23 on
> the server side. Filesystem on the server is ext3.
> 
> -- 
> Frank
