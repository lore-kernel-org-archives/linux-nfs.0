Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58412 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752691AbeFAO0k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Jun 2018 10:26:40 -0400
Date: Fri, 1 Jun 2018 10:26:40 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
Message-ID: <20180601142640.GC10666@fieldses.org>
References: <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com>
 <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
 <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com>
 <d6fab628-6fd1-de33-2ca4-d82917205ce7@suse.de>
 <95e00ce46fe1f5fed50fe24947eee0dda51e0140.camel@hammerspace.com>
 <c59d0be3-a10b-02c3-8126-3402a6a0eab1@suse.de>
 <828f320cde910a45983d91bddb6477d21c5cae33.camel@hammerspace.com>
 <CAJfpegvuvFzNwSZRLCMCrhms-K4Ge=PTcn4uezLgV8U3ag+4xQ@mail.gmail.com>
 <20180601135033.GA10666@fieldses.org>
 <CAJfpegvG4rkesopg=qj1H288X6H9CXu=N_fuYEsuWJ-O=5785A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegvG4rkesopg=qj1H288X6H9CXu=N_fuYEsuWJ-O=5785A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 01, 2018 at 04:00:22PM +0200, Miklos Szeredi wrote:
> On Fri, Jun 1, 2018 at 3:50 PM, bfields@fieldses.org
> <bfields@fieldses.org> wrote:
> > On Fri, Jun 01, 2018 at 03:32:59PM +0200, Miklos Szeredi wrote:
> >> How do you define "safely"?
> >>
> >> Is it safe for root to do
> >>
> >>   cp -a /nfs/remotedir /tmp/localdir
> >>
> >> ?
> >>
> >> That's essentially what an overlayfs mount with an NFS layer does with
> >> respect to access permissions:
> >>
> >>  - remote files are not modifiable to anyone, unless server allows
> >>
> >>  - remote files *readable to root* will provide access based on local DAC check.
> >>
> >> Does that need to be made clear in the docs?  Surely.  But it does NOT
> >> mean it's dangerous or that it's not useful with an arbitrary NFS
> >> server
> >
> > We should definitely have clear documentation, but despite that, in
> > practice lots of people *will* be surprised when permissions are
> > enforced differently after copy-up, and those surprises may well have
> > unpleasant implications.
> 
> Permissions are enforced exactly the same before and after copy-up.
> That's one of the good points in doing the permission checks locally.

Whoops, sorry, I missed that.  So you always read owners and mode bits
out of the cached inode and used those to check permissions instead of
calling access?

That still sounds pretty confusing.  E.g. if the server's squashing root
to a user without permission to read a file, you'll pass local
permission checks, but the success a given read may actually depend on
whether the data's already cached?  I feel like I still must not
understand something.  Sorry if I'm making these threads repeat
themselves....

--b.

> 
> That "cp -a /nfs/remotedir /tmp/localdir" example is almost exactly
> equivalent to:
> 
>   mount -t overlay -olowerdir=/nfs/remotedir,upperdir=/tmp/upper,...
> /tmp/localdir
> 
> except the copy is delayed until modification.
> 
> Thanks,
> Miklos
