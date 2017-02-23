Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56266 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751119AbdBWUU3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 15:20:29 -0500
Date: Thu, 23 Feb 2017 15:20:26 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dros Adamson <dros@primarydata.com>,
        Weston Andros Adamson <dros@netapp.com>
Subject: Re: [PATCH 6/6] NFSv4: allow getacl rpc to allocate pages on demand
Message-ID: <20170223202025.GI9417@parsley.fieldses.org>
References: <20170220160940.GB12335@parsley.fieldses.org>
 <4824B968-4ED6-44AA-A935-3D309D76EFFF@oracle.com>
 <20170220171519.GE12335@parsley.fieldses.org>
 <CAHc6FU6_bJE--6Da5Df+g+qRj6C1KZUL5PvkXrZ-mKbJqU936w@mail.gmail.com>
 <E06C6589-2E66-4013-9722-0FEADE596F70@oracle.com>
 <CAHc6FU6JghZAxiwj0XF0sOj1OufbxvabX+gYO52ROSZXDY1+dA@mail.gmail.com>
 <20170221213702.GA18645@parsley.fieldses.org>
 <CAHc6FU5EpChr02-t2ZRZ=oX1kRPO=L8TriLAzCxcoNhJSvxs+g@mail.gmail.com>
 <20170222015333.GA20019@parsley.fieldses.org>
 <CAHc6FU5WxqOOvr-qGeO3gjykiyFyZGPf2W5VJiTGkcR0AiyP5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU5WxqOOvr-qGeO3gjykiyFyZGPf2W5VJiTGkcR0AiyP5g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 23, 2017 at 11:28:46AM +0100, Andreas Gruenbacher wrote:
> On Wed, Feb 22, 2017 at 2:53 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Tue, Feb 21, 2017 at 10:45:35PM +0100, Andreas Gruenbacher wrote:
> >> On Tue, Feb 21, 2017 at 10:37 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >> > On Tue, Feb 21, 2017 at 10:21:05PM +0100, Andreas Gruenbacher wrote:
> >> >> On Tue, Feb 21, 2017 at 7:46 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >> >> > Hi Andreas-
> >> >> >
> >> >> >
> >> >> >> On Feb 20, 2017, at 4:31 PM, Andreas Gruenbacher <agruenba@redhat.com> wrote:
> >> >> >>
> >> >> >> On Mon, Feb 20, 2017 at 6:15 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >> >> >>> On Mon, Feb 20, 2017 at 11:42:31AM -0500, Chuck Lever wrote:
> >> >> >>>>
> >> >> >>>>> On Feb 20, 2017, at 11:09 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> >> >> >>>>>
> >> >> >>>>> On Sun, Feb 19, 2017 at 02:29:03PM -0500, Chuck Lever wrote:
> >> >> >>>>>>
> >> >> >>>>>>> On Feb 18, 2017, at 9:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >> >> >>>>>>>
> >> >> >>>>>>> From: Weston Andros Adamson <dros@netapp.com>
> >> >> >>>>>>>
> >> >> >>>>>>> Instead of preallocating pags, allow xdr_partial_copy_from_skb() to
> >> >> >>>>>>> allocate whatever pages we need on demand.  This is what the NFSv3 ACL
> >> >> >>>>>>> code does.
> >> >> >>>>>>
> >> >> >>>>>> The patch description does not explain why this change is
> >> >> >>>>>> being done.
> >> >> >>>>>
> >> >> >>>>> The only justification I see is avoiding allocating pages unnecessarily.
> >> >> >>>>
> >> >> >>>> That makes sense. Is there a real world workload that has seen
> >> >> >>>> a negative effect?
> >> >> >>>>
> >> >> >>>>
> >> >> >>>>> Without this patch, for each getacl, we allocate 17 pages (if I'm
> >> >> >>>>> calculating correctly) and probably rarely use most of them.
> >> >> >>>>>
> >> >> >>>>> In the v3 case I think it's 7 pages instead of 17.
> >> >> >>>>
> >> >> >>>> I would have guessed 9. Out of curiosity, is there a reason
> >> >> >>>> documented for these size limits?
> >> >> >>>
> >> >> >>>
> >> >> >>> In the v4 case:
> >> >> >>>
> >> >> >>>        #define NFS4ACL_MAXPAGES DIV_ROUND_UP(XATTR_SIZE_MAX, PAGE_SIZE)
> >> >> >>>
> >> >> >>> And I believe XATTR_SIZE_MAX is a global maximum on the size of any
> >> >> >>> extend attribute value.
> >> >> >>
> >> >> >> XATTR_SIZE_MAX is the maximum size of an extended attribute. NFSv4
> >> >> >> ACLs are passed through unchanged in "system.nfs4_acl".
> >> >> >
> >> >> > "Extended attribute" means this is a Linux-specific limit?
> >> >>
> >> >> Yes.
> >> >>
> >> >> > Is there anything that prevents a non-Linux system from constructing
> >> >> > or returning an ACL that is larger than that?
> >> >>
> >> >> No.
> >> >
> >> > In the >=v4.1 case there are session limits, but they'll typically be
> >> > less.  In the 4.0 case I think there's no explicit limit at all.  In
> >> > practice I bet other systems are similar to Linux in that the assume
> >> > peers won't send rpc replies or requests larger than about the
> >> > maximum-sized read or write.  But again that'll usually be a higher
> >> > limit than our ACL limit.
> >> >
> >> >> > What happens on a Linux client when a server returns an ACL that does
> >> >> > not fit in this allotment?
> >> >>
> >> >> I would hope an error, but I haven't tested it.
> >> >
> >> > I haven't tested either, but it looks to me like the rpc layer receives
> >> > a truncated request, the xdr decoding recognizes that it's truncated,
> >> > and the result is an -ERANGE.
> >> >
> >> > Looking now I think that my "NFSv4: simplify getacl decoding" changes
> >> > that to an -EIO.  More importantly, it makes that an EIO even when the
> >> > calling application was only asking for the length, not the actual ACL
> >> > data.  I'll fix that.
> >>
> >> Just be careful not to return a length from getxattr(path, name, NULL,
> >> 0) that will cause getxattr(path, name, buffer, size) to fail with
> >> ERANGE, please. Otherwise, user space might get very confused.
> >
> > Ugh, OK.  So there could be userspace code that does something like
> >
> >         while (getxattr(path, name, buf, size) == -ERANGE) {
> >                 /* oops, must have raced with a size change */
> >                 size = getxattr(path, name, NULL, 0);
> >                 buf = realloc(buf, size);
> >         }
> >
> > and you'd consider that a kernel bug not a userspace bug?
> 
> It would at least provoke errors if the above loop (with an additional
> check for size == -1) didn't terminate, so I'd like to avoid that. I
> see now that there is botched code in fs/xattr.c that tries to prevent
> that, so I'll try to fix that so that file systems won't have to
> bother.

Having seen your patch on fs-devel....  OK, so after that point, we can
choose in NFS to either to return -E2BIG ourselves or to return success
with the large length and let fs/xattr convert to -E2BIG if necessary.
Thanks, that makes sense.

> > I suspect that can happen both before and after my changes.
> >
> > So what do we want for that case?  Just -EIO?
> 
> getxattr and listxattr are trying to cast that kind of error to
> -E2BIG, which seems okay.

Got it, thanks.

--b.
