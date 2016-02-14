Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38753 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbcBNV1w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Feb 2016 16:27:52 -0500
Subject: Re: richacl(7) man page review comments
To: Andreas Gruenbacher <agruenba@redhat.com>
References: <56B770B6.7040803@gmail.com> <56B77262.7090107@gmail.com>
 <CAHc6FU5__xbKm4mg8+fK_ZW5ZYsDoQcYBBvQg573Eq4ERDsROw@mail.gmail.com>
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
Message-ID: <56C0F150.60008@gmail.com>
Date: Sun, 14 Feb 2016 22:27:44 +0100
MIME-Version: 1.0
In-Reply-To: <CAHc6FU5__xbKm4mg8+fK_ZW5ZYsDoQcYBBvQg573Eq4ERDsROw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/12/2016 11:25 PM, Andreas Gruenbacher wrote:
> Hi Michael,
> 
> On Sun, Feb 7, 2016 at 5:35 PM, Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> Hi Andreas,
>>
>> I'll probably have quite a few more comments on this page as I get to
>> understand RichACLs better. Here's some comments from an initial
>> reading.
> 
> thanks a lot for all the feedback to the man-pages. I've more or less
> made all the suggested changes but didn't get to adding examples yet
> (that's not so easy).
> 
> The changes are here:
> 
>   https://github.com/andreas-gruenbacher/richacl

Thanks. I'll send a few further comments. But I hope to send
more in the future.

>> So, an initial comment. It seems to me to that this page (but
>> not setrichacl(1) and getrichacl(1)) should ultimately land in
>> man-pages (just like acl(7)), since we're talking about a kernel
>> feature. Make sense?
> 
> We could sure move acl(5) and richacl(7) there.

We already have acl(5) (now "acl(7)" in man pages) ;-).

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
