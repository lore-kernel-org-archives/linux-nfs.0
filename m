Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:42891 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532AbaAUPfk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jan 2014 10:35:40 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so4091592pdj.1
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jan 2014 07:35:39 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] SUNRPC: Allow one callback request to be received from two sk_buff
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <CALrKORrZ3Kcuqc1RajQKkZcot0yiswh4VR_WuXHqfRTjn9oGQQ@mail.gmail.com>
Date: Tue, 21 Jan 2014 08:35:36 -0700
Cc: Dr Fields James Bruce <bfields@redhat.com>,
        "Miller David S." <davem@davemloft.net>,
        linuxnfs <linux-nfs@vger.kernel.org>, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Message-Id: <1BFACA51-087E-4945-851A-FBF0F108604C@primarydata.com>
References: <1390201154-20815-1-git-send-email-shaobingqing@bwstor.com.cn> <1390259843.2501.2.camel@leira.trondhjem.org> <CALrKORrZ3Kcuqc1RajQKkZcot0yiswh4VR_WuXHqfRTjn9oGQQ@mail.gmail.com>
To: shaobingqing <shaobingqing@bwstor.com.cn>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 21, 2014, at 3:08, shaobingqing <shaobingqing@bwstor.com.cn> wrote:

> 2014/1/21 Trond Myklebust <trond.myklebust@primarydata.com>:
>> On Mon, 2014-01-20 at 14:59 +0800, shaobingqing wrote:
>>> In current code, there only one struct rpc_rqst is prealloced. If one
>>> callback request is received from two sk_buff, the xprt_alloc_bc_request
>>> would be execute two times with the same transport->xid. The first time
>>> xprt_alloc_bc_request will alloc one struct rpc_rqst and the TCP_RCV_COPY_DATA
>>> bit of transport->tcp_flags will not be cleared. The second time
>>> xprt_alloc_bc_request could not alloc struct rpc_rqst any more and NULL
>>> pointer will be returned, then xprt_force_disconnect occur. I think one
>>> callback request can be allowed to be received from two sk_buff.
>>> 
>>> Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
>>> ---
>>> net/sunrpc/xprtsock.c |   11 +++++++++--
>>> 1 files changed, 9 insertions(+), 2 deletions(-)
>>> 
>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>> index ee03d35..606950d 100644
>>> --- a/net/sunrpc/xprtsock.c
>>> +++ b/net/sunrpc/xprtsock.c
>>> @@ -1271,8 +1271,13 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
>>>      struct sock_xprt *transport =
>>>                              container_of(xprt, struct sock_xprt, xprt);
>>>      struct rpc_rqst *req;
>>> +     static struct rpc_rqst *req_partial;
>>> +
>>> +     if (req_partial == NULL)
>>> +             req = xprt_alloc_bc_request(xprt);
>>> +     else if (req_partial->rq_xid == transport->tcp_xid)
>>> +             req = req_partial;
>> 
>> What happens here if req_partial->rq_xid != transport->tcp_xid? AFAICS,
>> req will be undefined. Either way, you cannot use a static variable for
>> storage here: that isn't re-entrant.
> 
> Because metadata sever only have one slot for backchannel request,
> req_partial->rq_xid == transport->tcp_xid always happens, if the callback
> request just being splited in two sk_buffs. But req_partial->rq_xid !=
> transport->tcp_xid may also happens in some special cases, such as
> retransmission occurs?

If the server retransmits, then it is broken. The NFSv4.1 protocol does not allow it to retransmit unless the connection breaks.

> If one callback request is splited in two sk_buffs, xs_tcp_read_callback
> will be execute two times. The req_partial should be a static variable,
> because  the second execution of xs_tcp_read_callback should use
> the rpc_rqst allocated for the first execution, which saves information
> copies from the first sk_buff.

No! This is a multi-threaded/process environment which can support multiple connection. It is a bug to use a static variable.

--
Trond Myklebust
Linux NFS client maintainer

