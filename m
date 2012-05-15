Return-Path: linux-nfs-owner@vger.kernel.org
Received: from idcmail-mo2no.shaw.ca ([64.59.134.9]:58037 "EHLO
	idcmail-mo2no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965427Ab2EOTzf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 15:55:35 -0400
Subject: Re: [PATCH] ext4: fix how i_version is modified and turn it on by default V2
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20120515182914.GC1907@localhost.localdomain>
Date: Tue, 15 May 2012 13:55:33 -0600
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org, tytso@mit.edu,
        jack@suse.cz
Message-Id: <AB91C817-DFEE-415F-8769-78831D72C6B7@dilger.ca>
References: <1337092396-3272-1-git-send-email-josef@redhat.com> <20120515175308.GB1907@localhost.localdomain> <4FB29DAC.3020801@panasas.com> <20120515182914.GC1907@localhost.localdomain>
To: Josef Bacik <josef@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-15, at 12:29 PM, Josef Bacik wrote:
> On Tue, May 15, 2012 at 09:17:16PM +0300, Boaz Harrosh wrote:
>> On 05/15/2012 08:53 PM, Josef Bacik wrote:
>>> On Tue, May 15, 2012 at 10:33:16AM -0400, Josef Bacik wrote:
>>>> This makes MS_I_VERSION be turned on by default.  Ext4 had been
>>>> unconditionally doing i_version++ in a few cases anway so the
>>>> mount option was kind of silly.  This patch also removes the
>>>> update in mark_inode_dirty and makes all of the cases where we
>>>> update ctime also do inode_inc_version.  file_update_time takes
>>>> care of the write case and all the places where we update
>>>> iversion are protected by the i_mutex so there should be no
>>>> extra i_lock overhead in the normal non-exported fs case.
>>> 
>>> Ok did some basic benchmarking with dd, I ran
>>> 
>>> dd if=/dev/zero of=/mnt/btrfs-test/file bs=1 count=10485760
>>> dd if=/dev/zero of=/mnt/btrfs-test/file bs=1M count=1000
>>> dd if=/dev/zero of=/mnt/btrfs-test/file bs=1M count=5000
>>> 
>>> 3 times with the patch and without the patch.  With the worst case
>>> scenario there is about a 40% longer run time, going from on average
>>> 12 seconds to 17 seconds.  With the other two runs they are the same
>>> runtime with the 1 megabyte blocks.

Josef,
thanks for running these tests.  This confirms that the problem
which has existed in the past with ext[34]_mark_inode_dirty()
still exists today, and for btrfs as well.

>> do you mean that the "with the patch" is 40% slower then "without the patch" in the same "bs=1 count=10485760 test" ?
>> 
>> Then count me clueless. Do you understand this difference?
>> 
>> The way I read your patch the inode is copied and written to disk
>> exactly the same number of times, as before. Only that now
>> i_version is also updated together with ctime and/or mtime. What
>> is the fundamental difference then?
>> Is it just that i_version++ in-memory operation?
> 
> Yeah but for every write() call we have to do this in-memory operation (via file_update_time()), so in the worst case where you are doing 1
> byte writes where you would notice this sort of overhead you get a 40%
> overhead just from:
> 
> spin_lock(&inode->i_lock);
> inode->i_version++;
> spin_unlock(&inode->i_lock);
> 
> and then the subsequent mark_inode_dirty() call.

Right.  That this is so noticeable (40% wallclock slowdown for
filesystem IO) means that the CPU usage is higher with the
patch than without, likely MUCH more than the 40% shown by the
wallclock time.

> What is likely saving us here is that the 1 byte writes are happening
> fast enough that the normal ctime/mtime operations aren't triggering
> a mark_inode_dirty() since it appears to happen within the same time,
> but now that we're doing the i_version++ we are calling
> mark_inode_dirty() more than before.

Right, and hence my objection to the "basic" version of this patch
that just turns on i_version updating for everyone.

> I'd have to profile it to verify that's what is actually happening,
> but that means turning on ftrace and parsing a bunch of output and
> man that sounds like more time than I want to waste on this.  The
> question is do we care that the worst case is so awful since the
> worst case is likely to not show up often if at all?

Based on my experience, there are a LOT of badly written applications
in the world, and I don't think anyone would be happy with a 40%
slowdown, PLUS 100% CPU usage on the node while doing IO.  I would
guess that the number of systems running badly-written applications
far exceeds the number of systems that are doing NFS exporting, so
I don't think this is a good tradeoff.

> If we do then I guess the next step is to add a fs flag for i_version
> so that people who are going to be exporting file systems can get
> this without having to use a special option all the time.

It should be fairly straight forward to have a flag set in the ext4
superblock (s_state flag?) that indicates that the filesystem has
been exported via NFS.  There might be other optimizations that can
be done based on this (e.g. avoid some of the directory cookie
hijinx that are only needed if NFS has exported the filesystem and
needs to keep persistent cookies across reboots).

I think that the ext4_mark_inode_dirty() performance problem could
be at least partially fixed by deferring the copy of in-core inode
to on-disk inode to use a journal commit callback.  This is far
more work than just setting a flag in the superblock, but it has
the potential to _improve_ performance rather than make it worse.

Cheers, Andreas





