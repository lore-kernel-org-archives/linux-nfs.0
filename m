Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:34769 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754824AbbISPHr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Sep 2015 11:07:47 -0400
Received: by oiev17 with SMTP id v17so40035993oie.1
        for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2015 08:07:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150919080812.063ebf1b@synchrony.poochiereds.net>
References: <1442394280-24280-1-git-send-email-suzuki.poulose@arm.com>
	<1442396149-24775-1-git-send-email-suzuki.poulose@arm.com>
	<20150916071730.052af53d@tlielax.poochiereds.net>
	<55FBF32C.7030107@arm.com>
	<1442595095.11370.13.camel@primarydata.com>
	<1442613607.11370.18.camel@primarydata.com>
	<20150919080812.063ebf1b@synchrony.poochiereds.net>
Date: Sat, 19 Sep 2015 11:07:46 -0400
Message-ID: <CAHQdGtT9OA5fUPr=cSH0UPB0Xi5Wz+12C7nF29xZwngYcXtdSA@mail.gmail.com>
Subject: Re: [PATCHv2] SUNRPC: Fix a race in xs_reset_transport
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields <bfields@fieldses.org>," <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org <linux-kernel@vger.kernel.org>, Marc
	Zyngier" <Marc.Zyngier@arm.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 19, 2015 at 8:08 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> On Fri, 18 Sep 2015 18:00:07 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> 8<-------------------------------------------------------------------
>> From 3e1c9d8092e2fa4509d84a00fcf21e7e0c581fe2 Mon Sep 17 00:00:00 2001
>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>> Date: Fri, 18 Sep 2015 15:53:24 -0400
>> Subject: [PATCH] SUNRPC: Lock the transport layer on shutdown
>>
>> Avoid all races with the connect/disconnect handlers by taking the
>> transport lock.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  net/sunrpc/xprt.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index ab5dd621ae0c..2e98f4a243e5 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -614,6 +614,7 @@ static void xprt_autoclose(struct work_struct *work)
>>       clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
>>       xprt->ops->close(xprt);
>>       xprt_release_write(xprt, NULL);
>> +     wake_up_bit(&xprt->state, XPRT_LOCKED);
>>  }
>>
>>  /**
>> @@ -723,6 +724,7 @@ void xprt_unlock_connect(struct rpc_xprt *xprt, void *cookie)
>>       xprt->ops->release_xprt(xprt, NULL);
>>  out:
>>       spin_unlock_bh(&xprt->transport_lock);
>> +     wake_up_bit(&xprt->state, XPRT_LOCKED);
>>  }
>>
>>  /**
>> @@ -1394,6 +1396,10 @@ out:
>>  static void xprt_destroy(struct rpc_xprt *xprt)
>>  {
>>       dprintk("RPC:       destroying transport %p\n", xprt);
>> +
>> +     /* Exclude transport connect/disconnect handlers */
>> +     wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_UNINTERRUPTIBLE);
>> +
>>       del_timer_sync(&xprt->timer);
>>
>>       rpc_xprt_debugfs_unregister(xprt);
>
>
> Yeah, that does seem cleaner and better follows the xs_close locking
> rules. Are those wake_up_bit calls sufficient though? Would it be
> better to just add it to xprt_clear_locked? In principle we should only
> sleep on this bit if there are no other users of the xprt, but I'm
> having a hard time following the code to ensure that that's the case.

If we're in xprt_destroy, then the refcount on the xprt has to be
zero. There should be no struct rpc_clnt referencing it, and hence
also no rpc_tasks to set/clear the lock state.

> Also, it seems like part of the problem is that we're ending up with
> these workqueue jobs being requeued after we've cancelled them. Perhaps
> we ought to have some way to ensure that once the xprt is on its way to
> destruction, the workqueue jobs cannot be requeued?

The workqueue jobs are required to own the lock before being enqueued,
since they need exclusive access to the socket until completed.
Since xprt_destroy now owns the lock, that means the socket callbacks
etc can no longer enqueue any new jobs.
