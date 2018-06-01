Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58840 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751964AbeFARng (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Jun 2018 13:43:36 -0400
Date: Fri, 1 Jun 2018 13:43:36 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
Message-ID: <20180601174336.GF10666@fieldses.org>
References: <95e00ce46fe1f5fed50fe24947eee0dda51e0140.camel@hammerspace.com>
 <c59d0be3-a10b-02c3-8126-3402a6a0eab1@suse.de>
 <828f320cde910a45983d91bddb6477d21c5cae33.camel@hammerspace.com>
 <CAJfpegvuvFzNwSZRLCMCrhms-K4Ge=PTcn4uezLgV8U3ag+4xQ@mail.gmail.com>
 <20180601135033.GA10666@fieldses.org>
 <CAJfpegvG4rkesopg=qj1H288X6H9CXu=N_fuYEsuWJ-O=5785A@mail.gmail.com>
 <20180601142640.GC10666@fieldses.org>
 <CAJfpegtmSK5yuU-Vz7mPODy=iP+=BLMs2fy=sH-iWG8g3jeBfg@mail.gmail.com>
 <20180601160857.GE10666@fieldses.org>
 <CAJfpeguFobmD5EdvYU7eFaaShMYxt9j72k=GKGHyh3-D-uCB-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpeguFobmD5EdvYU7eFaaShMYxt9j72k=GKGHyh3-D-uCB-Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 01, 2018 at 07:02:20PM +0200, Miklos Szeredi wrote:
> On Fri, Jun 1, 2018 at 6:08 PM, bfields@fieldses.org
> <bfields@fieldses.org> wrote:
> > On Fri, Jun 01, 2018 at 04:43:51PM +0200, Miklos Szeredi wrote:
> >> Look at ovl_permission(), I think it pretty clearly describes this model.
> >
> > Thanks!  Uh, so generic_permission is the thing that just does the usual
> > mode/acl checks on the in-core inode, and inode_permission is the one
> > that also calls into the filesystem?
> 
> Right.
> 
> > But I'm still a little confused--if I'm reading right, "realinode" is
> > the lower inode before copyup, and the upper inode after, so can't
> > inode_permission(realinode, mask) return different results before and
> > after copyup?
> 
> Theoretically, yes.  Not in any sane setup, though.

If root squashing is enabled and you mount as root, then it will change.

That's not an unlikely case, it's pretty much the default.

--b.

> 
> The inode_permission() checks on realinode are for making sure the
> mounter cannot gain undue privileges (will be especially important
> with userns mounts).


