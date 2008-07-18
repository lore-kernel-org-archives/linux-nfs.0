From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC][PATCH] Basic pre-allocation support for nfsd write
Date: Fri, 18 Jul 2008 10:39:42 -0400
Message-ID: <20080718143942.GE5288@fieldses.org>
References: <487D526D.8070307@cse.unsw.edu.au> <20080717151236.GB11759@fieldses.org> <487FD0AB.1000008@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34164 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854AbYGROjo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jul 2008 10:39:44 -0400
In-Reply-To: <487FD0AB.1000008-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 18, 2008 at 09:07:23AM +1000, Shehjar Tikoo wrote:
> J. Bruce Fields wrote:
>> On Wed, Jul 16, 2008 at 11:44:13AM +1000, Shehjar Tikoo wrote:
>>> Please see the attached patches for adding
>>> pre-allocation support into nfsd writes. Comments follow.
>>>
>>> Patches:
>>> a. 01_vfs_fallocate.patch
>>> Adds vfs_fallocate. Basically, encapsulates the call to
>>> inode->i_op->fallocate, which is currently called directly from
>>> sys_fallocate, which takes a file descriptor as argument, but nfsd
>>> needs to operate on struct file's.
>>>
>>> b. 02_init_file_prealloc_limit.patch
>>> Adds a new member to struct file, to keep track of how much has been
>>> preallocated for this file. For now, adding to struct file seemed an
>>> easy way to keep per-file state about preallocation but this can be
>>> changed to use a nfsd-specific hash table that maps (dev, ino) to
>>> per-file pre-allocation state.
>>>
>>> c. 03_nfsd_fallocate.patch
>>> Wires in the call to vfs_fallocate into nfsd_vfs_write.
>>> For now, the function nfsd_get_prealloc_len uses a very simple
>>> method to determine when and how much to pre-allocate. This can change
>>> if needed.
>>> This patch also adds two module_params that control pre-allocation:
>>>
>>>  1. /sys/module/nfsd/parameters/nfsd_prealloc
>>>   Determine whether to pre-allocate.
>>>
>>>  2. /sys/module/nfsd/parameters/nfsd_prealloc_len
>>>   How much to pre-allocate. Default is 5Megs.
>>
>> So, if I understand the algorithm right:
>>
>> 	- Initialize f_prealloc_len to 0.
>> 	- Ignore any write(offset, cnt) contained entirely in the range
>> 	  (0, f_prealloc_len).
>> 	- For any write outside that range, extend f_prealloc_len to
>> 	  offset + 5MB and call vfs_alloc(., ., offset, 5MB)
>>
>> (where the 5MB is actually the configurable nfsd_prealloc_len parameter
>> above).
>>
>
> Yes. However, it doesnt handle all the ways in which write requests
> can come in at the server but the aim was to test for sequential
> writes as a proof of concept first.
>
>>> The patches are based against 2.6.25.11.
>>>
>>> See the following two plots for read and write performance, with and
>>> without pre-allocation support. Tests were run using iozone. The
>>> filesystem was ext4 with extents enabled. The testbed used two Itanium
>>> machines as client and server, connected through a Gbit network with
>>> jumbo frames enabled. The filesystem was aged with various iozone and
>>> kernel compilation workloads that consumed 45G of a 64G disk.
>>>
>>> Server side mount options:
>>> rw,sync,insecure,no_root_squash,no_subtree_check,no_wdelay
>>>
>>> Client side mount options:
>>> intr,wsize=65536,rsize=65536
>>>
>>> 1. Read test
>>> http://www.gelato.unsw.edu.au/~shehjart/docs/nfsmeasurements/ext4fallocate_read.png
>>
>> Sorry, I don't understand exactly what iozone is doing in this test (and
>> the below).  Is it just doing sequential 64k reads (or, below, writes)
>> through a 2G file?
>
>
> Yes, write tests involve sequential writes with and without
> pre-allocation. The read tests read back the same file sequentially.
>
> So if we set nfsd_prealloc_len to 5Megs, then the sequential writes
> will be written to preallocated blocks of 5Megs. Once nfsd realizes
> that we've written to the previously pre-allocated block, it will
> pre-allocate another 5Mb block. The corresponding read test will be read 
> back the same file to determine the affect of
> 5Meg preallocation on  read throughput.
>
>
>>
>>> Read throughput clearly benefits due to the contiguity of disk blocks.
>>> In the best case, i.e. with pre-allocation of 4 and 5 Mb during the
>>> writing of the test file, throughput, during read of the same
>>> file, more than doubles.
>>>
>>> 2. Write test
>>> http://www.gelato.unsw.edu.au/~shehjart/docs/nfsmeasurements/ext4fallocate_write.png
>>> Going just by read performance, pre-allocation would be a nice thing
>>> to have *but* note that write throughput also decreases drastically,
>>> by almost 10 Mb/sec with just 1Mb of pre-allocation.
>>
>> So I guess it's not surprising--you're doing extra work at write time in
>> order to make the reads go faster.
>>
>
> True. With ext4 it looks like pre-allocation algorithm is not fast
> enough to help nfsd maintain the same throughput as the no  
> pre-allocation case. XFS, with its B-tree oriented approach, might
> help but this patch remains to be tested on XFS.
>
>> A general question: since this preallocation isn't already being done by
>> the filesystem, there must be some reason you think it's appropriate for
>> nfsd but not for other users.  What makes nfsd special?
>
> Nothing special about nfsd. I've been looking at NFS performance so  
> thats what I focus on with this patch. As I said in an earlier email,
> the ideal way would be to incorporate pre-allocation into VFS for
> writes which need O_SYNC. The motivation to do that is not so high
> because both ext4 and XFS now do delayed allocation for buffered
> writes.

OK, fair enough.  By the way, if you have code you want to merge at some
point, watch the style:

>>> +	if(file->f_prealloc_limit > (offset + cnt))

We normally put a space after the "if" there.

--b.
