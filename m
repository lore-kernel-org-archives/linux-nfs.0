Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754058Ab3IZTGo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 15:06:44 -0400
Date: Thu, 26 Sep 2013 12:06:11 -0700
From: Zach Brown <zab@redhat.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20130926190611.GP30372@lenny.home.zabbo.net>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
 <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
 <20130925183828.GA30372@lenny.home.zabbo.net>
 <CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com>
 <20130925190620.GB30372@lenny.home.zabbo.net>
 <20130925195526.GA18971@fieldses.org>
 <20130925210742.GG30372@lenny.home.zabbo.net>
 <CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com>
 <20130926153359.GE704@fieldses.org>
 <CAJfpegsUchb0eX+Hi3rN5Ypje3Y-dgo=pxgM1Y3BQbHVp=1hSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegsUchb0eX+Hi3rN5Ypje3Y-dgo=pxgM1Y3BQbHVp=1hSw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 08:06:41PM +0200, Miklos Szeredi wrote:
> On Thu, Sep 26, 2013 at 5:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Thu, Sep 26, 2013 at 10:58:05AM +0200, Miklos Szeredi wrote:
> >> On Wed, Sep 25, 2013 at 11:07 PM, Zach Brown <zab@redhat.com> wrote:
> >> >> A client-side copy will be slower, but I guess it does have the
> >> >> advantage that the application can track progress to some degree, and
> >> >> abort it fairly quickly without leaving the file in a totally undefined
> >> >> state--and both might be useful if the copy's not a simple constant-time
> >> >> operation.
> >> >
> >> > I suppose, but can't the app achieve a nice middle ground by copying the
> >> > file in smaller syscalls?  Avoid bulk data motion back to the client,
> >> > but still get notification every, I dunno, few hundred meg?
> >>
> >> Yes.  And if "cp"  could just be switched from a read+write syscall
> >> pair to a single splice syscall using the same buffer size.
> >
> > Will the various magic fs-specific copy operations become inefficient
> > when the range copied is too small?
> 
> We could treat spice-copy operations just like write operations (can
> be buffered, coalesced, synced).
> 
> But I'm not sure it's worth the effort; 99% of the use of this
> interface will be copying whole files.  And for that perhaps we need a
> different API, one which has been discussed some time ago:
> asynchronous copyfile() returns immediately with a pollable event
> descriptor indicating copy progress, and some way to cancel the copy.
> And that can internally rely on ->direct_splice(), with appropriate
> algorithms for determine the optimal  chunk size.

And perhaps we don't.  Perhaps we can provide this much simpler
data-plane interface that works well enough for most everyone and can
avoid going down the async rat hole, yet again.

- z
