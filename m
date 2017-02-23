Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18672 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbdBWUR0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2017 15:17:26 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 1/4] sunrpc: flag transports as using IETF approved congestion control protocols
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <65056db6-f30a-c44d-b01c-b549887c4895@talpey.com>
Date: Thu, 23 Feb 2017 15:17:16 -0500
Cc: Jeff Layton <jlayton@redhat.com>, bfields@fieldses.org,
        trond.myklebust@primarydata.com, schumaker.anna@gmail.com,
        linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Message-Id: <634EC3BA-6A1A-4B8A-B402-C29AC5098756@oracle.com>
References: <20170223170337.10686-1-jlayton@redhat.com> <20170223170337.10686-2-jlayton@redhat.com> <2152dfdf-f847-2511-1600-6499b6ea9708@talpey.com> <1487880034.3448.8.camel@redhat.com> <65056db6-f30a-c44d-b01c-b549887c4895@talpey.com>
To: Tom Talpey <tom@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



--
Chuck Lever

> On Feb 23, 2017, at 3:06 PM, Tom Talpey <tom@talpey.com> wrote:
> 
>> On 2/23/2017 3:00 PM, Jeff Layton wrote:
>>> On Thu, 2017-02-23 at 14:42 -0500, Tom Talpey wrote:
>>>> On 2/23/2017 12:03 PM, Jeff Layton wrote:
>>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>>> ---
>>>> include/linux/sunrpc/svc_xprt.h          | 1 +
>>>> net/sunrpc/svcsock.c                     | 1 +
>>>> net/sunrpc/xprtrdma/svc_rdma_transport.c | 2 ++
>>> 
>>> There's a possibly-important detail here. Not all RDMA transports have
>>> "IETF-approved congestion control", for example, RoCEv1. However, iWARP
>>> and (arguably) RoCEv2 do. On the other hand, as a nonroutable protocol,
>>> RoCEv1 may not fall under this restriction.
>>> 
>>> Net-net, inspecting only the RDMA attribute of the transport may be
>>> insufficient here.
>>> 
>>> It could be argued however that the xprtrdma layer, with its rpcrdma
>>> crediting, provides such congestion. But that needs to be made
>>> explicit, and perhaps, discussed in IETF. Initially, I think it would
>>> be important to flag this as a point for the future. For now, it may
>>> be best to flag RoCEv1 as not supporting congestion.
>>> 
>>> Tom.
>>> 
>> 
>> (cc'ing Chuck and the linux-rdma list)
>> 
>> Thanks Tom, that's very interesting.
>> 
>> Not being well versed in the xprtrdma layer, what condition should we
>> use here to set the flag? git grep shows that the string "ROCEV1" only
>> shows up in the bxnt_en driver. Is there some way to determine this
>> generically for any given RDMA driver?
> 
> I would not code RoCEv1 as an exception, I would code iWARP and RoCEv2
> as the only eligible ones. There are any number of other possibilities,
> none of which should be automatically flagged as congestion-controlled.
> 
> I'm also not sure I'm comfortable with hardcoding such a list into RPC.
> But it may be the best you can do for now. Chuck, are you aware of a
> verbs interface to obtain the RDMA transport type?

Yes, I can have a look when I get to Connectathon.



> 
> Tom.
> 
>> 
>> 
>>>> 3 files changed, 4 insertions(+)
>>>> 
>>>> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
>>>> index 7440290f64ac..f8aa9452b63c 100644
>>>> --- a/include/linux/sunrpc/svc_xprt.h
>>>> +++ b/include/linux/sunrpc/svc_xprt.h
>>>> @@ -67,6 +67,7 @@ struct svc_xprt {
>>>> #define XPT_CACHE_AUTH    11        /* cache auth info */
>>>> #define XPT_LOCAL    12        /* connection from loopback interface */
>>>> #define XPT_KILL_TEMP   13        /* call xpo_kill_temp_xprt before closing */
>>>> +#define XPT_CONG_CTRL    14        /* IETF approved congestion control protocol */
>>>> 
>>>>    struct svc_serv        *xpt_server;    /* service for transport */
>>>>    atomic_t                xpt_reserved;    /* space on outq that is rsvd */
>>>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>>>> index de066acdb34e..1956b8b96b2d 100644
>>>> --- a/net/sunrpc/svcsock.c
>>>> +++ b/net/sunrpc/svcsock.c
>>>> @@ -1306,6 +1306,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
>>>>    svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_tcp_class,
>>>>              &svsk->sk_xprt, serv);
>>>>    set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
>>>> +    set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
>>>>    if (sk->sk_state == TCP_LISTEN) {
>>>>        dprintk("setting up TCP socket for listening\n");
>>>>        set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>>> index 39652d390a9c..96b4797c2c54 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>>> @@ -571,6 +571,8 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
>>>>    spin_lock_init(&cma_xprt->sc_ctxt_lock);
>>>>    spin_lock_init(&cma_xprt->sc_map_lock);
>>>> 
>>>> +    set_bit(XPT_CONG_CTRL, &cma_xprt->sc_xprt.xpt_flags);
>>>> +
>>>>    if (listener)
>>>>        set_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
>>>> 
>>>> 
>> 

