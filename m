Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25853 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996Ab3HSUtG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Aug 2013 16:49:06 -0400
Date: Mon, 19 Aug 2013 16:48:57 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] vfs: allow umount to handle mountpoints without
 revalidating them
Message-ID: <20130819164857.3d6876e4@tlielax.poochiereds.net>
In-Reply-To: <20130819133503.1a793ecbfa99c1b0814bbb57@linux-foundation.org>
References: <1374834205-4406-1-git-send-email-jlayton@redhat.com>
	<20130819133503.1a793ecbfa99c1b0814bbb57@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 19 Aug 2013 13:35:03 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 26 Jul 2013 06:23:25 -0400 Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Christopher reported a regression where he was unable to unmount a NFS
> > filesystem where the root had gone stale. The problem is that
> > d_revalidate handles the root of the filesystem differently from other
> > dentries, but d_weak_revalidate does not. We could simply fix this by
> > making d_weak_revalidate return success on IS_ROOT dentries, but there
> > are cases where we do want to revalidate the root of the fs.
> > 
> > A umount is really a special case. We generally aren't interested in
> > anything but the dentry and vfsmount that's attached at that point. If
> > the inode turns out to be stale we just don't care since the intent is
> > to stop using it anyway.
> > 
> > Try to handle this situation better by treating umount as a special
> > case in the lookup code. Have it resolve the parent using normal
> > means, and then do a lookup of the final dentry without revalidating
> > it. In most cases, the final lookup will come out of the dcache, but
> > the case where there's a trailing symlink or !LAST_NORM entry on the
> > end complicates things a bit.
> > 
> 
> In which kernel version did the regression occur?  The patch *applies*
> to 3.8 and perhaps earlier, but we don't know which kernel versions
> actually need it.

v3.9 introduced the regression that I'm aware of (in commit
ecf3d1f1aa), but there have been problems with unmounting of stale
mountpoints for longer than that.

-- 
Jeff Layton <jlayton@redhat.com>
