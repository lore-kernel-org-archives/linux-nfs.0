Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7162 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751426Ab1GAShl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jul 2011 14:37:41 -0400
Subject: Re: Potential locking issue in sunrpc
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Ben Greear <greearb@candelatech.com>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 01 Jul 2011 14:37:39 -0400
In-Reply-To: <4E0CE5E9.2090401@candelatech.com>
References: <4E0CE5E9.2090401@candelatech.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1309545459.5230.25.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-06-30 at 14:08 -0700, Ben Greear wrote: 
> This method in sched.c says we should have a lock for ASYNC
> 
> /*
>   * Make an RPC task runnable.
>   *
>   * Note: If the task is ASYNC, this must be called with
>   * the spinlock held to protect the wait queue operation.
>   */
> static void rpc_make_runnable(struct rpc_task *task)
> 
> However, I don't think the lock is being taken for
> the call path starting with rpcb_call_async in
> rpcb_clnt.c:
> 
> rpcb_call_async
> rpc_run_task
> rpc_execute
> rpc_make_runnable
> 
> Is the comment on the make_runnable method wrong, or are we missing locking?

Neither. In the above case, we are not waking up from a wait queue, so
there are no locks involved.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

