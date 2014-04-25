Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54658 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbaDYHjO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 03:39:14 -0400
Date: Fri, 25 Apr 2014 03:39:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Layton Jeff <jlayton@redhat.com>
Subject: Re: nfsd bug fixes for 3.15
Message-ID: <20140425073912.GA22295@fieldses.org>
References: <20140424062516.GA8891@fieldses.org>
 <CAHQdGtRfybuqsxiS=Hd4Stkm1ex13f6SeEk5XbQcy35UZStHRA@mail.gmail.com>
 <20140424153116.GA15459@fieldses.org>
 <20140424163414.GA16429@fieldses.org>
 <CAHQdGtQ_WMRrEWb5Lq8zS7A6eeuN5_UrEtB9baOfciCbuNSLjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQ_WMRrEWb5Lq8zS7A6eeuN5_UrEtB9baOfciCbuNSLjA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 24, 2014 at 12:46:36PM -0400, Trond Myklebust wrote:
> On Thu, Apr 24, 2014 at 12:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Thu, Apr 24, 2014 at 11:31:16AM -0400, J. Bruce Fields wrote:
> >> On Thu, Apr 24, 2014 at 06:51:03AM -0400, Trond Myklebust wrote:
> >> > Hi Bruce,
> >> >
> >> > On Thu, Apr 24, 2014 at 2:25 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> > > Please pull the following bug fixes for 3.15 from:
> >> > >
> >> > >   git://linux-nfs.org/~bfields/linux.git for-3.15
> >> > >
> >> > > Three small nfsd bugfixes (including one locks.c fix for a bug triggered
> >> > > only from nfsd).
> >> > >
> >> > > Jeff's patches are for long-existing problems that became easier to
> >> > > trigger since the addition of vfs delegation support.
> >> > >
> >> > > --b.
> >> > >
> >> > > ----------------------------------------------------------------
> >> > > J. Bruce Fields (1):
> >> > >       Revert "nfsd4: fix nfs4err_resource in 4.1 case"
> >> > >
> >> >
> >> > Wait. Why?
> >>
> >> Have you changed your mind since our previous discussion, or just
> >> forgotten it?  (Or did I screw up and revert the wrong commit?)  See
> >>
> >>       http://mid.gmane.org/<BAD6904F-A82A-4FBC-807F-16560B2A23E0@primarydata.com>
> >>
> >> > NFS4ERR_RESOURCE breaks the Linux client.
> >>
> >> This returns us to pre-3.15 behavior so shouldn't introduce any new
> >> breakage.
> >>
> >> Fundamentally the problem is that we're returning an error in cases that
> >> shouldn't succeed, and rather than replacing one incorrect error by
> >
> > s/shouldn't/should/, apologies!--b.
> >
> >> another it seemed better to wait for a proper fix.
> >>
> >> --b.
> 
> I really shouldn't try to read my email before 8am (or at least not
> before my third espresso). I was confusing this with the
> NFS4ERR_STALE_STATEID problem that was merged as part of the same
> pull.
> Reverting the NFS4ERR_RESOURCE patch is fine.

Great, thanks.--b.
