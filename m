Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26269 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753461Ab1CVQCi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2011 12:02:38 -0400
Message-ID: <4D88C832.4010104@parallels.com>
Date: Tue, 22 Mar 2011 19:02:58 +0300
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
To: Peter Lojkin <ia6432@inbox.ru>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] RPC: killing RPC tasks races fixed
References: <E1Q22wg-00080R-00.ia6432-inbox-ru@f70.mail.ru>
In-Reply-To: <E1Q22wg-00080R-00.ia6432-inbox-ru@f70.mail.ru>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

22.03.2011 17:52, Peter Lojkin пишет:
> On Thu, 2011-03-17 at 15:54:23 2011-03-17 at 18:43 +0300, Stanislav Kinsbursky wrote:
>
>> RPC task RPC_TASK_QUEUED bit is set must be checked before trying to wake up
>> task rpc_killall_tasks() because task->tk_waitqueue can not be set (equal to
>> NULL).
>> Also, as Trond Myklebust mentioned, such approach (instead of checking
>> tk_waitqueue to NULL) allows us to "optimise away the call to
>> rpc_wake_up_queued_task() altogether for those
>> tasks that aren't queued".
>
> you mentioned earlier that you have found this problem in .32 kernel but your patch only works for newer kernels.
> does the following patch is correct and needed for pre .36 kernels?
>


Yes, it is. This bug was found in rhel6 kernel which is based on 2.6.32 vanilla.


> --- a/net/sunrpc/sched.c	2011-03-22 16:55:36.802000287 +0300
> +++ b/net/sunrpc/sched.c	2011-03-22 17:01:13.858000242 +0300
> @@ -939,7 +939,8 @@
>   		if (!(rovr->tk_flags&  RPC_TASK_KILLED)) {
>   			rovr->tk_flags |= RPC_TASK_KILLED;
>   			rpc_exit(rovr, -EIO);
> -			rpc_wake_up_task(rovr);
> +			if (RPC_IS_QUEUED(rovr))
> +				rpc_wake_up_task(rovr);
>   		}
>   	}
>   	spin_unlock(&clnt->cl_lock);
>


-- 
Best regards,
Stanislav Kinsbursky
