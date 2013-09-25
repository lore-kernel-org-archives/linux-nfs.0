Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60564 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753333Ab3IYTzb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Sep 2013 15:55:31 -0400
Date: Wed, 25 Sep 2013 15:55:26 -0400
To: Zach Brown <zab@redhat.com>
Cc: Anna Schumaker <schumaker.anna@gmail.com>,
        Szeredi Miklos <miklos@szeredi.hu>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20130925195526.GA18971@fieldses.org>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
 <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
 <20130925183828.GA30372@lenny.home.zabbo.net>
 <CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com>
 <20130925190620.GB30372@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130925190620.GB30372@lenny.home.zabbo.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 25, 2013 at 12:06:20PM -0700, Zach Brown wrote:
> On Wed, Sep 25, 2013 at 03:02:29PM -0400, Anna Schumaker wrote:
> > On Wed, Sep 25, 2013 at 2:38 PM, Zach Brown <zab@redhat.com> wrote:
> > >
> > > Hrmph.  I had composed a reply to you during Plumbers but.. something
> > > happened to it :).  Here's another try now that I'm back.
> > >
> > >> > Some things to talk about:
> > >> > - I really don't care about the naming here.  If you do, holler.
> > >> > - We might want different flags for file-to-file splicing and acceleration
> > >>
> > >> Yes, I think "copy" and "reflink" needs to be differentiated.
> > >
> > > I initially agreed but I'm not so sure now.  The problem is that we
> > > can't know whether the acceleration is copying or not.  XCOPY on some
> > > array may well do some shared referencing tricks.  The nfs COPY op can
> > > have a server use btrfs reflink, or ext* and XCOPY, or .. who knows.  At
> > > some point we have to admit that we have no way to determine the
> > > relative durability of writes.  Storage can do a lot to make writes more
> > > or less fragile that we have no visibility of.  SSD FTLs can log a bunch
> > > of unrelated sectors on to one flash failure domain.
> > >
> > > And if such a flag couldn't *actually* guarantee anything for a bunch of
> > > storage topologies, well, let's not bother with it.
> > >
> > > The only flag I'm in favour of now is one that has splice return rather
> > > than falling back to manual page cache reads and writes.  It's more like
> > > O_NONBLOCK than any kind of data durability hint.
> > 
> > For reference, I'm planning to have the NFS server do the fallback
> > when it copies since any local copy will be faster than a read and
> > write over the network.
> 
> Agreed, this is definitely the reasonable thing to do.

A client-side copy will be slower, but I guess it does have the
advantage that the application can track progress to some degree, and
abort it fairly quickly without leaving the file in a totally undefined
state--and both might be useful if the copy's not a simple constant-time
operation.

So maybe a way to pass your NONBLOCKy flag to the server would be
useful?

FWIW the protocol doesn't seem frozen yet, so I assume we could still
add an extra flag field if you think it would be worthwhile.

--b.
