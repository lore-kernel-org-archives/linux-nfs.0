Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50138 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774AbcBHTyG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2016 14:54:06 -0500
Date: Mon, 8 Feb 2016 14:54:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: silent truncation for large file offsets
Message-ID: <20160208195403.GA18462@fieldses.org>
References: <20160208183328.GA29982@infradead.org>
 <20160208193012.GG17411@fieldses.org>
 <CAHQdGtRN16=oYbsgtf_XEpxyWpz-H8+u6j2ekckqumiHh5Yv7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRN16=oYbsgtf_XEpxyWpz-H8+u6j2ekckqumiHh5Yv7g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 08, 2016 at 02:45:54PM -0500, Trond Myklebust wrote:
> On Mon, Feb 8, 2016 at 2:30 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Mon, Feb 08, 2016 at 10:33:28AM -0800, Christoph Hellwig wrote:
> >> >From a Linux client to a Linux server (in fact the same system in this
> >> example), NFSv4.1, XFS file system:
> >>
> >> root@vm:~/xfstests# truncate --size 9223372036854775807 /mnt/nfs1/test
> >> root@vm:~/xfstests# ls -l /mnt/nfs1/test
> >> -rw-r--r-- 1 root root 9223372036854775806 Feb  8 18:30 /mnt/nfs1/test
> >> root@vm:~/xfstests# ls -l /mnt/test/test
> >> -rw-r--r-- 1 root root 9223372036854775807 Feb  8 18:30 /mnt/test/test
> >>
> >> so the file gets created with the correct size on the server, but
> >> the clients shows the size truncated.
> >>
> >> This is extraced from xfstests generic/911 which tests clone
> >> functionality and fails because of this issue.
> >
> > Took a quick look at wireshark, and GETATTR is returning the correct
> > (larger) size.
> >
> > Also FSINFO (this is v3) returns 9223372036854775807 as the maximum file
> > size.
> >
> 
> I'll bet it's this:
> 
> static inline loff_t nfs_size_to_loff_t(__u64 size)
> {
>         if (size > (__u64) OFFSET_MAX - 1)
>                 return OFFSET_MAX - 1;
>         return (loff_t) size;
> }
> 
> Should be "return OFFSET_MAX", no?

I guess so

(That's confusing, though--in general, shouldn't the maximum file size
be one *more* than the maximum offset?  But looks like st_size is
off_t, so, I guess this is just how it is.)

--b.
