From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: Doc for adding new NFS export option
Date: Wed, 9 Jul 2008 19:40:40 -0400
Message-ID: <76bd70e30807091640q179617b8s749742bd2f10097d@mail.gmail.com>
References: <48718FF4.4030200@cse.unsw.edu.au>
	 <18545.47041.516146.605353@notabene.brown>
	 <4874263B.50902@cse.unsw.edu.au>
	 <18548.14177.493986.264761@notabene.brown>
	 <48753C1A.3030402@cse.unsw.edu.au>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, "Neil Brown" <neilb@suse.de>
To: "Shehjar Tikoo" <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.189]:33446 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbYGIXkm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2008 19:40:42 -0400
Received: by gv-out-0910.google.com with SMTP id e6so592403gvc.37
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jul 2008 16:40:40 -0700 (PDT)
In-Reply-To: <48753C1A.3030402-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 9, 2008 at 6:30 PM, Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org> wrote:
> Neil Brown wrote:
>>
>> On Wednesday July 9, shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org wrote:
>>>
>>> Neil Brown wrote:
>>>>
>>>> So what exactly is this new export option that you want to add?
>>>
>>> As the option's name suggests, the idea is to use fallocate support in
>>> ext4 and XFS, to pre-allocate disk blocks. I feel this might help nfsd  sync
>>> writes where each write request has to go to disk almost ASAP. Because NFSv3
>>> writes have to be stable(..not sure about NFSv4..), the write-to-disk and
>>> block allocation must happen immediately. It is possible that the blocks
>>> being allocated for each NFS sync write are not as contiguous as they could
>>> be for say, local buffered writes.
>>> I am hoping that by using some form of adaptive pre-allocation we can
>>> improve the contiguity of disk blocks for nfsd writes.
>>>
>>
>> NFSv3 writes do not have to be stable.  The client will usually
>> request DATA_UNSTABLE, and then send a COMMIT a while later.  This
>> should give the filesystem time to do delayed allocation.
>> NFSv4 is much the same.
>> NFSv2 does require stable writes, but it should not be used by anyone
>> interested in good write performance on large files.
>>
>> It isn't clear to me that this is something that should be an option
>> in /etc/exports.
>
> For now, I only need this option so I dont have to rebuild the kernel each
> time I want to toggle the "prealloc" option.
>
>> When would a sysadmin want to turn it off?  Or if a sysadmin did want
>> control, sure the level of control required would be the size of the
>> preallocation.
>
> It might be a good idea to turn it off if the block allocation algorithm
> slows things down when allocating large number of blocks.
>
> True. If needed, we should be able to add entries in /proc that control min,
> max and other limits on preallocation size.

Usually options specific to a particular physical file system are
handled with mount options on the server.  NFS export options are used
to tune NFS-specific behavior.

Couldn't you specify a mount option that enables preallocation when
mounting the file system you want to export?

I can see having a file system callback for the NFS server that
provides a hint that "the client just extended this file and wrote a
bunch of data -- so preallocate blocks for the data, and I will commit
the data at some later point".  Most file systems would make this a
no-op.

But I don't think this would help small synchronous writes... it would
improve block allocation for large writes.

-- 
Chuck Lever
