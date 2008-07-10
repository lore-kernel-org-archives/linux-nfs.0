From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: Re: Doc for adding new NFS export option
Date: Fri, 11 Jul 2008 09:40:50 +1000
Message-ID: <48769E02.3020900@cse.unsw.edu.au>
References: <48718FF4.4030200@cse.unsw.edu.au>	 <18545.47041.516146.605353@notabene.brown>	 <4874263B.50902@cse.unsw.edu.au>	 <18548.14177.493986.264761@notabene.brown>	 <48753C1A.3030402@cse.unsw.edu.au> <76bd70e30807091640q179617b8s749742bd2f10097d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tone.orchestra.cse.unsw.EDU.AU ([129.94.242.59]:48005 "EHLO
	tone.orchestra.cse.unsw.EDU.AU" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755224AbYGJXzd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 19:55:33 -0400
In-Reply-To: <76bd70e30807091640q179617b8s749742bd2f10097d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Wed, Jul 9, 2008 at 6:30 PM, Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org> wrote:
>> Neil Brown wrote:
>>> On Wednesday July 9, shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org wrote:
>>>> Neil Brown wrote:
>>>>> So what exactly is this new export option that you want to add?
>>>> As the option's name suggests, the idea is to use fallocate support in
>>>> ext4 and XFS, to pre-allocate disk blocks. I feel this might help nfsd  sync
>>>> writes where each write request has to go to disk almost ASAP. Because NFSv3
>>>> writes have to be stable(..not sure about NFSv4..), the write-to-disk and
>>>> block allocation must happen immediately. It is possible that the blocks
>>>> being allocated for each NFS sync write are not as contiguous as they could
>>>> be for say, local buffered writes.
>>>> I am hoping that by using some form of adaptive pre-allocation we can
>>>> improve the contiguity of disk blocks for nfsd writes.
>>>>
>>> NFSv3 writes do not have to be stable.  The client will usually
>>> request DATA_UNSTABLE, and then send a COMMIT a while later.  This
>>> should give the filesystem time to do delayed allocation.
>>> NFSv4 is much the same.
>>> NFSv2 does require stable writes, but it should not be used by anyone
>>> interested in good write performance on large files.
>>>
>>> It isn't clear to me that this is something that should be an option
>>> in /etc/exports.
>> For now, I only need this option so I dont have to rebuild the kernel each
>> time I want to toggle the "prealloc" option.
>>
>>> When would a sysadmin want to turn it off?  Or if a sysadmin did want
>>> control, sure the level of control required would be the size of the
>>> preallocation.
>> It might be a good idea to turn it off if the block allocation algorithm
>> slows things down when allocating large number of blocks.
>>
>> True. If needed, we should be able to add entries in /proc that control min,
>> max and other limits on preallocation size.
> 
> Usually options specific to a particular physical file system are
> handled with mount options on the server.  NFS export options are used
> to tune NFS-specific behavior.
> 
> Couldn't you specify a mount option that enables preallocation when
> mounting the file system you want to export?

Two points here:
For filesystems that support preallocation,
a) it is already enabled through the inode->i_ops->fallocate operation 
while

b) leaving the decision about the size of the pre-allocation up to the 
caller, in this case NFS, because the caller will know best about the 
pattern of writes it is handing to the filesystem.

So yes, it'll need a NFS level parameter(s), be it an export option or 
a module_param.
> 
> I can see having a file system callback for the NFS server that
> provides a hint that "the client just extended this file and wrote a
> bunch of data -- so preallocate blocks for the data, and I will commit
> the data at some later point".  Most file systems would make this a
> no-op.

Ideally, something like preallocation window should become part of the 
VFS, like read-ahead data in struct file_ra_state, by adding a 
relevant data structure to struct file but that is too big a change at 
this point, considering the points below.

> 
> But I don't think this would help small synchronous writes... it would
> improve block allocation for large writes.
> 

In my really simple prototype, with 64k NFS wsize and a single client 
writing a 2Gig file over software raid0, there is no improvement in 
write performance for XFS, and a lower throughput figure for ext4 for 
all pre-allocation sizes ranging from 5Megs to 100Megs. The read 
throughput does improve slightly for ext4. Havent tested reads for XFS 
yet. This is for 2.6.25.10. One reason for no performance gain in XFS 
could be the fact that the disk in these tests was newly formatted and 
the test file was the first file created on the new filesystem so the 
blocks allocated in the "no_prealloc" case were mostly contiguous to 
begin with(..although that is highly simplifying it..). Perhaps 
running a test with multiple writer clients will give more 
information. Regarding ext4, I have no idea yet as to why throughput 
reduces on using pre-allocation, that too on a fresh filesystem.

I'll run a few more tests in the next few days, in the mean time, 
would someone here like to take a look at the patch I have for this 
and provide feedback?

Thanks
Shehjar
