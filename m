Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932175Ab2DQNbx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 09:31:53 -0400
Date: Tue, 17 Apr 2012 09:32:22 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach\@exagrid.com" <pstaubach@exagrid.com>,
        "viro\@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch\@infradead.org" <hch@infradead.org>,
        "michael.brantley\@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner\@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120417093222.2ff5e1bd@corrin.poochiereds.net>
In-Reply-To: <87sjg2o62z.fsf@tucsk.pomaz.szeredi.hu>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<4F8C3036.2030702@itwm.fraunhofer.de>
	<20120416134642.1754cd3e@corrin.poochiereds.net>
	<1334604785.2879.23.camel@lade.trondhjem.org>
	<20120416154322.0d95e435@corrin.poochiereds.net>
	<1334607906.2879.36.camel@lade.trondhjem.org>
	<20120416190548.2463d1d0@corrin.poochiereds.net>
	<87sjg2o62z.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 17 Apr 2012 15:12:20 +0200
Miklos Szeredi <miklos@szeredi.hu> wrote:

> Jeff Layton <jlayton@redhat.com> writes:
> 
> >> 
> >> Won't something like fstatat(AT_FDCWD, "", &stat, AT_EMPTY_PATH) risk
> >> looping forever there, or am I missing something?
> >> 
> >
> > To make sure I understand, that should be "shortcut" for a lookup of the
> > cwd?
> >
> > So I guess the concern is that you'd do the above and get a successful
> > lookup since you're just going to get back the cwd. At that point,
> > you'd attempt the getattr and get ESTALE back. Then, you'd redo the
> > lookup with LOOKUP_REVAL set -- but since we're operating on the
> > cwd, we don't have a way to redo the lookup since we don't have a
> > pathname that we can look up again...
> >
> > So yeah, I guess if you're sitting in a stale directory, something like
> > that could loop eternally.
> >
> > Do you think the proposed check for fatal_signal_pending is enough to
> > mitigate such a problem? Or do we need to limit the number of retries
> > to address those sorts of loops?
> 
> Lets step back a bit.
> 
> The retry is needed when when we discover during ->getattr() that the
> cached lookup returned a stale file handle.
> 
> If the lookup wasn't cached or if there was no lookup at all
> (stat(".") and friends) then retrying will not gain anything.
> 

That's not necessarily the case, at least not with NFS. It's easily
possible for you to do a full-fledged lookup over the wire, and then
for that inode to be removed prior to issuing a call against the FH that
you got back. 

> And that also means that retrying multiple times is pointless, since
> after the first retry we are sure to have up-to-date attributes.
> 

Again, it's not pointless. It's possible (though somewhat pathological)
for you to hit the race above more than once in the same operation.
Granted, it's an unlikely race but it is possible.

> Unfortunately it's impossible for the filesystem to know whether a
> ->getattr (or other inode operation) was perfromed after a cached or a
> non-cached lookup.
> 
> I'm not sure what the right interface for this would be.  One would be
> to just pass the "cached-or-not" information as a flag.  That works for
> getattr() but not for other operations.
> 
> Another is to introduce atomic lookup+foo variants of these operations
> just like for open.  E.g. the lookup+getattr is called if the cached
> lookup fails or if the cached lookup succeeds and the plain ->getattr
> call returns ESTALE.
>

To do that would require protocol support that we simply don't have. We
don't have a way to (for instance) say via NFS "give me the attributes
for this filename". Well, at least not for NFSv3...

With v4 you could theoretically construct a compound that does that,
but you'd have to assume that the server won't release the reference to
the inode midway through the compound. That's a reasonably safe
assumption.

While it's nice to consider new atomic ops like this, it's not really
possible with earlier versions of NFS.

-- 
Jeff Layton <jlayton@redhat.com>
