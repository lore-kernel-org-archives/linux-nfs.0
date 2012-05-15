Return-Path: linux-nfs-owner@vger.kernel.org
Received: from idcmail-mo2no.shaw.ca ([64.59.134.9]:45843 "EHLO
	idcmail-mo2no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965699Ab2EOWTC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 18:19:02 -0400
Subject: Re: [PATCH] ext4: fix how i_version is modified and turn it on by default V2
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20120515210029.GA11932@fieldses.org>
Date: Tue, 15 May 2012 16:19:00 -0600
Cc: Josef Bacik <josef@redhat.com>, Boaz Harrosh <bharrosh@panasas.com>,
        linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, tytso@mit.edu,
        jack@suse.cz
Message-Id: <CC7D470A-2CF5-4F15-AEC0-461B48A641C9@dilger.ca>
References: <1337092396-3272-1-git-send-email-josef@redhat.com> <20120515175308.GB1907@localhost.localdomain> <4FB29DAC.3020801@panasas.com> <20120515182914.GC1907@localhost.localdomain> <AB91C817-DFEE-415F-8769-78831D72C6B7@dilger.ca> <20120515200533.GD1907@localhost.localdomain> <20120515210029.GA11932@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-15, at 3:00 PM, J. Bruce Fields wrote:
> On Tue, May 15, 2012 at 04:05:34PM -0400, Josef Bacik wrote:
>> On Tue, May 15, 2012 at 01:55:33PM -0600, Andreas Dilger wrote:
>>> It should be fairly straight forward to have a flag set in the ext4
>>> superblock (s_state flag?) that indicates that the filesystem has
>>> been exported via NFS.  There might be other optimizations that can
>>> be done based on this (e.g. avoid some of the directory cookie
>>> hijinx that are only needed if NFS has exported the filesystem and
>>> needs to keep persistent cookies across reboots).
>>> 
>>> I think that the ext4_mark_inode_dirty() performance problem could
>>> be at least partially fixed by deferring the copy of in-core inode
>>> to on-disk inode to use a journal commit callback.  This is far more
>>> work than just setting a flag in the superblock, but it has the
>>> potential to _improve_ performance rather than make it worse.
> 
> Could you give any more pointers for an ext4 ignoramus?  (Where *is* the
> journal commit code that would need the callback?  And where is the copy
> currently done?)

The ext4_mark_inode_dirty() starts a transaction handle, and calls
ext4_mark_iloc_dirty->ext4_do_update_inode() to do the copying and
dirtying of the block.

The JBD2 commit callback was added for OCFS2 to do the checksums of
the blocks only once, instead of for each modification.  IIRC, this
is done by a callback on struct journal_head (one per buffer_head),
but I haven't looked into all of the details.

>> Yeah Btrfs doesn't have this sort of problem since we delay inode
>> updating sinc it is so costly, we simply let it hang around in the
>> in-core inode until we feel like updating it at some point down the
>> road.  I'll put together a feature flag or something to make it be
>> enabled for always if somebody turns it on.
> 
> Thanks for looking at this.
> 
> A feature flag would be an improvement over a mount option.
> 
> If the flag makes a noticeable difference to performance, then it makes
> me nervous toggling it automatically.  And what will we do if statx
> starts returning i_version to userspace?

As mentioned in another post, all statxat() fields are optional.

Cheers, Andreas





