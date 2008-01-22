From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: atimes not updated over NFS
Date: Tue, 22 Jan 2008 12:17:17 -0500
Message-ID: <20080122171717.GD24697@fieldses.org>
References: <20080109223748.GH9212@aym.net2.nerim.net> <1199920996.7638.3.camel@heimdal.trondhjem.org> <20080109235153.GI9212@aym.net2.nerim.net> <20080114083435.GA24215@janus> <1200325393.7470.6.camel@heimdal.trondhjem.org> <20080114175122.GB2768@janus> <20080121190638.GL17468@fieldses.org> <1200943865.25562.56.camel@heimdal.trondhjem.org> <20080121210230.GA22046@janus> <20080121210925.GQ17468@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47912 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161AbYAVRR1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2008 12:17:27 -0500
In-Reply-To: <20080121210925.GQ17468@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 21, 2008 at 04:09:25PM -0500, bfields wrote:
> On Mon, Jan 21, 2008 at 10:02:30PM +0100, Frank van Maarseveen wrote:
> > "rm -f testfile" and at least one "touch ." in advance to get deterministic behavior.
> > 
> > > 
> > >                 ssh server 'dd </dev/zero >testfile count=1; ls -l --time=atime --full-time testfile'
> > 
> > put a sleep 2 here.
> > 
> > >                 
> > >                 cat testfile >/dev/null
> > 
> > put a sleep 2 here just in case we would race with something in flight
> > 
> > >                 
> > >                 ssh server 'ls -l --time=atime --full-time testfile'
> > >                 ls -l --time=atime --full-time testfile
> > > 
> > 
> > I tried some kernels (same on client and server). There are three atimes
> > after each experiment.
> > 
> > 2.6.21.7:
> > 	t
> > 	t + 2
> > 	t + 2
> > 
> > This seems to work but it doesn't: only the first "cat testfile" will
> > update the atime. Subsequent cat commands will not update atime unless
> > "cat" is executed on the server.
> 
> I think that's just the expected result of client caching, so all you
> can do in that case is add "set check_mbox_size=yes" to your .muttrc or
> something.....
> 
> > 
> > 2.6.22.10:
> > 	t
> > 	t + 2
> > 	t + 2
> > 
> > (same behavior)
> > 
> > 2.6.23.12:
> > 	t
> > 	t
> > 	t
> > 
> > definately not good. "cat" on the server updates atime again.
> 
> Yes, that looks like a server bug, and this:...
> 
> > 
> > 
> > Trying a different combination of kernels:
> > 
> > server 2.6.23.12, client 2.6.22.10:
> > 	t
> > 	t
> > 	t
> > 
> > server 2.6.22.10, client 2.6.23.12:
> > 	t
> > 	t + 2
> > 	t + 2
> 
> ...confirms that since the results appear to depend only on the server
> version, not on the client version.

And I can confirm this here on 2.6.24-rc8 (+ a few patches).
Unfortunately, I don't have any suggestion better right now than
bisecting....

--b.
