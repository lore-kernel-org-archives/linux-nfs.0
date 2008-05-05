From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Ensure that 'noac' and/or 'actimeo=0' turn off attribute caching
Date: Mon, 5 May 2008 11:55:32 -0400
Message-ID: <95989F05-2BCE-4923-94C6-46D46270D120@oracle.com>
References: <20080502202502.29449.81285.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <6A5A94A9-6F7A-469C-926D-A39B18381FFE@oracle.com> <1210001033.7409.1.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:17488 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314AbYEEP4H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2008 11:56:07 -0400
In-Reply-To: <1210001033.7409.1.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 5, 2008, at 11:23 AM, Trond Myklebust wrote:
> On Mon, 2008-05-05 at 11:02 -0400, Chuck Lever wrote:
>> Hi Trond-
>>
>> On May 2, 2008, at 4:25 PM, Trond Myklebust wrote:
>>> Both the 'noac' and 'actimeo=0' mount options should ensure that
>>> attributes
>>> are not cached, however a bug in nfs_attribute_timeout() means that
>>> currently, the attributes may in fact get cached for up to one
>>> jiffy. This
>>> has been seen to cause corruption in some applications.
>>>
>>> The reason for the bug is that the time_in_range() test returns
>>> 'true' as
>>> long as the current time lies between nfsi->read_cache_jiffies and
>>> nfsi->read_cache_jiffies + nfsi->attrtimeo. In other words, if  
>>> jiffies
>>> equals nfsi->read_cache_jiffies, then we still cache the attribute
>>> data.
>>>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> ---
>>>
>>> fs/nfs/inode.c |    7 +++++++
>>> 1 files changed, 7 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>> index 5cb3345..38f06d3 100644
>>> --- a/fs/nfs/inode.c
>>> +++ b/fs/nfs/inode.c
>>> @@ -707,6 +707,13 @@ int nfs_attribute_timeout(struct inode *inode)
>>>
>>> 	if (nfs_have_delegation(inode, FMODE_READ))
>>> 		return 0;
>>> +	/*
>>> +	 * Special case: if the attribute timeout is set to 0, then we
>>> +	 * 		 treat the cache as having expired (unless we
>>> +	 * 		 have a delegation).
>>> +	 */
>>> +	if (nfsi->attrtimeo == 0)
>>> +		return 1;
>>> 	return !time_in_range(jiffies, nfsi->read_cache_jiffies, nfsi-
>>>> read_cache_jiffies + nfsi->attrtimeo);
>>> }
>>
>> Do nfs_access_get_cached() and nfs_update_inode() have the same  
>> issue?
>
> nfs_access_get_cached() probably has the same issue, but I can't see  
> how
> nfs_update_inode() would. Could you explain?


nfs_update_inode() is the only other place that actually uses the  
value of nfsi->attrtimeo (and it uses it with time_in_range).  I'm  
merely asking if we have verified that the behavior is correct if nfsi- 
 >attrtimeo == 0.

The logic there is abstruse, so it's difficult to tell if the (nfsi- 
 >attrtimeo == 0) case is behaving as expected.  I don't see any  
obvious problem with it right now.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
