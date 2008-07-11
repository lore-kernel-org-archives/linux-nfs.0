From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: Re: Doc for adding new NFS export option
Date: Fri, 11 Jul 2008 22:32:39 +1000
Message-ID: <487752E7.3060207@cse.unsw.edu.au>
References: <48718FF4.4030200@cse.unsw.edu.au>	 <18545.47041.516146.605353@notabene.brown>	 <4874263B.50902@cse.unsw.edu.au>	 <18548.14177.493986.264761@notabene.brown>	 <48753C1A.3030402@cse.unsw.edu.au>	 <76bd70e30807091640q179617b8s749742bd2f10097d@mail.gmail.com>	 <48769E02.3020900@cse.unsw.edu.au> <76bd70e30807102131w190145d7nece35402050be860@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from note.orchestra.cse.unsw.EDU.AU ([129.94.242.24]:44347 "EHLO
	note.orchestra.cse.unsw.EDU.AU" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754971AbYGKM2n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2008 08:28:43 -0400
In-Reply-To: <76bd70e30807102131w190145d7nece35402050be860-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Thu, Jul 10, 2008 at 7:40 PM, Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org> wrote:
>> Chuck Lever wrote:
>>> On Wed, Jul 9, 2008 at 6:30 PM, Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
>>> wrote:
>>>> Neil Brown wrote:
>>>>> On Wednesday July 9, shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org wrote:
>>>>>> Neil Brown wrote:
>>>>>>> So what exactly is this new export option that you want to add?
>>>>>> As the option's name suggests, the idea is to use fallocate support in
>>>>>> ext4 and XFS, to pre-allocate disk blocks. I feel this might help nfsd
>>>>>>  sync
>>>>>> writes where each write request has to go to disk almost ASAP. Because
>>>>>> NFSv3
>>>>>> writes have to be stable(..not sure about NFSv4..), the write-to-disk
>>>>>> and
>>>>>> block allocation must happen immediately. It is possible that the
>>>>>> blocks
>>>>>> being allocated for each NFS sync write are not as contiguous as they
>>>>>> could
>>>>>> be for say, local buffered writes.
>>>>>> I am hoping that by using some form of adaptive pre-allocation we can
>>>>>> improve the contiguity of disk blocks for nfsd writes.
>>>>>>
>>>>> NFSv3 writes do not have to be stable.  The client will usually
>>>>> request DATA_UNSTABLE, and then send a COMMIT a while later.  This
>>>>> should give the filesystem time to do delayed allocation.
>>>>> NFSv4 is much the same.
>>>>> NFSv2 does require stable writes, but it should not be used by anyone
>>>>> interested in good write performance on large files.
>>>>>
>>>>> It isn't clear to me that this is something that should be an option
>>>>> in /etc/exports.
>>>> For now, I only need this option so I dont have to rebuild the kernel
>>>> each
>>>> time I want to toggle the "prealloc" option.
>>>>
>>>>> When would a sysadmin want to turn it off?  Or if a sysadmin did want
>>>>> control, sure the level of control required would be the size of the
>>>>> preallocation.
>>>> It might be a good idea to turn it off if the block allocation algorithm
>>>> slows things down when allocating large number of blocks.
>>>>
>>>> True. If needed, we should be able to add entries in /proc that control
>>>> min,
>>>> max and other limits on preallocation size.
>>> Usually options specific to a particular physical file system are
>>> handled with mount options on the server.  NFS export options are used
>>> to tune NFS-specific behavior.
>>>
>>> Couldn't you specify a mount option that enables preallocation when
>>> mounting the file system you want to export?
>> Two points here:
>> For filesystems that support preallocation,
>> a) it is already enabled through the inode->i_ops->fallocate operation while
>>
>> b) leaving the decision about the size of the pre-allocation up to the
>> caller, in this case NFS, because the caller will know best about the
>> pattern of writes it is handing to the filesystem.
>>
>> So yes, it'll need a NFS level parameter(s), be it an export option or a
>> module_param.
> 
> Oh, I see.  "do" or "don't" have NFSD use the i_op->fallocate call on
> file systems that support it.
> 
>>> I can see having a file system callback for the NFS server that
>>> provides a hint that "the client just extended this file and wrote a
>>> bunch of data -- so preallocate blocks for the data, and I will commit
>>> the data at some later point".  Most file systems would make this a
>>> no-op.
>> Ideally, something like preallocation window should become part of the VFS,
>> like read-ahead data in struct file_ra_state, by adding a relevant data
>> structure to struct file but that is too big a change at this point,
>> considering the points below.
> 
> The VFS would be the right place for local file accesses.
> 
> I think it is reasonable for NFSD to also have some specific control
> over this (apart from anything the VFS might do), for example by
> invoking the i_op itself as needed -- NFS file accesses are different
> from local accesses in subtle ways.
> 
>>> But I don't think this would help small synchronous writes... it would
>>> improve block allocation for large writes.
>>>
>> In my really simple prototype, with 64k NFS wsize and a single client
>> writing a 2Gig file over software raid0, there is no improvement in write
>> performance for XFS, and a lower throughput figure for ext4 for all
>> pre-allocation sizes ranging from 5Megs to 100Megs.
> 
> I would expect you might find differences depending on exactly when
> the pre-allocation is performed, and how much data is coming over in
> every WRITE request.  If you try a megabyte at a time and a much
> larger file, you might see greater differences.
> 

