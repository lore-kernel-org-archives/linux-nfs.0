Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:52231 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932277Ab2EOUba (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 16:31:30 -0400
Message-ID: <4FB2BB90.30900@panasas.com>
Date: Tue, 15 May 2012 23:24:48 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Josef Bacik <josef@redhat.com>
CC: <linux-ext4@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>, <adilger@dilger.ca>, <tytso@mit.edu>,
        <jack@suse.cz>
Subject: Re: [PATCH] ext4: fix how i_version is modified and turn it on by
 default V2
References: <1337092396-3272-1-git-send-email-josef@redhat.com> <20120515175308.GB1907@localhost.localdomain> <4FB29DAC.3020801@panasas.com> <20120515182914.GC1907@localhost.localdomain>
In-Reply-To: <20120515182914.GC1907@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/15/2012 09:29 PM, Josef Bacik wrote:

> On Tue, May 15, 2012 at 09:17:16PM +0300, Boaz Harrosh wrote:

<snip>

>>
>> do you mean that the "with the patch" is 40% slower then "without the patch"
>> 	in the same "bs=1 count=10485760 test" ?
>>
>> Then count me clueless. Do you understand this difference?
>>
>> The way I read your patch the inode is copied and written to disk exactly the
>> same number of times, as before. Only that now i_version is also updated
>> together with ctime and/or mtime. What is the fundamental difference then?
>> Is it just that i_version++ in-memory operation?
>>
> 
> Yeah but for every write() call we have to do this in-memory operation (via
> file_update_time()), so in the worst case where you are doing 1 byte writes
> where you would notice this sort of overhead you get a 40% overhead just from
> 
> spin_lock(&inode->i_lock);
> inode->i_version++;
> spin_unlock(&inode->i_lock);
> 


We should be optimizing this we can take the spin_lock once and change
the i_version and ctime/mtime at the same locking cycle.

> and then the subsequent mark_inode_dirty() call.  What is likely saving us here
> is that the 1 byte writes are happening fast enough that the normal ctime/mtime
> operations aren't triggering a mark_inode_dirty() since it appears to happen
> wihtin the same time, 


Ha, OK that Jiffy resolution of ctime. Hence the core problem BTW, changes come
in and we can't differentiate them.

So you are saying that there is somewhere in code that does
if (old_ctime != cur_ctime)
	mark_inode_dirty()

Isn't the mark_inode_dirty() called every-time regardless of the value set
at ctime ?

> but now that we're doing the i_version++ we are calling
> mark_inode_dirty() more than before.  


Can we fix that. Can we mark the inode dirty at Jiffy resolution?

In the case of a Server crash the nfs_changed attr is expected to reset
back to old value until such time that some client did a COMMIT. Up to
COMMIT it might happen that on disk version is older than runtime.

But the Jiffy resolution is a real bummer believe me.

> I'd have to profile it to verify that's
> what is actually happening, but that means turning on ftrace and parsing a bunch
> of output and man that sounds like more time than I want to waste on this.  The
> question is do we care that the worst case is so awful since the worst case is
> likely to not show up often if at all?  If we do then I guess the next step is
> to add a fs flag for i_version so that people who are going to be exporting file
> systems can get this without having to use a special option all the time.
> Thanks,
> 


Lets just think about it a bit, Can we make it that disk updates happen just
as often as today and no more. But in memory inquiry of i_version gives us
a much higher resolution.

What about that Al's proposal of incrementing only after an NFSD inquiry

> Josef 


Thanks for looking into this. We all hate this for a long time but never
took the time to fix it.

Boaz
