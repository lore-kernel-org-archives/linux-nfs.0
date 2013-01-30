Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:43358 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3A3FmZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 00:42:25 -0500
Message-ID: <5108B2B6.7010807@parallels.com>
Date: Wed, 30 Jan 2013 09:42:14 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>,
        <linux-kernel@vger.kernel.org>, <devel@openvz.org>
Subject: Re: [RFC PATCH] SUNRPC: protect transport processing with rw sem
References: <20130129110317.29541.51920.stgit@localhost.localdomain> <20130129225736.GC6219@fieldses.org>
In-Reply-To: <20130129225736.GC6219@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

30.01.2013 02:57, J. Bruce Fields пишет:
> On Tue, Jan 29, 2013 at 02:03:30PM +0300, Stanislav Kinsbursky wrote:
>> There could be a service transport, which is processed by service thread and
>> racing in the same time with per-net service shutdown like listed below:
>>
>> CPU#0:                            CPU#1:
>>
>> svc_recv                        svc_close_net
>> svc_get_next_xprt (list_del_init(xpt_ready))
>>                              svc_close_list (set XPT_BUSY and XPT_CLOSE)
>>                              svc_clear_pools(xprt was gained on CPU#0 already)
>>                              svc_delete_xprt (set XPT_DEAD)
>> svc_handle_xprt (is XPT_CLOSE => svc_delete_xprt()
>> BUG()
>>
>> There could be different solutions of the problem.
>> Probably, the patch doesn't implement the best one, but I hope the simple one.
>> IOW, it protects critical section (dequeuing of pending transport and
>> enqueuing  it back to the pool) by per-service rw semaphore,
>
> It's actually per-thread (per-struct svc_rqst) here.
>

Yes, sure.

>> taken for read.
>> On per-net transports shutdown, this semaphore have to be taken for write.
>
> There's no down_write in this patch.  Did you forget this part?
>

See "fs/nfs/callback.c" part

> The server rpc code goes to some care not to write to any global
> structure, to prevent server threads running on multiple cores from
> bouncing cache lines between them.
>

This is just an idea. I.e. I wasn't trying to polish the patch - just to share the vision.

> But my understanding is that even down_read() does modify the semaphore.
> So we might want something like the percpu semaphore describe in
> Documentation/percpu-rw-semaphore.txt.
>

Sure, I'll have a look.


-- 
Best regards,
Stanislav Kinsbursky
