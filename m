From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 07/33] NFS: Ensure that rpc_run_task() errors are propagated back to the caller
Date: Tue, 22 Apr 2008 10:19:37 -0400
Message-ID: <92201A7C-4650-450E-ABF2-EF699B208647@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204048.14124.4335.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <BE4F0130-A492-4229-83E4-E7C912B0ABF0@oracle.com> <1208823472.7767.40.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:42025 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbYDVOVA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2008 10:21:00 -0400
In-Reply-To: <1208823472.7767.40.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 21, 2008, at 8:17 PM, Trond Myklebust wrote:
> On Mon, 2008-04-21 at 15:55 -0400, Chuck Lever wrote:
>> Hi Trond-
>>
>> On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> ---
>>>
>>> fs/nfs/direct.c |   10 ++++++----
>>> fs/nfs/read.c   |   23 +++++++++++++++--------
>>> fs/nfs/write.c  |   33 +++++++++++++++++++--------------
>>> 3 files changed, 40 insertions(+), 26 deletions(-)
>>>
>>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>>> index abf8e02..4757a2b 100644
>>> --- a/fs/nfs/direct.c
>>> +++ b/fs/nfs/direct.c
>>> @@ -347,8 +347,9 @@ static ssize_t
>>> nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
>>> 		NFS_PROTO(inode)->read_setup(data, &msg);
>>>
>>> 		task = rpc_run_task(&task_setup_data);
>>> -		if (!IS_ERR(task))
>>> -			rpc_put_task(task);
>>> +		if (IS_ERR(task))
>>> +			break;
>>> +		rpc_put_task(task);
>>>
>>> 		dprintk("NFS: %5u initiated direct read call "
>>> 			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
>>
>> My reading of this logic suggests that if the very first
>> rpc_run_task() call in the loop fails, we'll return -EFAULT instead  
>> of
>> something sensible, like -ENOMEM.
>
> I'm confused. How could ENOMEM be a sensible substitute for EFAULT?


My point is that EFAULT isn't an appropriate return code if  
rpc_run_task() fails.  EFAULT is appropriate only when the I/O engine  
can't access the user's memory.

If no bytes were read, an error code that reflects the problem should  
be returned.

	task = rpc_run_task(&task_setup_data);
	if (IS_ERR(task) {
		result = PTR_ERR(task);
		break;
	}
	rpc_put_task(task);

The logic at the end of nfs_direct_read_schedule_segment() will take  
care to return the number of bytes read, or an error code if no bytes  
were read.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
