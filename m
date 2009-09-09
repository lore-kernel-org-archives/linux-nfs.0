From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
 part)
Date: Wed, 09 Sep 2009 14:39:59 -0400
Message-ID: <1252521599.8722.53.camel@heimdal.trondhjem.org>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
	 <20090805144540.12866.22084.stgit@matisse.1015granger.net>
	 <20090805174811.GB9944@fieldses.org>
	 <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com>
	 <20090805181545.GF9944@fieldses.org>
	 <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com>
	 <1249507356.5428.11.camel@heimdal.trondhjem.org>
	 <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com>
	 <1249515004.5428.34.camel@heimdal.trondhjem.org>
	 <20090909142945.755da393@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60829 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752163AbZIISkH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 14:40:07 -0400
In-Reply-To: <20090909142945.755da393-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-09-09 at 14:29 -0400, Jeff Layton wrote:
> On Wed, 05 Aug 2009 19:30:04 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > On Wed, 2009-08-05 at 18:24 -0400, Chuck Lever wrote:
> > > On Aug 5, 2009, at 5:22 PM, Trond Myklebust wrote:
> > > > On Wed, 2009-08-05 at 14:26 -0400, Chuck Lever wrote:
> > > >> sqlite3 doesn't do anything special under the covers.  It uses only
> > > >> POSIX file access and locking calls, as far as I know.  So I think
> > > >> hosting /var on most well-behaved clustering file systems won't have
> > > >> any problem with this arrangement.
> > > >
> > > > So we're basically introducing a dependency on a completely new  
> > > > library
> > > > that will have to be added to boot partitions/nfsroot/etc, and we have
> > > > no real reason for doing it other than because we want to move from
> > > > using sync() to fsync()?
> > > >
> > > > Sounds like a NACK to me...
> > > 
> > > Which library are you talking about, libsqlite3 or libtirpc?  Because  
> > > NEITHER of those is in /lib.
> > 
> > libsqlite is the problem. Unlike libtirpc, it's utility has yet to be
> > established.
> >
> 
> Sorry to revive this so late, but I think we need to come to some
> sort of resolution here. The only missing piece for client side IPv6
> support is statd...
> 
> I'm not sure I understand the objection to using libsqlite3 here. We
> certainly could roll our own routines to handle data storage, but why
> would we want to do so? sqlite3 is quite good at what it does. Why
> wouldn't we want to use it?

Backwards compatibility is one major reason. statd already exists, and
is in use out there. I shouldn't be forced to reboot all my clients when
I upgrade the nfs-utils package on my server.

Simplicity is another reason. WTF do we need a full SQL database, when
all we want to do is store 2 pieces of data (a hostname and a cookie)?
It isn't as if this has been a major problem for us previously.

> > > In any event, it's not just sync(2) that is a problem.  sync(2) by  
> > > itself is a boot performance problem, but it's the combination of  
> > > rename and sync that is known to be especially unreliable during  
> > > system crashes.  Statd, being a crash monitor, shouldn't depend on  
> > > rename/sync to maintain persistent data in the face of system  
> > > instability.  I'd call that a real reason to use something more robust.
> > 
> > What are you talking about? Is this about the truncate + rename issue
> > leaving empty files upon a crash?
> > That issue is solved trivially by doing an fsync() before you rename the
> > file. That entire discussion was about whether or not existing
> > applications should be _required_ to do this kind of POSIX pedantry,
> > when previously they could get away without it.
> > 
> > IOW: that issue alone does not justify replacing the current simple file
> > based scheme.
> >
> 
> There are other reasons, not to use the simple file-based scheme too...
> 
> Internationalized domain names will be easier to deal with via sqlite3,
> for instance.

Please explain...

> Certainly we could code this up ourselves, but what's the benefit to
> doing that when we have a perfectly good data storage engine available?

Why change something that works???? Rewriting from scratch is _NOT_ the
Linux way, and has usually bitten us hard when we've done it.

The 2.6.19 rewrite of the kernel mount code springs to mind...

Trond

