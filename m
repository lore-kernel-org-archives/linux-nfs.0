Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37211 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231AbcBOOPs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2016 09:15:48 -0500
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <CAHc6FU69k2uRXjSSS+9K0cXzFs74DPsz6DDv8GN=hmh7RpPA-Q@mail.gmail.com>
References: <56B770B6.7040803@gmail.com> <56B77262.7090107@gmail.com>
 <CAHc6FU5__xbKm4mg8+fK_ZW5ZYsDoQcYBBvQg573Eq4ERDsROw@mail.gmail.com>
 <56C0F150.60008@gmail.com> <CAHc6FU49uRb11HhO655jimn_CzLrDyGHAB2iDAv92cftCCXkEA@mail.gmail.com>
 <56C1A788.9020008@gmail.com> <CAHc6FU69k2uRXjSSS+9K0cXzFs74DPsz6DDv8GN=hmh7RpPA-Q@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Mon, 15 Feb 2016 15:15:27 +0100
Message-ID: <CAKgNAki53C7bZyWFSQMD1ArCD9w2V9RH0MozCk99G1=PuUUy1g@mail.gmail.com>
Subject: Re: richacl(7) man page review comments
To: Andreas Gruenbacher <agruenba@redhat.com>
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

On 15 February 2016 at 12:35, Andreas Gruenbacher <agruenba@redhat.com> wrote:
> On Mon, Feb 15, 2016 at 11:25 AM, Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> You're right. I was confusing with xattr(7). So, I think it might
>> make some sense to eventually move both of these into man-pages (for
>> richacl(7), at least, it's probably worth delaying this for a bit),
>> since  they're describing kernel-user-space interfaces.
>
> Well, the actual user-space interface is xattrs in both cases.

Yes, xattrs are the base of the framework, but I was using "interface"
in a very broad way: ACLs and RichACLs are exposing kernel-defined
policies and rules about file permissions to user space (much as say
chmod(2) and the file mode bits). That's why it seems to make some
sense to place those pages with the other pages that describe
kernel-user-spaces interfaces. Plus, they'd now and then get some
man-pages love :-).

>> I can see counter-arguments too, such as these pages are closely
>> related to the corresponding user-space libraries you maintain.
>> What do you think?
>
> I would keep the man-pages where they are right now, but I don't have
> a strong preference.

I'd be happy to see acl(5) and eventually richacl(7) in man pages, but
it's your call in the end, of course.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
