Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932894Ab2EOS3p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 14:29:45 -0400
Date: Tue, 15 May 2012 14:29:14 -0400
From: Josef Bacik <josef@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Josef Bacik <josef@redhat.com>, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org, adilger@dilger.ca,
        tytso@mit.edu, jack@suse.cz
Subject: Re: [PATCH] ext4: fix how i_version is modified and turn it on by
 default V2
Message-ID: <20120515182914.GC1907@localhost.localdomain>
References: <1337092396-3272-1-git-send-email-josef@redhat.com>
 <20120515175308.GB1907@localhost.localdomain>
 <4FB29DAC.3020801@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4FB29DAC.3020801@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 09:17:16PM +0300, Boaz Harrosh wrote:
> On 05/15/2012 08:53 PM, Josef Bacik wrote:
> 
> > On Tue, May 15, 2012 at 10:33:16AM -0400, Josef Bacik wrote:
> >> This makes MS_I_VERSION be turned on by default.  Ext4 had been
> >> unconditionally doing i_version++ in a few cases anway so the mount option
> >> was kind of silly.  This patch also removes the update in mark_inode_dirty
> >> and makes all of the cases where we update ctime also do inode_inc_ב.
> >> file_update_time takes care of the write case and all the places where we
> >> update iversion are protected by the i_mutex so there should be no extra
> >> i_lock overhead in the normal non-exported fs case.  Thanks,
> >>
> > 
> > Ok did some basic benchmarking with dd, I ran
> > 
> > dd if=/dev/zero of=/mnt/btrfs-test/file bs=1 count=10485760
> > dd if=/dev/zero of=/mnt/btrfs-test/file bs=1M count=1000
> > dd if=/dev/zero of=/mnt/btrfs-test/file bs=1M count=5000
> > 
> > 3 times with the patch and without the patch.  With the worst case scenario
> > there is about a 40% longer run time, going from on average 12 seconds to 17
> > seconds.  
> 
> 
> do you mean that the "with the patch" is 40% slower then "without the patch"
> 	in the same "bs=1 count=10485760 test" ?
> 
> Then count me clueless. Do you understand this difference?
> 
> The way I read your patch the inode is copied and written to disk exactly the
> same number of times, as before. Only that now i_version is also updated
> together with ctime and/or mtime. What is the fundamental difference then?
> Is it just that i_version++ in-memory operation?
>

Yeah but for every write() call we have to do this in-memory operation (via
file_update_time()), so in the worst case where you are doing 1 byte writes
where you would notice this sort of overhead you get a 40% overhead just from

spin_lock(&inode->i_lock);
inode->i_version++;
spin_unlock(&inode->i_lock);

and then the subsequent mark_inode_dirty() call.  What is likely saving us here
is that the 1 byte writes are happening fast enough that the normal ctime/mtime
operations aren't triggering a mark_inode_dirty() since it appears to happen
wihtin the same time, but now that we're doing the i_version++ we are calling
mark_inode_dirty() more than before.  I'd have to profile it to verify that's
what is actually happening, but that means turning on ftrace and parsing a bunch
of output and man that sounds like more time than I want to waste on this.  The
question is do we care that the worst case is so awful since the worst case is
likely to not show up often if at all?  If we do then I guess the next step is
to add a fs flag for i_version so that people who are going to be exporting file
systems can get this without having to use a special option all the time.
Thanks,

Josef 
