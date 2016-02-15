Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34284 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbcBOKZT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2016 05:25:19 -0500
Subject: Re: richacl(7) man page review comments
To: Andreas Gruenbacher <agruenba@redhat.com>
References: <56B770B6.7040803@gmail.com> <56B77262.7090107@gmail.com>
 <CAHc6FU5__xbKm4mg8+fK_ZW5ZYsDoQcYBBvQg573Eq4ERDsROw@mail.gmail.com>
 <56C0F150.60008@gmail.com>
 <CAHc6FU49uRb11HhO655jimn_CzLrDyGHAB2iDAv92cftCCXkEA@mail.gmail.com>
Cc: mtk.manpages@gmail.com, "J. Bruce Fields" <bfields@fieldses.org>,
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
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <56C1A788.9020008@gmail.com>
Date: Mon, 15 Feb 2016 11:25:12 +0100
MIME-Version: 1.0
In-Reply-To: <CAHc6FU49uRb11HhO655jimn_CzLrDyGHAB2iDAv92cftCCXkEA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andreas,

On 02/15/2016 12:12 AM, Andreas Gruenbacher wrote:
> On Sun, Feb 14, 2016 at 10:27 PM, Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> On 02/12/2016 11:25 PM, Andreas Gruenbacher wrote:
>>> We could sure move acl(5) and richacl(7) there.
>>
>> We already have acl(5) (now "acl(7)" in man pages) ;-).
> 
> Hmm, I can't find that page either in
> git://git.kernel.org/pub/scm/docs/man-pages/man-pages or on
> http://man7.org/. Are you sure you don't mean xattr.7 == attr.5 which
> documents the xattr syscall interface?

You're right. I was confusing with xattr(7). So, I think it might
make some sense to eventually move both of these into man-pages (for 
richacl(7), at least, it's probably worth delaying this for a bit), 
since  they're describing kernel-user-space interfaces. I can see 
counter-arguments too, such as these pages are closely related to 
the corresponding user-space libraries you maintain. What do you
think?

Thanks,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