Ok. It is possible that the sweet spot for ext4 preallocation 
performance is even below 5Megs.

> Do you think it is useful to adjust your pre-allocation algorithm
> based on the characteristics of the underlying metadevices, or do the
> file systems handle that reasonably well for themselves?
> 

It will be useful for filesystems like ext[34] that do not already 
incorporate some form of volume management capabilities. For instance, 
I am not fully aware of how XFS works but looking at some recent perf 
measurements and the paper on XFS(Sweeney96) which does mention XFS 
volume manager, one can guess that it exploits knowledge of underlying 
arrangement of disks for higher performance. So in the case of XFS, I 
doubt if there is much more we can do at NFS layer without interfering 
with XFS behaviour. Thats a different story for ext[34]. The question 
here is: How do I determine if we have a single disk or multiple disks 
associated with the device nfsd is writing to?
It might be possible to make the preallocated blocks be distributed 
over multiple devices to improve parallelism.
(...I can hear shouts of, "layer violation!" at the back. :) ....)


> Would you try a pre-allocation if the client extends a file with a
> SETATTR before it pushes any data to the server?

Definitely. In fs/nfsd/vfs.c:nfsd_setattr(..), this can be 
special-cased to check if the file is getting extended and then use 
preallocation if supported by the underlying filesystem.


Thanks for other tips.
Shehjar

> 
>> The read throughput does
>> improve slightly for ext4. Havent tested reads for XFS yet.
> 
> There is a tool floating around called "seekwatcher" that can analyze
> the seek activity on your server's file system.  If you can measure a
> reduction in seek activity during reads after writing a pre-allocated
> file, I think that would be a success even if there wasn't a
> measurable performance improvement during the read.
> 
>> This is for
>> 2.6.25.10. One reason for no performance gain in XFS could be the fact that
>> the disk in these tests was newly formatted and the test file was the first
>> file created on the new filesystem so the blocks allocated in the
>> "no_prealloc" case were mostly contiguous to begin with(..although that is
>> highly simplifying it..). Perhaps running a test with multiple writer
>> clients will give more information.
> 
> You might also consider some file system aging techniques to boost the
> amount of fragmentation before running your test.  Multiple concurrent
> kernel builds, iozone runs, and keeping the size of your partition on
> the small side are some ways to increase fragmentation.
> 
>> I'll run a few more tests in the next few days, in the mean time, would
>> someone here like to take a look at the patch I have for this and provide
>> feedback?
> 
> I think it would be OK to post such a patch to the list.
> 

