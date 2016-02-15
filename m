Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:35990 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbcBOLfQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2016 06:35:16 -0500
Received: by mail-vk0-f42.google.com with SMTP id c3so104919787vkb.3
        for <linux-nfs@vger.kernel.org>; Mon, 15 Feb 2016 03:35:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56C1A788.9020008@gmail.com>
References: <56B770B6.7040803@gmail.com>
	<56B77262.7090107@gmail.com>
	<CAHc6FU5__xbKm4mg8+fK_ZW5ZYsDoQcYBBvQg573Eq4ERDsROw@mail.gmail.com>
	<56C0F150.60008@gmail.com>
	<CAHc6FU49uRb11HhO655jimn_CzLrDyGHAB2iDAv92cftCCXkEA@mail.gmail.com>
	<56C1A788.9020008@gmail.com>
Date: Mon, 15 Feb 2016 12:35:14 +0100
Message-ID: <CAHc6FU69k2uRXjSSS+9K0cXzFs74DPsz6DDv8GN=hmh7RpPA-Q@mail.gmail.com>
Subject: Re: richacl(7) man page review comments
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, lkml <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        Dave Chinner <david@fromorbit.com>,
        Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Andreas Dilger <adilger@dilger.ca>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 15, 2016 at 11:25 AM, Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> You're right. I was confusing with xattr(7). So, I think it might
> make some sense to eventually move both of these into man-pages (for
> richacl(7), at least, it's probably worth delaying this for a bit),
> since  they're describing kernel-user-space interfaces.

Well, the actual user-space interface is xattrs in both cases.

> I can see counter-arguments too, such as these pages are closely
> related to the corresponding user-space libraries you maintain.
> What do you think?

I would keep the man-pages where they are right now, but I don't have
a strong preference.

Andreas
