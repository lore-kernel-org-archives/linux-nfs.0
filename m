Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:43506 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757952Ab2EOSYS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 14:24:18 -0400
Message-ID: <4FB29DAC.3020801@panasas.com>
Date: Tue, 15 May 2012 21:17:16 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Josef Bacik <josef@redhat.com>
CC: <linux-ext4@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>, <adilger@dilger.ca>, <tytso@mit.edu>,
        <jack@suse.cz>
Subject: Re: [PATCH] ext4: fix how i_version is modified and turn it on by
 default V2
References: <1337092396-3272-1-git-send-email-josef@redhat.com> <20120515175308.GB1907@localhost.localdomain>
In-Reply-To: <20120515175308.GB1907@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/15/2012 08:53 PM, Josef Bacik wrote:

> On Tue, May 15, 2012 at 10:33:16AM -0400, Josef Bacik wrote:
>> This makes MS_I_VERSION be turned on by default.  Ext4 had been
>> unconditionally doing i_version++ in a few cases anway so the mount option
>> was kind of silly.  This patch also removes the update in mark_inode_dirty
>> and makes all of the cases where we update ctime also do inode_inc_ב.
>> file_update_time takes care of the write case and all the places where we
>> update iversion are protected by the i_mutex so there should be no extra
>> i_lock overhead in the normal non-exported fs case.  Thanks,
>>
> 
> Ok did some basic benchmarking with dd, I ran
> 
> dd if=/dev/zero of=/mnt/btrfs-test/file bs=1 count=10485760
> dd if=/dev/zero of=/mnt/btrfs-test/file bs=1M count=1000
> dd if=/dev/zero of=/mnt/btrfs-test/file bs=1M count=5000
> 
> 3 times with the patch and without the patch.  With the worst case scenario
> there is about a 40% longer run time, going from on average 12 seconds to 17
> seconds.  


do you mean that the "with the patch" is 40% slower then "without the patch"
	in the same "bs=1 count=10485760 test" ?

Then count me clueless. Do you understand this difference?

The way I read your patch the inode is copied and written to disk exactly the
same number of times, as before. Only that now i_version is also updated
together with ctime and/or mtime. What is the fundamental difference then?
Is it just that i_version++ in-memory operation?

> With the other two runs they are the same runtime with the 1 megabyte
> blocks.  So the question is, do we care about this worst case since any sane
> application developer isn't going to do writes that small?  Thanks,

> Josef
Thanks
Boaz

