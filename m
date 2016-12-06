Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44708 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751593AbcLFS6I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 13:58:08 -0500
Date: Tue, 6 Dec 2016 13:58:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>,
        Andreas =?utf-8?Q?Gr=C3=BCnbacher?=
        <andreas.gruenbacher@gmail.com>,
        Patrick Plagwitz <Patrick_Plagwitz@web.de>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] overlayfs: ignore empty NFSv4 ACLs in ext4 upperdir
Message-ID: <20161206185806.GC31197@fieldses.org>
References: <CAJfpeguwUtRWRGmNmimNp-FXzWqMCCQMb24iWPu0w_J0_rOnnw@mail.gmail.com>
 <20161205151933.GA17517@fieldses.org>
 <CAJfpegtpkavseTFLspaC7svbvHRq-0-7jvyh63+DK5iWHTGnaQ@mail.gmail.com>
 <20161205162559.GB17517@fieldses.org>
 <CAHpGcMKHjic6L+J0qvMYNG9hVCcDO1hEpx4BiEk0ZCKDV39BmA@mail.gmail.com>
 <266c571f-e4e2-7c61-5ee2-8ece0c2d06e9@web.de>
 <CAHpGcMKmtppfn7PVrGKEEtVphuLV=YQ2GDYKOqje4ZANhzSgDw@mail.gmail.com>
 <CAHpGcMKjscfhmrAhwGes0ag2xTkbpFvCO6eiLL_rHz87XE-ZmA@mail.gmail.com>
 <CAJfpegvRFGOc31gVuYzanzWJ=mYSgRgtAaPhYNxZwHin3Wc0Gw@mail.gmail.com>
 <CAHc6FU4JQ28BFZE9_8A06gtkMvvKDzFmw9=ceNPYvnMXEimDMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHc6FU4JQ28BFZE9_8A06gtkMvvKDzFmw9=ceNPYvnMXEimDMw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 06, 2016 at 02:18:31PM +0100, Andreas Gruenbacher wrote:
> On Tue, Dec 6, 2016 at 11:08 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> > On Tue, Dec 6, 2016 at 12:24 AM, Andreas Grünbacher
> > <andreas.gruenbacher@gmail.com> wrote:
> >> 2016-12-06 0:19 GMT+01:00 Andreas Grünbacher <andreas.gruenbacher@gmail.com>:
> >
> >>> It's not hard to come up with a heuristic that determines if a
> >>> system.nfs4_acl value is equivalent to a file mode, and to ignore the
> >>> attribute in that case. (The file mode is transmitted in its own
> >>> attribute already, so actually converting .) That way, overlayfs could
> >>> still fail copying up files that have an actual ACL. It's still an
> >>> ugly hack ...
> >>
> >> Actually, that kind of heuristic would make sense in the NFS client
> >> which could then hide the "system.nfs4_acl" attribute.
> >
> > Even simpler would be if knfsd didn't send the attribute if not
> > necessary.  Looks like there's code actively creating the nfs4_acl on
> > the wire even if the filesystem had none:
> >
> >     pacl = get_acl(inode, ACL_TYPE_ACCESS);
> >     if (!pacl)
> >         pacl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
> >
> > What's the point?
> 
> That's how the protocol is specified.

Yep, even if we could make that change to nfsd it wouldn't help the
client with the large number of other servers that are out there
(including older knfsd's).

--b.

> (I'm not saying that that's very helpful.)
> 
> Andreas
