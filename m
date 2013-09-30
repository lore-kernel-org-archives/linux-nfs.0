Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46369 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753979Ab3I3Oei (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 10:34:38 -0400
Date: Mon, 30 Sep 2013 10:34:32 -0400
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
Message-ID: <20130930143432.GG16579@fieldses.org>
References: <20130925210742.GG30372@lenny.home.zabbo.net>
 <CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com>
 <20130926185508.GO30372@lenny.home.zabbo.net>
 <5244A68F.906@redhat.com>
 <20130927200550.GA22640@fieldses.org>
 <20130927205013.GZ30372@lenny.home.zabbo.net>
 <CAJfpegtdiQzP7t5hc_OaHjSGTrjdZLfKi6fiKqBQ_+AP2Y0-oQ@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9467EF2D7@SACEXCMBX04-PRD.hq.netapp.com>
 <52474839.2080201@redhat.com>
 <CAJfpegsN7Hu8uecSVQrhax+n+zhq=uUgpzOk=qZ6_n383tdNCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAJfpegsN7Hu8uecSVQrhax+n+zhq=uUgpzOk=qZ6_n383tdNCQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 30, 2013 at 02:20:30PM +0200, Miklos Szeredi wrote:
> On Sat, Sep 28, 2013 at 11:20 PM, Ric Wheeler <rwheeler@redhat.com> wrote:
> 
> >>> I don't see the safety argument very compelling either.  There are real
> >>> semantic differences, however: ENOSPC on a write to a
> >>> (apparentlíy) already allocated block.  That could be a bit unexpected.
> >>> Do we
> >>> need a fallocate extension to deal with shared blocks?
> >>
> >> The above has been the case for all enterprise storage arrays ever since
> >> the invention of snapshots. The NFSv4.2 spec does allow you to set a
> >> per-file attribute that causes the storage server to always preallocate
> >> enough buffers to guarantee that you can rewrite the entire file, however
> >> the fact that we've lived without it for said 20 years leads me to believe
> >> that demand for it is going to be limited. I haven't put it top of the list
> >> of features we care to implement...
> >>
> >> Cheers,
> >>     Trond
> >
> >
> > I agree - this has been common behaviour for a very long time in the array
> > space. Even without an array,  this is the same as overwriting a block in
> > btrfs or any file system with a read-write LVM snapshot.
> 
> Okay, I'm convinced.
> 
> So I suggest
> 
>  - mount(..., MNT_REFLINK): *allow* splice to reflink.  If this is not
> set, fall back to page cache copy.
>  - splice(... SPLICE_REFLINK):  fail non-reflink copy.  With this app
> can force reflink.
> 
> Both are trivial to implement and make sure that no backward
> incompatibility surprises happen.
> 
> My other worry is about interruptibility/restartability.  Ideas?
> 
> What happens on splice(from, to, 4G) and it's a non-reflink copy?
> Can the page cache copy be made restartable?   Or should splice() be
> allowed to return a short count?  What happens on (non-reflink) remote
> copies and huge request sizes?

If I were writing an application that required copies to be restartable,
I'd probably use the largest possible range in the reflink case but
break the copy into smaller chunks in the splice case.

For that reason I don't like the idea of a mount option--the choice is
something that the application probably wants to make (or at least to
know about).

The NFS COPY operation, as specified in current drafts, allows for
asynchronous copies but leaves the state of the file undefined in the
case of an aborted COPY.  I worry that agreeing on standard behavior in
the case of an abort might be difficult.

--b.
