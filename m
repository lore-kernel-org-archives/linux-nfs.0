From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: Re: Doc for adding new NFS export option
Date: Thu, 10 Jul 2008 08:30:50 +1000
Message-ID: <48753C1A.3030402@cse.unsw.edu.au>
References: <48718FF4.4030200@cse.unsw.edu.au>	<18545.47041.516146.605353@notabene.brown>	<4874263B.50902@cse.unsw.edu.au> <18548.14177.493986.264761@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@suse.de>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from note.orchestra.cse.unsw.EDU.AU ([129.94.242.24]:58386 "EHLO
	note.orchestra.cse.unsw.EDU.AU" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751801AbYGIWo5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2008 18:44:57 -0400
In-Reply-To: <18548.14177.493986.264761-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> On Wednesday July 9, shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org wrote:
>> Neil Brown wrote:
>>> So what exactly is this new export option that you want to add?
>> As the option's name suggests, the idea is to use fallocate support in 
>> ext4 and XFS, to pre-allocate disk blocks. I feel this might help nfsd 
>>   sync writes where each write request has to go to disk almost ASAP. 
>> Because NFSv3 writes have to be stable(..not sure about NFSv4..), the 
>> write-to-disk and block allocation must happen immediately. It is 
>> possible that the blocks being allocated for each NFS sync write are 
>> not as contiguous as they could be for say, local buffered writes.
>> I am hoping that by using some form of adaptive pre-allocation we can 
>> improve the contiguity of disk blocks for nfsd writes.
>>
> 
> NFSv3 writes do not have to be stable.  The client will usually
> request DATA_UNSTABLE, and then send a COMMIT a while later.  This
> should give the filesystem time to do delayed allocation.
> NFSv4 is much the same.
> NFSv2 does require stable writes, but it should not be used by anyone
> interested in good write performance on large files.
> 
> It isn't clear to me that this is something that should be an option
> in /etc/exports.

For now, I only need this option so I dont have to rebuild the kernel 
each time I want to toggle the "prealloc" option.

> When would a sysadmin want to turn it off?  Or if a sysadmin did want
> control, sure the level of control required would be the size of the
> preallocation. 

It might be a good idea to turn it off if the block allocation 
algorithm slows things down when allocating large number of blocks.

True. If needed, we should be able to add entries in /proc that 
control min, max and other limits on preallocation size.

> I would strongly suggest demonstrating that you can improve some
> measure of performance using preallocation before you even begin to
> think about having an export option to select it.

Agreed. I'll have some measurements soon after I have something working.

Thanks
Shehjar
