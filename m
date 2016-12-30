Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:34355 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751683AbcL3Ifd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Dec 2016 03:35:33 -0500
Date: Fri, 30 Dec 2016 09:35:30 +0100
From: Christoph Hellwig <hch@lst.de>
To: Bruce James Fields <bfields@fieldses.org>
Cc: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [nfsv4] RFC 7530: Filehandle of opened file after the REMOVE
Message-ID: <20161230083530.GA26413@lst.de>
References: <20161213181734.Horde.EqgB09El8rupnkesIQaBwJ3@mail.telka.sk> <CADaq8jcq2C0o8EWXoGjxDn58sV_J+-SP-=rj934Se-DV69b-pw@mail.gmail.com> <20161214112112.Horde.aPh8AjT6iWRl37CULwihyV7@mail.telka.sk> <CAABAsM7v6y0bsb0jKzfvobkUjniTLhM3uv8FYjo07HcLD2004w@mail.gmail.com> <20161227144414.GA32002@fieldses.org> <CADaq8jck14SKL6Ua9QxbqPyX1=1aaA7+76wv-__EWFvh7ZcEJA@mail.gmail.com> <C496AE44-0F27-4B66-A1F6-A76AEAFD7A90@gmail.com> <20161229024703.GA21325@fieldses.org> <20161229074830.GA3002@lst.de> <20161229205426.GA389@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161229205426.GA389@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 29, 2016 at 03:54:26PM -0500, Bruce James Fields wrote:
> I assume this would need userspace updates too, so fsck would know not
> to free the unlinked files, and so administrators could see what was
> going on and maybe free them manually if need be.

At least for XFS that's not a worry - if the file system is so toast
that you run xfs_repair NFS exports getting back are the least of your
worries.

Note that these open but unlinked files already happen all the time during
normal operation, they only interesting aspect that NFS would add is that
we might have to reclaim them later when NFS is involved.

> It may seem like overkill, but we have (mostly complete) support for
> running multiple nfsd's in containers, which can be started and stopped
> independently.  And we may want to allow a single filesystem to be
> exported by more than one such nfsd. I think we can still manage that
> with a single unlinked inode list, though--we'd just need logic in nfsd
> to delay freeing as long as any nfsd is restarting.

I'd really want to avoid that logic in the fs.  What I can trivially
offer you from the fs is to:

 1) offer a mount option not to reclaim the unlinked inode list
 2) offer an interface (e.g. in super_operations or export_ops)
    to reclaim the unlinked inodes for a fs mounted with that option

and NFSD would have call the second options.  But I'd like to keep
it out of the fs when that is called exactly.

Note that the filesystem still is in a perfectly fine (although a little
odd) state before we reclaim the unlinked inodes - from the on disk
POV it is not different from a currently active but unlinked file,
the only difference is that we won't ever get a final unlink for it
and only a manual reclaim free them.

The only somewhat hard thing about implementing this on the fs side
is to come up with a scheme to distinguish between old unlinked inodes
left over from before a crash, and new ones created after it that are
active.  But that's something a simple inode flag should be able to
solve.
