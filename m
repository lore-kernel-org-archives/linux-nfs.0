Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752931AbZIITOE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 15:14:04 -0400
Date: Wed, 9 Sep 2009 15:13:54 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
 part)
Message-ID: <20090909151354.504ccdf6@tlielax.poochiereds.net>
In-Reply-To: <1252521599.8722.53.camel@heimdal.trondhjem.org>
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
	<1252521599.8722.53.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 09 Sep 2009 14:39:59 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Wed, 2009-09-09 at 14:29 -0400, Jeff Layton wrote:
> > On Wed, 05 Aug 2009 19:30:04 -0400
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > 
> > > On Wed, 2009-08-05 at 18:24 -0400, Chuck Lever wrote:
> > > > On Aug 5, 2009, at 5:22 PM, Trond Myklebust wrote:
> > > > > On Wed, 2009-08-05 at 14:26 -0400, Chuck Lever wrote:
> > > > >> sqlite3 doesn't do anything special under the covers.  It uses only
> > > > >> POSIX file access and locking calls, as far as I know.  So I think
> > > > >> hosting /var on most well-behaved clustering file systems won't have
> > > > >> any problem with this arrangement.
> > > > >
> > > > > So we're basically introducing a dependency on a completely new  
> > > > > library
> > > > > that will have to be added to boot partitions/nfsroot/etc, and we have
> > > > > no real reason for doing it other than because we want to move from
> > > > > using sync() to fsync()?
> > > > >
> > > > > Sounds like a NACK to me...
> > > > 
> > > > Which library are you talking about, libsqlite3 or libtirpc?  Because  
> > > > NEITHER of those is in /lib.
> > > 
> > > libsqlite is the problem. Unlike libtirpc, it's utility has yet to be
> > > established.
> > >
> > 
> > Sorry to revive this so late, but I think we need to come to some
> > sort of resolution here. The only missing piece for client side IPv6
> > support is statd...
> > 
> > I'm not sure I understand the objection to using libsqlite3 here. We
> > certainly could roll our own routines to handle data storage, but why
> > would we want to do so? sqlite3 is quite good at what it does. Why
> > wouldn't we want to use it?
> 
> Backwards compatibility is one major reason. statd already exists, and
> is in use out there. I shouldn't be forced to reboot all my clients when
> I upgrade the nfs-utils package on my server.
> 

We could roll a conversion utility for this if it would help. nfs-utils
upgrades usually mean restarting statd anyway:

shut down old-statd
convert flat file db to sqlite
start up new-statd

...so I don't think we necessarily need to reboot the clients for this.
It should (in theory) be possible to do the reverse even.

> Simplicity is another reason. WTF do we need a full SQL database, when
> all we want to do is store 2 pieces of data (a hostname and a cookie)?
> It isn't as if this has been a major problem for us previously.
> 

Been a little while since I took my initial look at new-statd, but I
see that Chuck is has this (just a for-instance):

        rc = sqlite3_prepare_v2(db, "CREATE TABLE " STATD_MONITOR_TABLENAME
                                        " (priv BLOB,"
                                        " mon_name TEXT NOT NULL,"
                                        " my_name TEXT NOT NULL,"
                                        " program INTEGER,"
                                        " version INTEGER,"
                                        " procedure INTEGER,"
                                        " protocol TEXT NOT NULL,"
                                        " state INTEGER,"
                                        " UNIQUE(mon_name,my_name));",
                                                -1, &stmt, NULL);


He's tracking some other info there too. Is this all necessary? Maybe
not now, but having a storage engine that can cope with tracking extra
info will make it easier to handle things like multihomed clients and
servers correctly (something that the existing statd is not very good
at at the moment).

> > > > In any event, it's not just sync(2) that is a problem.  sync(2) by  
> > > > itself is a boot performance problem, but it's the combination of  
> > > > rename and sync that is known to be especially unreliable during  
> > > > system crashes.  Statd, being a crash monitor, shouldn't depend on  
> > > > rename/sync to maintain persistent data in the face of system  
> > > > instability.  I'd call that a real reason to use something more robust.
> > > 
> > > What are you talking about? Is this about the truncate + rename issue
> > > leaving empty files upon a crash?
> > > That issue is solved trivially by doing an fsync() before you rename the
> > > file. That entire discussion was about whether or not existing
> > > applications should be _required_ to do this kind of POSIX pedantry,
> > > when previously they could get away without it.
> > > 
> > > IOW: that issue alone does not justify replacing the current simple file
> > > based scheme.
> > >
> > 
> > There are other reasons, not to use the simple file-based scheme too...
> > 
> > Internationalized domain names will be easier to deal with via sqlite3,
> > for instance.
> 
> Please explain...
> 

Well, we currently store statd info in flat files named with the
hostname. With an internationalized domain name, we may have a
multibyte character in that name. We could try to store that as an
ASCII or UTF8 name, but we'd have to roll conversion routines for it.
Why bother when we have a storage engine that does that work for us?

> > Certainly we could code this up ourselves, but what's the benefit to
> > doing that when we have a perfectly good data storage engine available?
> 
> Why change something that works???? Rewriting from scratch is _NOT_ the
> Linux way, and has usually bitten us hard when we've done it.
> 
> The 2.6.19 rewrite of the kernel mount code springs to mind...
> 

A good point. Given who I work for, I *really* hate regressions since
they tend to mean a lot of my time tends to get eaten up.

At some point however it becomes very difficult to patch up old code.
old-statd in particular hasn't seen the attention that it probably
should have.

I trust that Chuck will be willing to fix problems that come along. The
new code seems to be on par with the old in complexity so I don't think
we'd be taking on a great maintenance burden with it even if Chuck
isn't available.

Could we add IPv6 support as a patchset to the existing statd instead?
Sure. That patch would be smaller than Chuck's rewrite, but I still
think there are advantages to considering a major overhaul here.

-- 
Jeff Layton <jlayton@redhat.com>
