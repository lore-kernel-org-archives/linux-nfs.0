Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56613 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbcDAQfZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Apr 2016 12:35:25 -0400
Date: Fri, 1 Apr 2016 12:35:22 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Include OFD lock owners when looking up state
In-Reply-To: <CAHQdGtQKqs--JP6-OT6jjNh6JXTG6+cebL64t8OW8q771UL8FQ@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1604011212040.18253@planck>
References: <cover.1459512819.git.bcodding@redhat.com> <CAHQdGtQ34HGqNLEh=mPPVhuOc9akkd9F--EdsA=y07isbO=KNg@mail.gmail.com> <alpine.OSX.2.19.9992.1604011148030.18253@planck> <CAHQdGtQKqs--JP6-OT6jjNh6JXTG6+cebL64t8OW8q771UL8FQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Apr 2016, Trond Myklebust wrote:

> On Fri, Apr 1, 2016 at 11:48 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> > On Fri, 1 Apr 2016, Trond Myklebust wrote:
> >
> >> On Fri, Apr 1, 2016 at 11:34 AM, Benjamin Coddington
> >> <bcodding@redhat.com> wrote:
> >> > The client sends IO only under the open stateid when using OFD (and flock)
> >> > locking instead of the appropriate lock stateid because the nfs_lock_context
> >> > only tracks POSIX lockowners, which is the reference to the process' file
> >> > table.
> >> >
> >> > This is a problem for two reasons.  The first is that rfc7530,
> >> > section-9.1.4.5 states that IO sent by an entity corresponding to the
> >> > lock-owner which holds a byte-range lock should be sent under the lock
> >> > stateid for that lock.  Otherwise, a server enforcing mandatory byte-range
> >> > locking might reject that operation.  Secondly, not tracking OFD lock owners
> >> > means that accounting for IO sent under those owners is broken.  That
> >> > creates a problem for some work to guarantee an unlock will be sent after
> >> > operations scheduled under a lock complete.
> >>
> >> OK. Can we just kill this in the bud? No support for OFD locks in NFS:
> >> this is nuts....
> >
> > Will you explain why it is nuts?  That would be helpful for me.
>
> The point of the OFD crap was that they should work exactly like POSIX
> locks except for the unlock-on-close, the latter being managed by the
> VFS layer. If we have to make loads of changes to NFS in order to
> change the tracking of lock owners, then the design itself is broken,
> and needs to be fixed.

It seems your objection is more about trying to combine the two different
models of a lock's ownership or boundaries from the VFS side, where in NFS
there's been traditionally only one model used.

The reason that OFD locks require changes to work on NFS is because the
owners (the context of a lock) are different, and NFS right now assumes that
the boundaries of lock ownership are always going to be a shared file table.

Assuming that the boundaries of a lock will only ever be entities with shared
file tables might be difficult to support long term.  What happens when
applications start using OFD locks (or other future locks that might allow
user-defined locking contexts) and then later we discover applications won't
work properly on NFS?

How can we fix this once for NFS?  NFS could be fixed if it didn't have to
keep track of the lock context, if the lock context were opaque.  Should
there be a way to look up a reference to a locking context without having to
keep track of files or file tables or anything else?

Ben
