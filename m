Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35451 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443AbbFCS3z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2015 14:29:55 -0400
Received: by qkhq76 with SMTP id q76so10621506qkh.2
        for <linux-nfs@vger.kernel.org>; Wed, 03 Jun 2015 11:29:54 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [BUG] nfs3 client stops retrying to connect
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20150521012155.GA19680@bender.morinfr.org>
Date: Wed, 3 Jun 2015 14:31:55 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chris Mason <clm@fb.com>
Message-Id: <DAF3CB64-5777-4F74-A31E-4F3FE55D14AD@gmail.com>
References: <20150521012155.GA19680@bender.morinfr.org>
To: Guillaume Morin <guillaume@morinfr.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 20, 2015, at 9:21 PM, Guillaume Morin <guillaume@morinfr.org> wrote:

> Hi,
> 
> Last week we had an NFS outage and one of our NFS servers
> went down for quite a while. All clients use it for NFSv3 hard mount
> using TCP
> 
> Most clients recovered fine when the server came back up but a dozen or
> so never did.  They are all running 3.14.35 or later.
> 
> All tasks trying to use the mount are in D state and have not recovered.
> The last and only nfs-related message in the kernel log is
> nfs: server blah not responding, still trying
> 
> I spent some time trying to debug the problem.  ftrace showed that the
> rpc subsystems is trying to recover:
> 
> <idle>-0     [003] dNs. 4619235.426567: sched_wakeup: comm=daemon pid=4247 prio=120 success=1 target_cpu=003
> daemon-4247  [003] .... 4619235.426582: rpc_task_run_action: task:44610@4 flags=00a0 state=0005 status=-110 action=call_connect_status [sunrpc]
> daemon-4247  [003] .... 4619235.426583: rpc_connect_status: task:44610@4, status -110
> daemon-4247  [003] .... 4619235.426588: rpc_task_run_action: task:44610@4 flags=00a0 state=0005 status=0 action=call_timeout [sunrpc]
> daemon-4247  [003] .... 4619235.426589: rpc_task_run_action: task:44610@4 flags=00a0 state=0005 status=0 action=call_bind [sunrpc]
> daemon-4247  [003] .... 4619235.426590: rpc_task_run_action: task:44610@4 flags=00a0 state=0005 status=0 action=call_connect [sunrpc]
> daemon-4247  [003] ..s. 4619235.426591: rpc_task_sleep: task:44610@4 flags=00a0 state=0005 status=0 timeout=18000 queue=xprt_pending
> 
> This goes on and on but despite all this a tcpdump shows that the client
> never tries to connect.  There is absolutely no traffic between the
> nfs client and the nfs server.
> 
> I looked at the daemon in crash and looked at its rpc_task, it looked
> pretty legit:
> struct rpc_task {
>  tk_count = {
>    counter = 2
>  }, 
>  tk_task = {
>    next = 0xffff88010bf67008, 
>    prev = 0xffff88032f81e018
>  }, 
>  tk_client = 0xffff88032f81e000, 
>  tk_rqstp = 0xffff8803310a4c00, 
>  tk_msg = {
>    rpc_proc = 0xffffffffa08b7b18, 
>    rpc_argp = 0xffff88016abe6a58, 
>    rpc_resp = 0xffff880165d6db00, 
>    rpc_cred = 0x0
>  }, 
>  tk_callback = 0xffffffffa06f19e0 <xprt_connect_status>, 
>  tk_action = 0xffffffffa06ee310 <call_connect_status>, 
>  tk_ops = 0xffffffffa070db20 <rpc_default_ops>, 
>  tk_calldata = 0x0, 
>  tk_timeout = 36000, 
>  tk_runstate = 6, 
>  tk_workqueue = 0x0, 
>  tk_waitqueue = 0xffff880331352a58, 
>  u = {
>    tk_work = {
>      data = {
>        counter = -131927684863392
>      }, 
>      entry = {
>        next = 0xffff880331352a60, 
>        prev = 0x0
>      }, 
>      func = 0x0
>    }, 
>    tk_wait = {
>      list = {
>        next = 0xffff880331352a60, 
>        prev = 0xffff880331352a60
>      }, 
>      links = {
>        next = 0x0, 
>        prev = 0x0
>      }, 
>      timer_list = {
>        next = 0xffff880331352b00, 
>        prev = 0xffff880331352b00
>      }, 
>      expires = 5680095648
>    }
>  }, 
>  tk_start = {
>    tv64 = 4088588208239840
>  }, 
>  tk_owner = 4247, 
>  tk_status = 0, 
>  tk_flags = 160, 
>  tk_timeouts = 2929, 
>  tk_pid = 44610, 
>  tk_priority = 1 '\001', 
>  tk_garb_retry = 2 '\002', 
>  tk_cred_retry = 2 '\002', 
>  tk_rebind_retry = 2 '\002'
> 
> 
> When I dug into the nested rpc_xprt object, I noticed that the state was 0x15 which is
> XPRT_LOCKED|XPRT_CONNECTING|XPRT_BOUND
> 
> XPRT_CONNECTING is surprising since there was definitely no traffic
> going on between the server and the client (and it was the case for
> a few days)
> 
> If xprt_connect() is called while XPRT_CONNECTING is set, we do not try to
> connect() again until it cleared.  It seemed it was erroneously set.
> 
> To test this theory, I wrote a module that when loaded cleared that bit
> in the xprt_task.  As soon as the rpc task timed out, the client tried
> to connect and the mount recovered gracefully.
> 
> I am not quite sure how it got into that state though as
> xs_tcp_setup_socket always clears it.  But it definitely happened on a
> few machines.
> 
> If somehow xs_close() is called before the callback
> happens, I think it could leave XPRT_CONNECTING on forever though
> (since xs_tcp_setup_socket is never called), see
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/net/sunrpc/xprtsock.c?id=refs/tags/v3.14.43#n887
> 
> I am still have a few clients with the stuck mount so I could gather
> more information if necessary.

A series of commits were merged into the v4.0 kernel, starting with commit 4dda9c8a5e34,
that changed the TCP connect logic significantly. It would be helpful to know if the
problem can be reproduced when your clients are running the v4.0 kernel.

--
Chuck Lever
chucklever@gmail.com



