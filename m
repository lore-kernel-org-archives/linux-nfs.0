Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e31.co.us.ibm.com ([32.97.110.149]:34189 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932419Ab2EOSwv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 14:52:51 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <djwong@us.ibm.com>;
	Tue, 15 May 2012 12:52:46 -0600
Date: Tue, 15 May 2012 11:50:37 -0700
From: djwong <djwong@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Dilger <adilger@dilger.ca>, "Theodore Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Message-ID: <20120515185037.GG6938@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
References: <20120514140618.GA29902@fieldses.org>
 <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
 <20120514152334.GB29902@fieldses.org>
 <14B38D68-FAE4-444A-BCD9-7EBF7E1BBFE1@dilger.ca>
 <20120515173340.GA10064@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120515173340.GA10064@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 01:33:40PM -0400, J. Bruce Fields wrote:
> On Mon, May 14, 2012 at 11:27:42AM -0600, Andreas Dilger wrote:
> > On 2012-05-14, at 9:23 AM, J. Bruce Fields wrote:
> > > On Mon, May 14, 2012 at 09:02:12AM -0600, Andreas Dilger wrote:
> > >> On 2012-05-14, at 8:06, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > >>> knfsd needs i_version updates on, as will userspace nfs servers and
> > >>> probably others.
> > >>> 
> > >>> The only effects are that inode->i_version is bumped (under the i_lock)
> > >>> in more places, and that ->dirty_inode(I_DIRTY_DATASYNC) may be called
> > >>> more frequently than once per jiffy on write (see file_update_time).
> > >>> However the latter appears to be mostly a no-op in that case.
> > >> 
> > >> I thought this can have noticeable performance impact, since ext4_mark_inode_dirty() is quite heavyweight?
> > > 
> > > There's no reason it should be, should it, if we already just dirtied
> > > the inode a moment ago?
> > 
> > Ideally not, but the way ext[34]_mark_inode_dirty() is implemented
> > is that it copies the whole in-core inode to the on-disk inode every
> > time it is marked dirty.  That ensures that the on-disk inode is
> > up-to-date when the journal flushes the blocks to disk, but is not
> > an ideal implementation.  It has been this way since the first ext3
> > implementation was done.
> > 
> > As a result, dirtying the inode very frequently for ext[34] is
> > currently expensive and should be avoided.
> > 
> > I _think_ that the ext4 metadata checksum patches have changed this
> > to only flag the inode dirty and run a pre-commit callback to copy
> > the in-core inode to the on-disk inode.  I'm not sure what the
> > current status of that patch is, nor how easily it could be split
> > from that patch series and land separately.
> 
> I did some searching, found a couple of versions of the metadata
> checksum patches, but no patch that looked like what you're describing.
> Any idea where that is?

That _was_ going to be the basis of phase 2 of my metadata checksum patchset,
but since I've been moved to other projects, I don't see that on my plate in
the near future. :/

(tldr: It doesn't exist.)

--D
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

