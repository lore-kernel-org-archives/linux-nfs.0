Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:47097 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758004Ab0HDCCY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 22:02:24 -0400
Subject: Re: numeric UIDs
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jim Rees <rees@umich.edu>, Daniel.Muntz@emc.com, linux-nfs@vger.kernel.org
In-Reply-To: <20100803224245.GB9752@fieldses.org>
References: <201008030401.33552.dreck@vmsd.ath.cx>
	 <20100803164318.GB13896@merit.edu> <20100803192216.GC31579@fieldses.org>
	 <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com>
	 <20100803215704.GA15494@merit.edu>
	 <1280873719.14520.17.camel@heimdal.trondhjem.org>
	 <20100803222337.GA9752@fieldses.org>
	 <1280874675.14520.23.camel@heimdal.trondhjem.org>
	 <20100803224245.GB9752@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 Aug 2010 22:02:16 -0400
Message-ID: <1280887336.24669.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-08-03 at 18:42 -0400, J. Bruce Fields wrote:
> On Tue, Aug 03, 2010 at 06:31:15PM -0400, Trond Myklebust wrote:
> > On Tue, 2010-08-03 at 18:23 -0400, J. Bruce Fields wrote:
> > > On Tue, Aug 03, 2010 at 06:15:19PM -0400, Trond Myklebust wrote:
> > > > On Tue, 2010-08-03 at 17:57 -0400, Jim Rees wrote:
> > > > > Daniel.Muntz@emc.com wrote:
> > > > > 
> > > > >   I'll fourth this motion.  The spec goes out of its way to declare this a
> > > > >   violation.  IMHO, the NFSv4.[0-n] specs should adopt the convention that a
> > > > >   uid string consisting of [0-9]+ be interpreted as the string
> > > > >   representation of a numeric UID--just as valid as a "user@domain" string.
> > > > > 
> > > > > I argued for this as an option in the early days but was shouted down.
> > > > > Sorry I can't remember the details, it was many years ago.
> > > > 
> > > > Why is nobody talking about fixing AUTH_SYS? The alternative to using
> > > > numeric uids/gids in NFS would be to use user@domain/group@domain in the
> > > > credential.
> > > 
> > > I'm not sure what that does to address complaints like original
> > > poster's:
> > > 
> > > 	http://marc.info/?l=linux-nfs&m=128080127215350&w=2
> > > 
> > > And I'd like it to be possible to make the NFSv3->NFSv4 upgrade as
> > > transparent as possible.
> > 
> > 1) RFC3530 does allow a workaround for cases where the _server_ doesn't
> > have a mapping from uid/gid -> name. We just haven't implemented it on
> > Linux servers (or clients).
> 
> Yeah, somebody should.
> 
> > 2) Why is AUTH_SYS so sacrosanct?
> 
> Because it's what almost everyone uses.

No. It's the _default_. ...and a really really bad default.

The sane thing to do is to change that default instead of trying to add
in yet another ptolemaic epicycle to "fix" just one of the many
problems...
For NFSv4, an auth system that is based on user/groupnames and domains
is a sane fix. It can be made to work with legacy NFSv2/v3 uids and gids
by setting up /etc/passwords, /etc/groups and/or ldap appropriately (as
should already be the case if you are using NFSv2/v3).

> > We know it has a bunch of problems,
> > not least the one that limits ngroups <= 16, and the fact that it relies
> > on uids (as opposed to login names) being the same on client and server
> > so why not try to fix those limitations?
> 
> Sure, that would be great.
> 
> Again, that doesn't address the complaints above.

Yes it does.

It is far better to return an error when the NFS server doesn't
recognize the user and group name rather than to try to use a uid and
gid that is only valid on the local client. Better still, the server
could allocate a new uid or gid (just like Samba does) when it
encounters an unknown user or group name, instead of returning the
error.

The server can still default to the workaround of using the ascii
uid/gid when it is trying to export a file for which it has no
user/group.

It boils down to the fact that we all log in to our clients with
_usernames_, not uids. Trying to make the uid the fundamental object is
the mistake that got us here in the first place.

Trond

