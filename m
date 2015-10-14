Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:32946 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbbJNHlb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 03:41:31 -0400
Date: Wed, 14 Oct 2015 00:41:25 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: P??draig Brady <P@draigBrady.com>, Neil Brown <nfbrown@novell.com>,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
Message-ID: <20151014074125.GA2485@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <87vbai6sud.fsf@notabene.neil.brown.name>
 <5617A1E9.1080509@draigBrady.com>
 <561D68B9.8030209@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <561D68B9.8030209@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 13, 2015 at 04:25:29PM -0400, Anna Schumaker wrote:
> I haven't tried it, but I think the hole would be expanded :(.  I'm having splice() handle the pagecache copy part, and (as far as I know) splice() doesn't know anything about sparse files.  I might be able to put in some kind of fallocate() / splice() loop to copy the range in multiple pieces.
> 
> I don't want to add COPY_FR_SPARSE_AUTO, because then the kernel will have to determine how best to interpret "auto".  I'm more inclined to add a single COPY_FR_SPARSE flag to enable creating sparse files, and then have the application tell us what to do for any given range.

Teh right think is to keep sparse ranges spare as much as possible.
This would require the same sort of support as NFS READ_PLUS so I think
it's worthwhile to try it.  If the file system can't support it it won't
be sparse, so we'll get a worse quality of implementation.

But please don't add even more weird flags that just confuse users.

So far I think the only useful flag for copy_file_range is a PREALLOC
or similar flag that says the destination range should have an implicit
poix_fallocate performed on it.  And due to the complexity of
implementation I'm not even sure we need that in the first version.
