Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43681 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966836Ab2EOVIs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 17:08:48 -0400
Date: Tue, 15 May 2012 17:08:15 -0400
From: Josef Bacik <josef@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Josef Bacik <josef@redhat.com>, Andreas Dilger <adilger@dilger.ca>,
        Boaz Harrosh <bharrosh@panasas.com>, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, tytso@mit.edu, jack@suse.cz
Subject: Re: [PATCH] ext4: fix how i_version is modified and turn it on by
 default V2
Message-ID: <20120515210815.GE1907@localhost.localdomain>
References: <1337092396-3272-1-git-send-email-josef@redhat.com>
 <20120515175308.GB1907@localhost.localdomain>
 <4FB29DAC.3020801@panasas.com>
 <20120515182914.GC1907@localhost.localdomain>
 <AB91C817-DFEE-415F-8769-78831D72C6B7@dilger.ca>
 <20120515200533.GD1907@localhost.localdomain>
 <20120515210029.GA11932@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120515210029.GA11932@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 05:00:29PM -0400, J. Bruce Fields wrote:
> On Tue, May 15, 2012 at 04:05:34PM -0400, Josef Bacik wrote:
> > On Tue, May 15, 2012 at 01:55:33PM -0600, Andreas Dilger wrote:
> > > It should be fairly straight forward to have a flag set in the ext4
> > > superblock (s_state flag?) that indicates that the filesystem has
> > > been exported via NFS.  There might be other optimizations that can
> > > be done based on this (e.g. avoid some of the directory cookie
> > > hijinx that are only needed if NFS has exported the filesystem and
> > > needs to keep persistent cookies across reboots).
> > > 
> > > I think that the ext4_mark_inode_dirty() performance problem could
> > > be at least partially fixed by deferring the copy of in-core inode
> > > to on-disk inode to use a journal commit callback.  This is far more
> > > work than just setting a flag in the superblock, but it has the
> > > potential to _improve_ performance rather than make it worse.
> 
> Could you give any more pointers for an ext4 ignoramus?  (Where *is* the
> journal commit code that would need the callback?  And where is the copy
> currently done?)
> 

The copy is currently done in mark_inode_dirty(), I'm looking into what would
need to be done to get the inodes to update the on disk stuff on journal commit
only, but I worry that will make commits take way longer than normal and cause
other issues.

> > Yeah Btrfs doesn't have this sort of problem since we delay inode
> > updating sinc it is so costly, we simply let it hang around in the
> > in-core inode until we feel like updating it at some point down the
> > road.  I'll put together a feature flag or something to make it be
> > enabled for always if somebody turns it on.
> 
> Thanks for looking at this.
> 
> A feature flag would be an improvement over a mount option.
> 
> If the flag makes a noticeable difference to performance, then it makes
> me nervous toggling it automatically.  And what will we do if statx
> starts returning i_version to userspace?
> 

Well statx can return flags right?  I'm sure we could just have a flag that says
"hey iversion is completely useless."  Thanks,

Josef
