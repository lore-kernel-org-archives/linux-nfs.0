Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966693Ab2EOUGE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 16:06:04 -0400
Date: Tue, 15 May 2012 16:05:34 -0400
From: Josef Bacik <josef@redhat.com>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Josef Bacik <josef@redhat.com>, Boaz Harrosh <bharrosh@panasas.com>,
        linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org, tytso@mit.edu, jack@suse.cz
Subject: Re: [PATCH] ext4: fix how i_version is modified and turn it on by
 default V2
Message-ID: <20120515200533.GD1907@localhost.localdomain>
References: <1337092396-3272-1-git-send-email-josef@redhat.com>
 <20120515175308.GB1907@localhost.localdomain>
 <4FB29DAC.3020801@panasas.com>
 <20120515182914.GC1907@localhost.localdomain>
 <AB91C817-DFEE-415F-8769-78831D72C6B7@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AB91C817-DFEE-415F-8769-78831D72C6B7@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 01:55:33PM -0600, Andreas Dilger wrote:

<snip>

> > 
> > Yeah but for every write() call we have to do this in-memory operation (via file_update_time()), so in the worst case where you are doing 1
> > byte writes where you would notice this sort of overhead you get a 40%
> > overhead just from:
> > 
> > spin_lock(&inode->i_lock);
> > inode->i_version++;
> > spin_unlock(&inode->i_lock);
> > 
> > and then the subsequent mark_inode_dirty() call.
> 
> Right.  That this is so noticeable (40% wallclock slowdown for
> filesystem IO) means that the CPU usage is higher with the
> patch than without, likely MUCH more than the 40% shown by the
> wallclock time.
> 
> > What is likely saving us here is that the 1 byte writes are happening
> > fast enough that the normal ctime/mtime operations aren't triggering
> > a mark_inode_dirty() since it appears to happen within the same time,
> > but now that we're doing the i_version++ we are calling
> > mark_inode_dirty() more than before.
> 
> Right, and hence my objection to the "basic" version of this patch
> that just turns on i_version updating for everyone.
> 

Yeah agreed, I wasn't completely convinced this would happen until I ran the
tests, and usual I was wrong.

> > I'd have to profile it to verify that's what is actually happening,
> > but that means turning on ftrace and parsing a bunch of output and
> > man that sounds like more time than I want to waste on this.  The
> > question is do we care that the worst case is so awful since the
> > worst case is likely to not show up often if at all?
> 
> Based on my experience, there are a LOT of badly written applications
> in the world, and I don't think anyone would be happy with a 40%
> slowdown, PLUS 100% CPU usage on the node while doing IO.  I would
> guess that the number of systems running badly-written applications
> far exceeds the number of systems that are doing NFS exporting, so
> I don't think this is a good tradeoff.
> 
> > If we do then I guess the next step is to add a fs flag for i_version
> > so that people who are going to be exporting file systems can get
> > this without having to use a special option all the time.
> 
> It should be fairly straight forward to have a flag set in the ext4
> superblock (s_state flag?) that indicates that the filesystem has
> been exported via NFS.  There might be other optimizations that can
> be done based on this (e.g. avoid some of the directory cookie
> hijinx that are only needed if NFS has exported the filesystem and
> needs to keep persistent cookies across reboots).
> 
> I think that the ext4_mark_inode_dirty() performance problem could
> be at least partially fixed by deferring the copy of in-core inode
> to on-disk inode to use a journal commit callback.  This is far
> more work than just setting a flag in the superblock, but it has
> the potential to _improve_ performance rather than make it worse.
> 

Yeah Btrfs doesn't have this sort of problem since we delay inode updating sinc
it is so costly, we simply let it hang around in the in-core inode until we feel
like updating it at some point down the road.  I'll put together a feature flag
or something to make it be enabled for always if somebody turns it on.  Thanks,

Josef
