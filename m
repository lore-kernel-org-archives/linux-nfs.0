Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:34599 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaDNUyD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2014 16:54:03 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5710A71F-C4D5-408B-9B41-07F21B5853F0@oracle.com>
Date: Mon, 14 Apr 2014 16:53:49 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <6837A427-B677-4CC7-A022-4FB9E52A3FC6@oracle.com>
References: <014738b6-698e-4ea1-82f9-287378bfec19@CMEXHTCAS2.ad.emulex.com> <D7AB2150-5F25-4BA2-80D9-94890AD11F8F@primarydata.com> <F1C70AD6-BDD4-4534-8DC4-61D2767581D9@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEAA43@CMEXMB1.ad.emulex.com> <E66D006A-0D04-4602-8BF5-6834CACD2E24@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEB3B4@CMEXMB1.ad.emulex.com> <BD7B05C0-4733-4DD1-83F3-B30B6B0EE48C@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEB3DF@CMEXMB1.ad.emulex.com> <56C87770-7940-4006-948C-FEF3C0EC4ACC@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEBD66@CMEXMB1.ad.emulex.com> <5710A71F-C4D5-408B-9B41-07F21B5853F0@oracle.com>
To: Devesh Sharma <Devesh.Sharma@Emulex.Com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Devesh-


On Apr 13, 2014, at 12:01 AM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Apr 11, 2014, at 7:51 PM, Devesh Sharma <Devesh.Sharma@Emulex.Com> wrote:
> 
>> Hi  Chuck,
>> Yes that is the case, Following is the trace I got.
>> 
>> <4>RPC:   355 setting alarm for 60000 ms
>> <4>RPC:   355 sync task going to sleep
>> <4>RPC:       xprt_rdma_connect_worker: reconnect
>> <4>RPC:       rpcrdma_ep_disconnect: rdma_disconnect -1
>> <4>RPC:       rpcrdma_ep_connect: rpcrdma_ep_disconnect status -1
>> <3>ocrdma_mbx_create_qp(0) rq_err
>> <3>ocrdma_mbx_create_qp(0) sq_err
>> <3>ocrdma_create_qp(0) error=-1
>> <4>RPC:       rpcrdma_ep_connect: rdma_create_qp failed -1
>> <4>RPC:   355 __rpc_wake_up_task (now 4296956756)
>> <4>RPC:   355 disabling timer
>> <4>RPC:   355 removed from queue ffff880454578258 "xprt_pending"
>> <4>RPC:       __rpc_wake_up_task done
>> <4>RPC:       xprt_rdma_connect_worker: exit
>> <4>RPC:   355 sync task resuming
>> <4>RPC:   355 xprt_connect_status: error 1 connecting to server 192.168.1.1
> 
> xprtrdma’s connect worker is returning “1” instead of a negative errno.
> That’s the bug that triggers this chain of events.

rdma_create_qp() has returned -EPERM. There’s very little xprtrdma can do if
the provider won’t even create a QP. That seems like a rare and fatal problem.

For the moment, I’m inclined to think that a panic is correct behavior, since
there are outstanding registered memory regions that cannot be cleaned up
without a QP (see below).


> RPC tasks waiting for the reconnect are awoken. xprt_connect_status() doesn’t
> recognize a tk_status of “1”, so it turns it into -EIO, and kills each waiting
> RPC task.

>> <4>RPC:       wake_up_next(ffff880454578190 "xprt_sending")
>> <4>RPC:   355 call_connect_status (status -5)
>> <4>RPC:   355 return 0, status -5
>> <4>RPC:   355 release task
>> <4>RPC:       wake_up_next(ffff880454578190 "xprt_sending")
>> <4>RPC:       xprt_rdma_free: called on 0x(null)
> 
> And as part of exiting, the RPC task has to free its buffer.
> 
> Not exactly sure why req->rl_nchunks is not zero for an NFSv4 GETATTR.
> This is why rpcrdma_deregister_external() is invoked here.
> 
> Eventually this gets around to attempting to post a LOCAL_INV WR with
> ->qp set to NULL, and the panic below occurs.

This is a somewhat different problem.

Not only do we need to have a good ->qp here, but it has to be connected
and in the ready-to-send state before LOCAL_INV work requests can be posted.

The implication of this is that if a server disconnects (server crash
or network partition), the client is stuck waiting for the server to come
back before it can deregister memory and retire outstanding RPC requests.

This is bad for ^C or soft timeouts or umount … when the server is unavailable.

So I feel we need better clean-up when the client cannot reconnect. Probably
deregistering RPC chunk MR’s before finally tearing down the old QP is what
is necessary.

I’ll play around with this idea.


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



