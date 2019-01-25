Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DC70C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 20:10:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EC6F22184C
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 20:10:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726284AbfAYUKi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 15:10:38 -0500
Received: from fieldses.org ([173.255.197.46]:49828 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726262AbfAYUKi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Jan 2019 15:10:38 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 4505B1C1D; Fri, 25 Jan 2019 15:10:37 -0500 (EST)
Date:   Fri, 25 Jan 2019 15:10:37 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix error return values for
 nfsd4_clone_file_range()
Message-ID: <20190125201037.GA5173@fieldses.org>
References: <20190121205838.18680-1-trond.myklebust@hammerspace.com>
 <20190125004658.GB3953@fieldses.org>
 <698446e18a6718ee1ced06ecfd06e2de802fa16e.camel@gmail.com>
 <20190125163218.GA2752@fieldses.org>
 <CAN-5tyEZhVEMSjxbWfGoODb6eAmO7VJLjYkMv2HwUyXKHjyyWw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyEZhVEMSjxbWfGoODb6eAmO7VJLjYkMv2HwUyXKHjyyWw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 25, 2019 at 11:42:17AM -0500, Olga Kornievskaia wrote:
> On Fri, Jan 25, 2019 at 11:32 AM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Jan 25, 2019 at 12:50:09AM -0500, Trond Myklebust wrote:
> > > On Thu, 2019-01-24 at 19:46 -0500, J. Bruce Fields wrote:
> > > > On Mon, Jan 21, 2019 at 03:58:38PM -0500, Trond Myklebust wrote:
> > > > > If the parameter 'count' is non-zero, nfsd4_clone_file_range() will
> > > > > currently clobber all errors returned by vfs_clone_file_range() and
> > > > > replace them with EINVAL.
> > > >
> > > > Oops, thanks for the fix.  I'm still a little confused, though:
> > ...
> > > > > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > > > > index 9824e32b2f23..7dc98e14655d 100644
> > > > > --- a/fs/nfsd/vfs.c
> > > > > +++ b/fs/nfsd/vfs.c
> > > > > @@ -557,9 +557,11 @@ __be32 nfsd4_clone_file_range(struct file
> > > > > *src, u64 src_pos, struct file *dst,
> > > > >   loff_t cloned;
> > > > >
> > > > >   cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos,
> > > > > count, 0);
> > > > > + if (cloned < 0)
> > > > > +         return nfserrno(cloned);
> > > > >   if (count && cloned != count)
> > > > > -         cloned = -EINVAL;
> > > > > - return nfserrno(cloned < 0 ? cloned : 0);
> > > > > +         return nfserrno(-EINVAL);
> > > > > + return 0;
> > > >
> > > > I still don't understand the cloned != count case.  I thought clone
> > > > was
> > > > supposed to be all-or-nothing and atomic, can it really return a
> > > > short
> > > > copy?  And how is that inval, shouldn't that be serverfault?
> > >
> > > That, quite frankly, seems like more of a question for Darrick, not me.
> > > I haven't changed that part of the code.
> > >
> > > The main thing I care about is being able to correctly report
> > > EOPNOTSUPP errors for the vast majority of filesystems that don't
> > > support clone() or dedup().
> >
> > Makes sense, and I'm happy just to apply this and then sort out the rest in a
> > subsequent patch, but I'd really like to understand; Darrick?:
> >
> > ioctl_file_clone also converts short copies to EINVAL:
> >
> >         if (cloned < 0)
> >                 ret = cloned;
> >         else if (olen && cloned != olen)
> >                 ret = -EINVAL;
> >         else
> >                 ret = 0;
> >
> > Maybe that happens iff we hit EOF in the short file?
> >
> > Does that mean we can successfully copy up to EOF and then return -EINVAL?
> > That sounds wrong.
> >
> > There's a man page (IOCTL-FICLONERANGE(2)) but it doesn't cover this case.
> 
> I thought cloned by definition was all or nothing meaning there can't
> be a "short" clone. If you allow for less then asked bytes to be
> returned, then your next offsets might not be block aligned.

Yeah.  I was assuming it could happen in the case you ask to clone
beyond the end of the source file.  But looking at the code, there's a
check for that case in generic_remap_checks() before doing the clone,
and while holding a write lock on i_rwsem (I assume that's enough to
hold the file size constant).  At least that's true in the cases (btrfs
& xfs) that I checked.

So, I don't know, maybe that check is just dead code.

--b.
