Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:26693 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027AbZD3VN3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 17:13:29 -0400
Cc: Brian R Cowan <brcowan@us.ibm.com>, linux-nfs@vger.kernel.org
Message-Id: <E3E36E6E-1BE2-4C6D-9CDB-C85B9AF06999@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <49FA0CE8.9090706@redhat.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Thu, 30 Apr 2009 17:13:01 -0400
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com> <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com> <49FA0CE8.9090706@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 30, 2009, at 4:41 PM, Peter Staubach wrote:

> Chuck Lever wrote:
>>
>> On Apr 30, 2009, at 4:12 PM, Brian R Cowan wrote:
>>
>>> Hello all,
>>>
>>> This is my first post, so please be gentle.... I have been working
>>> with a
>>> customer who is attempting to build their product in ClearCase  
>>> dynamic
>>> views on Linux. When they went from Red hat Enterprise Linux 4
>>> (update 5)
>>> to Red Hat Enterprise Linux 5 (Update 2), their build performance
>>> degraded
>>> dramatically. When troubleshooting the issue, we noticed that  
>>> links on
>>> RHEL 5 caused an incredible number of "STABLE" 4kb nfs writes even
>>> though
>>> the storage we were writing to was EXPLICITLY mounted async. (This  
>>> made
>>> RHEL 5 nearly 5x slower than RHEL 4.5 in this area...)
>>>
>>> On consultation with some internal resources, we found this change  
>>> in
>>> the
>>> 2.6 kernel:
>>>
>>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=ab0a3dbedc51037f3d2e22ef67717a987b3d15e2
>>>
>>>
>>> In here it looks like the NFS client is forcing sync writes any  
>>> time a
>>> write of less than the NFS write size occurs. We tested this
>>> hypothesis by
>>> setting the write size to 2KB. The "STABLE" writes went away and  
>>> link
>>> times came back down out of the stratosphere. We built a modified  
>>> kernel
>>> based on the RHEL 5.2 kernel (that ONLY backed out of this change)
>>> and we
>>> got a 33% improvement in overall build speeds. In my case, I see  
>>> almost
>>> identical build times between the 2 OS's when we use this modified
>>> kernel
>>> on RHEL 5.
>>>
>>> Now, why am I posing this to the list? I need to understand *why*  
>>> that
>>> change was made. On the face of it, simply backing out that patch
>>> would be
>>> perfect. I'm paranoid. I want to make sure that this is the ONLY  
>>> reason:
>>> "/* For single writes, FLUSH_STABLE is more efficient */ "
>>>
>>> It seems more accurate to say that they *aren't* more efficient, but
>>> rather are "safer, but slower."
>>
>> They are more efficient from the point of view that only a single RPC
>> is needed for a complete write.  The WRITE and COMMIT are done in a
>> single request.
>>
>> I don't think the issue here is whether the write is stable, but it  
>> is
>> whether the NFS client has to block the application for it.  A stable
>> write that is asynchronous to the application is faster than
>> WRITE+COMMIT.
>>
>> So it's not "stable" that is holding you up, it's "synchronous."
>> Those are orthogonal concepts.
>>
>
> Actually, the "stable" part can be a killer.  It depends upon
> why and when nfs_flush_inode() is invoked.
>
> I did quite a bit of work on this aspect of RHEL-5 and discovered
> that this particular code was leading to some serious slowdowns.
> The server would end up doing a very slow FILE_SYNC write when
> all that was really required was an UNSTABLE write at the time.

If the client is asking for FILE_SYNC when it doesn't need the COMMIT,  
then yes, that would hurt performance.

> Did anyone actually measure this optimization and if so, what
> were the numbers?
>
>    Thanx...
>
>       ps

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
