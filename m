Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49186 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbbKJGZF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2015 01:25:05 -0500
Date: Mon, 9 Nov 2015 22:24:28 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, mtk.manpages@gmail.com, andros@netapp.com
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
Message-ID: <20151110062428.GF3255@birch.djwong.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org>
 <20151012231749.GC11398@birch.djwong.org>
 <20151013072737.GA10794@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151013072737.GA10794@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 13, 2015 at 12:27:37AM -0700, Christoph Hellwig wrote:
> On Mon, Oct 12, 2015 at 04:17:49PM -0700, Darrick J. Wong wrote:
> > Hm.  Peng's patches only generalize the CLONE and CLONE_RANGE ioctls from
> > btrfs, however they don't port over the (vastly different) EXTENT_SAME ioctl.
> > 
> > What does everyone think about generalizing EXTENT_SAME?  The interface enables
> > one to ask the kernel to dedupe multiple file ranges in a single call.  That's
> > more complex than what I was proposing with COPY_FR_DEDUP(E), but I'm assuming
> > that the extra complexity buys us the ability to ... multi-dedupe at the same
> > time, with locks held on the source file?
> > 
> > I'm happy to generalize the existing EXTENT_SAME, but please yell if you really
> > hate the interface.
> 
> It's not pretty, but if the btrfs folks have a good reason for it I
> don't see a reason to diverge.

I started hoisting EXTENT_SAME into the VFS but I don't like the name because
this ioctl implies some sort of action, but "EXTENT SAME" lacks a verb.  Since
we have to introduce a new symbol anyway, I'm going to use FS_DEDUPE_RANGE.

struct file_dedupe_range {
	...
}

#define FI_DEDUPE_RANGE         _IOWR(0x94, 54, struct file_dedupe_range)

(Honestly, I'm not in love with FICLONERANGE either, but FIDEDUPRANGE was just
unpronounceable mess.)

Also, for the btrfs folks: Why does extent_same call mnt_want_write_file on the
fd that we pass into the ioctl?  Shouldn't we be calling it on the fd that's in
the btrfs_ioctl_extent_same_info structure because that'ss the file that gets
its blocks remapped?

--D
