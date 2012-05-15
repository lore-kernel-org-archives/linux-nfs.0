Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49354 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966052Ab2EORdm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 13:33:42 -0400
Date: Tue, 15 May 2012 13:33:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: "Theodore Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Message-ID: <20120515173340.GA10064@fieldses.org>
References: <20120514140618.GA29902@fieldses.org>
 <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
 <20120514152334.GB29902@fieldses.org>
 <14B38D68-FAE4-444A-BCD9-7EBF7E1BBFE1@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <14B38D68-FAE4-444A-BCD9-7EBF7E1BBFE1@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 14, 2012 at 11:27:42AM -0600, Andreas Dilger wrote:
> On 2012-05-14, at 9:23 AM, J. Bruce Fields wrote:
> > On Mon, May 14, 2012 at 09:02:12AM -0600, Andreas Dilger wrote:
> >> On 2012-05-14, at 8:06, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >>> knfsd needs i_version updates on, as will userspace nfs servers and
> >>> probably others.
> >>> 
> >>> The only effects are that inode->i_version is bumped (under the i_lock)
> >>> in more places, and that ->dirty_inode(I_DIRTY_DATASYNC) may be called
> >>> more frequently than once per jiffy on write (see file_update_time).
> >>> However the latter appears to be mostly a no-op in that case.
> >> 
> >> I thought this can have noticeable performance impact, since ext4_mark_inode_dirty() is quite heavyweight?
> > 
> > There's no reason it should be, should it, if we already just dirtied
> > the inode a moment ago?
> 
> Ideally not, but the way ext[34]_mark_inode_dirty() is implemented
> is that it copies the whole in-core inode to the on-disk inode every
> time it is marked dirty.  That ensures that the on-disk inode is
> up-to-date when the journal flushes the blocks to disk, but is not
> an ideal implementation.  It has been this way since the first ext3
> implementation was done.
> 
> As a result, dirtying the inode very frequently for ext[34] is
> currently expensive and should be avoided.
> 
> I _think_ that the ext4 metadata checksum patches have changed this
> to only flag the inode dirty and run a pre-commit callback to copy
> the in-core inode to the on-disk inode.  I'm not sure what the
> current status of that patch is, nor how easily it could be split
> from that patch series and land separately.

I did some searching, found a couple of versions of the metadata
checksum patches, but no patch that looked like what you're describing.
Any idea where that is?

--b.
