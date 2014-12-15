Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:57376 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaLOP5M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2014 10:57:12 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so11959206pdi.30
        for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2014 07:57:11 -0800 (PST)
Date: Mon, 15 Dec 2014 07:57:07 -0800
From: Omar Sandoval <osandov@osandov.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/8] swap: don't add ITER_BVEC flag to direct_IO rw
Message-ID: <20141215155649.GB20161@mew>
References: <cover.1418618044.git.osandov@osandov.com>
 <5f9e8a7dcdf08bd2dd433f1a42690ab8e67e7915.1418618044.git.osandov@osandov.com>
 <20141215061601.GT22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141215061601.GT22149@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 15, 2014 at 06:16:02AM +0000, Al Viro wrote:
> On Sun, Dec 14, 2014 at 09:26:57PM -0800, Omar Sandoval wrote:
> > The rw argument to direct_IO has some ill-defined semantics. Some
> > filesystems (e.g., ext4, FAT) decide whether they're doing a write with
> > rw == WRITE, but others (e.g., XFS) check rw & WRITE. Let's set a good
> > example in the swap file code and say ITER_BVEC belongs in
> > iov_iter->flags but not in rw. This caters to the least common
> > denominator and avoids a sweeping change of every direct_IO
> > implementation for now.
> 
> Frankly, this is bogus.  If anything, let's just kill the first argument
> completely - ->direct_IO() can always pick it from iter->type.
> 
> As for catering to the least common denominator...  To hell with the lowest
> common denominator.  How many instances of ->direct_IO() do we have, anyway?
> 24 in the mainline (and we don't give a flying fuck for out-of-tree code, as
> a matter of policy).  Moreover, several are of "do nothing" variety.
> 
> FWIW, 'rw' is a mess.  We used to have this:
> 	READ: O_DIRECT read
> 	WRITE: O_DIRECT write
> 	KERNEL_WRITE: swapout
> 
> These days KERNEL_WRITE got replaced with ITER_BVEC | WRITE.  The thing is,
> we have a bunch of places where we explicitly checked for being _equal_ to
> WRITE.  I.e. the checks that gave a negative on swapouts.  I suspect that most
> of them are wrong and should trigger on all writes, including swapouts, but
> I really didn't want to dig into that pile of fun back then.  That's the
> main reason why 'rw' argument has survived at all...
>
In that case, I'll take a stab at nuking rw. I'm almost certain that
some of these are completely wrong (for example, of the form
if (rw == WRITE) do_write(); else do_read();). This isn't an immediate
problem for swap files on BTRFS, as __blockdev_direct_IO does a bitwise
test, so I think I'll split it out into its own series.

Thanks,
-- 
Omar
