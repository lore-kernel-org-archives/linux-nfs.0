Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55343 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751262Ab3JASmQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 14:42:16 -0400
Date: Tue, 1 Oct 2013 14:42:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Ric Wheeler <rwheeler@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Zach Brown <zab@redhat.com>, Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20131001184210.GM26382@fieldses.org>
References: <52474839.2080201@redhat.com>
 <CAJfpegsN7Hu8uecSVQrhax+n+zhq=uUgpzOk=qZ6_n383tdNCQ@mail.gmail.com>
 <20130930143432.GG16579@fieldses.org>
 <CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com>
 <52499026.3090802@redhat.com>
 <CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com>
 <52498AA8.2090204@redhat.com>
 <CAJfpegv_C6cLOuA-mNtgtf2QbmmmcHwjQVo8mAnhf_wbJ8iRhg@mail.gmail.com>
 <52498DB6.7060901@redhat.com>
 <CAJfpegsvrr7x3MbdpvxUmzq0ZfDHfZkzAar6Od2G7wg8DgPLYQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegsvrr7x3MbdpvxUmzq0ZfDHfZkzAar6Od2G7wg8DgPLYQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 30, 2013 at 05:46:38PM +0200, Miklos Szeredi wrote:
> On Mon, Sep 30, 2013 at 4:41 PM, Ric Wheeler <rwheeler@redhat.com> wrote:
> > The way the array based offload (and some software side reflink works) is
> > not a byte by byte copy. We cannot assume that a valid count can be returned
> > or that such a count would be an indication of a sequential segment of good
> > data.  The whole thing would normally have to be reissued.
> >
> > To make that a true assumption, you would have to mandate that in each of
> > the specifications (and sw targets)...
> 
> You're missing my point.
> 
>  - user issues SIZE_MAX splice request
>  - fs issues *64M* (or whatever) request to offload
>  - when that completes *fully* then we return 64M to userspace
>  - if it completes partially, then we return an error to userspace
> 
> Again, wouldn't that work?

So if implementations fall into two categories:

	- "instant": latency is on the order of a single IO.

	- "slow": latency is seconds or minutes, but still faster than a
	  normal copy.  (See Anna's NFS server implementation that does
	  an ordinary copy internally.)

Then to me it still seems simplest to design only for the "instant"
case.

But if we want to add some minimal help for the "slow" case then
Miklos's proposal looks fine: the application doesn't have to know which
case it's dealing with ahead of time--it always just submits the largest
range it knows about--but a "slow" implementation isn't forced to leave
the application waiting in one syscall for minutes with no indication
what's going on.

--b.
