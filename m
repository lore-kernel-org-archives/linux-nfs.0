Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:25447 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966244Ab2EOWh3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 18:37:29 -0400
Date: Tue, 15 May 2012 18:27:51 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: nfsv4 <nfsv4@ietf.org>, NFS list <linux-nfs@vger.kernel.org>
Message-ID: <777570427.442339.1337120871955.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <4FB2D447.50209@panasas.com>
Subject: Re: [nfsv4] commit thru DS at the bakeathon?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:
> On 05/16/2012 12:58 AM, Rick Macklem wrote:
> 
> > Hi,
> >
> > I was just wondering if anyone was going to have a pNFS server
> > at the June bakeathon that does Files layout and requires
> > "commit through the DS"?
> >
> 
> 
> I bet it could be simple to implement with the Linux local-exp
> pnfs server. (If not already supported)
> 
Right now, it does "commit through MDS", which is what I am testing.

I wasn't actually looking for a server that does "commit through DS"
as hoping no-one would have one at the bakeathon, so I didn't need to
worry about coding that in the next couple of weeks. (However, if someone
does have one, I might get that coded for testing;-)

> > It's one piece I haven't implemented yet and, although I do plan
> > on coding it, I was wondering if I should try and get it done in
> > the next couple of weeks?
> >
> > Just fyi, I'll have a FreeBSD NFSv4.0 server and a NFSv4.1 client
> > that
> >      includes pNFS using the files layout only there for testing.
> >      (excluding support for "commit through DS" maybe?)
> >
> 
> 
> Hey nice! a pnfs client for FBSD. Do you have a preliminary design
> for multiple layout-drivers like in Linux with a vector table?
> 
Not yet. I have tried to keep a fairly clean separation between the
generic layout stuff and the files layout specifics. I plan on starting
working on block layout stuff soon, in part to clean things up so that
other layouts can be added.

> Should I be looking into objects implementation?
> 
Well, it wouldn't be easy yet, but it would be great if you could do so
in a few months?

> > Looking forward to the bakeathon, rick
> 
> 
> Will not attend this time. Perhaps next time. Do you
> have a public git tree for review?
> 
Not git, but svn...
http://svnweb.freebsd.org/viewvc/base/projects/nfsv4.1-client
to look at it, or I think something like the following can be
used by an svn client to do a read-only checkout:
svn checkout http://svnweb.freebsd.org/base/projects/nfsv4.1-client

There is an entire FreeBSD kernel there, but the nfsv4 client
stuff is in sys/fs/nfsclient (with a little in sys/fs/nfs).

> Cheers
> Boaz
