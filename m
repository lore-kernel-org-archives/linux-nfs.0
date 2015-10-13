Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56654 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbbJMH1t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 03:27:49 -0400
Date: Tue, 13 Oct 2015 00:27:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, mtk.manpages@gmail.com, andros@netapp.com
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
Message-ID: <20151013072737.GA10794@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org>
 <20151012231749.GC11398@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151012231749.GC11398@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 12, 2015 at 04:17:49PM -0700, Darrick J. Wong wrote:
> Hm.  Peng's patches only generalize the CLONE and CLONE_RANGE ioctls from
> btrfs, however they don't port over the (vastly different) EXTENT_SAME ioctl.
> 
> What does everyone think about generalizing EXTENT_SAME?  The interface enables
> one to ask the kernel to dedupe multiple file ranges in a single call.  That's
> more complex than what I was proposing with COPY_FR_DEDUP(E), but I'm assuming
> that the extra complexity buys us the ability to ... multi-dedupe at the same
> time, with locks held on the source file?
> 
> I'm happy to generalize the existing EXTENT_SAME, but please yell if you really
> hate the interface.

It's not pretty, but if the btrfs folks have a good reason for it I
don't see a reason to diverge.
