From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 07/33] NFS: Ensure that rpc_run_task() errors are propagated back to the caller
Date: Tue, 22 Apr 2008 11:32:59 -0400
Message-ID: <F6371394-AC06-4B2A-9786-607E29E2B41A@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204048.14124.4335.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <BE4F0130-A492-4229-83E4-E7C912B0ABF0@oracle.com> <1208823472.7767.40.camel@heimdal.trondhjem.org> <92201A7C-4650-450E-ABF2-EF699B208647@oracle.com> <1208877058.11982.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:43146 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756787AbYDVPeS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2008 11:34:18 -0400
In-Reply-To: <1208877058.11982.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 22, 2008, at 11:10 AM, Trond Myklebust wrote:
> On Tue, 2008-04-22 at 10:19 -0400, Chuck Lever wrote:
>> My point is that EFAULT isn't an appropriate return code if
>> rpc_run_task() fails.  EFAULT is appropriate only when the I/O engine
>> can't access the user's memory.
>>
>> If no bytes were read, an error code that reflects the problem should
>> be returned.
>>
>> 	task = rpc_run_task(&task_setup_data);
>> 	if (IS_ERR(task) {
>> 		result = PTR_ERR(task);

		^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You need to add this line to your patch.

>>
>> 		break;
>> 	}
>> 	rpc_put_task(task);
>>
>> The logic at the end of nfs_direct_read_schedule_segment() will take
>> care to return the number of bytes read, or an error code if no bytes
>> were read.
>
> Then a fix should be applied to auth_gss.c: the EFAULT error message  
> is
> coming from the downcall code. If it is not appropriate to pass that  
> on
> to the RPC caller, then we should substitute an EACCES.

The way I read your patch, PTR_ERR(task) is never returned to  
nfs_direct_read_schedule_segment's caller, so it's not possible for  
the downcall error code to be propagated upwards.

Instead, if rpc_run_task() fails the _first_ time through the loop  
(before any bytes have been started), the loop will exit, but "result"  
will already be set to the number of pages grabbed by get_user_pages.

In other words, if no bytes are in flight, "result" will be equal to  
or greater than zero, and the logic at the end of the function will  
return EFAULT.

Am I wrong about that?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
