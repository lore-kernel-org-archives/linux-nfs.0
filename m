Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:32832 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752762AbcLFNSf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2016 08:18:35 -0500
Received: by mail-vk0-f42.google.com with SMTP id 137so195618393vkl.0
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2016 05:18:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJfpegvRFGOc31gVuYzanzWJ=mYSgRgtAaPhYNxZwHin3Wc0Gw@mail.gmail.com>
References: <5a6862bd-924d-25e4-2a8e-ba4f51e66604@web.de> <CAJfpeguwUtRWRGmNmimNp-FXzWqMCCQMb24iWPu0w_J0_rOnnw@mail.gmail.com>
 <20161205151933.GA17517@fieldses.org> <CAJfpegtpkavseTFLspaC7svbvHRq-0-7jvyh63+DK5iWHTGnaQ@mail.gmail.com>
 <20161205162559.GB17517@fieldses.org> <CAHpGcMKHjic6L+J0qvMYNG9hVCcDO1hEpx4BiEk0ZCKDV39BmA@mail.gmail.com>
 <266c571f-e4e2-7c61-5ee2-8ece0c2d06e9@web.de> <CAHpGcMKmtppfn7PVrGKEEtVphuLV=YQ2GDYKOqje4ZANhzSgDw@mail.gmail.com>
 <CAHpGcMKjscfhmrAhwGes0ag2xTkbpFvCO6eiLL_rHz87XE-ZmA@mail.gmail.com> <CAJfpegvRFGOc31gVuYzanzWJ=mYSgRgtAaPhYNxZwHin3Wc0Gw@mail.gmail.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 6 Dec 2016 14:18:31 +0100
Message-ID: <CAHc6FU4JQ28BFZE9_8A06gtkMvvKDzFmw9=ceNPYvnMXEimDMw@mail.gmail.com>
Subject: Re: [PATCH] overlayfs: ignore empty NFSv4 ACLs in ext4 upperdir
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>,
        Patrick Plagwitz <Patrick_Plagwitz@web.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 6, 2016 at 11:08 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> On Tue, Dec 6, 2016 at 12:24 AM, Andreas Grünbacher
> <andreas.gruenbacher@gmail.com> wrote:
>> 2016-12-06 0:19 GMT+01:00 Andreas Grünbacher <andreas.gruenbacher@gmail.com>:
>
>>> It's not hard to come up with a heuristic that determines if a
>>> system.nfs4_acl value is equivalent to a file mode, and to ignore the
>>> attribute in that case. (The file mode is transmitted in its own
>>> attribute already, so actually converting .) That way, overlayfs could
>>> still fail copying up files that have an actual ACL. It's still an
>>> ugly hack ...
>>
>> Actually, that kind of heuristic would make sense in the NFS client
>> which could then hide the "system.nfs4_acl" attribute.
>
> Even simpler would be if knfsd didn't send the attribute if not
> necessary.  Looks like there's code actively creating the nfs4_acl on
> the wire even if the filesystem had none:
>
>     pacl = get_acl(inode, ACL_TYPE_ACCESS);
>     if (!pacl)
>         pacl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
>
> What's the point?

That's how the protocol is specified. (I'm not saying that that's very helpful.)

Andreas
