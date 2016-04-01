Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753110AbcDAPsp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Apr 2016 11:48:45 -0400
Date: Fri, 1 Apr 2016 11:48:42 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Include OFD lock owners when looking up state
In-Reply-To: <CAHQdGtQ34HGqNLEh=mPPVhuOc9akkd9F--EdsA=y07isbO=KNg@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1604011148030.18253@planck>
References: <cover.1459512819.git.bcodding@redhat.com> <CAHQdGtQ34HGqNLEh=mPPVhuOc9akkd9F--EdsA=y07isbO=KNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Apr 2016, Trond Myklebust wrote:

> On Fri, Apr 1, 2016 at 11:34 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> > The client sends IO only under the open stateid when using OFD (and flock)
> > locking instead of the appropriate lock stateid because the nfs_lock_context
> > only tracks POSIX lockowners, which is the reference to the process' file
> > table.
> >
> > This is a problem for two reasons.  The first is that rfc7530,
> > section-9.1.4.5 states that IO sent by an entity corresponding to the
> > lock-owner which holds a byte-range lock should be sent under the lock
> > stateid for that lock.  Otherwise, a server enforcing mandatory byte-range
> > locking might reject that operation.  Secondly, not tracking OFD lock owners
> > means that accounting for IO sent under those owners is broken.  That
> > creates a problem for some work to guarantee an unlock will be sent after
> > operations scheduled under a lock complete.
>
> OK. Can we just kill this in the bud? No support for OFD locks in NFS:
> this is nuts....

Will you explain why it is nuts?  That would be helpful for me.
