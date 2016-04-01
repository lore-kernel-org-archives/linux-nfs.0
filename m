Return-Path: <jlayton@poochiereds.net>
Date: Fri, 1 Apr 2016 12:09:13 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Anna Schumaker
 <anna.schumaker@netapp.com>,
        Linux NFS Mailing List
 <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Include OFD lock owners when looking up state
Message-ID: <20160401120913.658a77f2@synchrony.poochiereds.net>
In-Reply-To: <CAHQdGtQ34HGqNLEh=mPPVhuOc9akkd9F--EdsA=y07isbO=KNg@mail.gmail.com>
References: <cover.1459512819.git.bcodding@redhat.com>
	<CAHQdGtQ34HGqNLEh=mPPVhuOc9akkd9F--EdsA=y07isbO=KNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Apr 2016 11:47:10 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

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

Why wouldn't there be? OFD locks seem quite sane (more so than
traditional POSIX locks anyway), and the opaque v4 lockowner model
should work with OFD locks just fine...

-- 
Jeff Layton <jlayton@poochiereds.net>
