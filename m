Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:46094 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbaAWBmM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jan 2014 20:42:12 -0500
MIME-Version: 1.0
In-Reply-To: <20140122235233.GA17155@fieldses.org>
References: <1390201154-20815-1-git-send-email-shaobingqing@bwstor.com.cn>
	<1390259843.2501.2.camel@leira.trondhjem.org>
	<CALrKORrZ3Kcuqc1RajQKkZcot0yiswh4VR_WuXHqfRTjn9oGQQ@mail.gmail.com>
	<1BFACA51-087E-4945-851A-FBF0F108604C@primarydata.com>
	<20140122235233.GA17155@fieldses.org>
Date: Thu, 23 Jan 2014 09:42:11 +0800
Message-ID: <CALrKORrNnd+LOE_8Y7zRXbnbGVHV02pJdAZ5B+VPVS72w71zBQ@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Allow one callback request to be received from
 two sk_buff
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dr Fields James Bruce <bfields@redhat.com>,
        "Miller David S." <davem@davemloft.net>,
        linuxnfs <linux-nfs@vger.kernel.org>, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014/1/23 J. Bruce Fields <bfields@fieldses.org>:
> On Tue, Jan 21, 2014 at 08:35:36AM -0700, Trond Myklebust wrote:
>>
>> On Jan 21, 2014, at 3:08, shaobingqing <shaobingqing@bwstor.com.cn> wrote:
>>
>> > 2014/1/21 Trond Myklebust <trond.myklebust@primarydata.com>:
>> >> On Mon, 2014-01-20 at 14:59 +0800, shaobingqing wrote:
>> >>> In current code, there only one struct rpc_rqst is prealloced. If one
>> >>> callback request is received from two sk_buff, the xprt_alloc_bc_request
>> >>> would be execute two times with the same transport->xid. The first time
>> >>> xprt_alloc_bc_request will alloc one struct rpc_rqst and the TCP_RCV_COPY_DATA
>> >>> bit of transport->tcp_flags will not be cleared. The second time
>> >>> xprt_alloc_bc_request could not alloc struct rpc_rqst any more and NULL
>> >>> pointer will be returned, then xprt_force_disconnect occur. I think one
>> >>> callback request can be allowed to be received from two sk_buff.
>> >>>
>> >>> Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
>> >>> ---
>> >>> net/sunrpc/xprtsock.c |   11 +++++++++--
>> >>> 1 files changed, 9 insertions(+), 2 deletions(-)
>> >>>
>> >>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> >>> index ee03d35..606950d 100644
>> >>> --- a/net/sunrpc/xprtsock.c
>> >>> +++ b/net/sunrpc/xprtsock.c
>> >>> @@ -1271,8 +1271,13 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
>> >>>      struct sock_xprt *transport =
>> >>>                              container_of(xprt, struct sock_xprt, xprt);
>> >>>      struct rpc_rqst *req;
>> >>> +     static struct rpc_rqst *req_partial;
>> >>> +
>> >>> +     if (req_partial == NULL)
>> >>> +             req = xprt_alloc_bc_request(xprt);
>> >>> +     else if (req_partial->rq_xid == transport->tcp_xid)
>> >>> +             req = req_partial;
>> >>
>> >> What happens here if req_partial->rq_xid != transport->tcp_xid? AFAICS,
>> >> req will be undefined. Either way, you cannot use a static variable for
>> >> storage here: that isn't re-entrant.
>> >
>> > Because metadata sever only have one slot for backchannel request,
>> > req_partial->rq_xid == transport->tcp_xid always happens, if the callback
>> > request just being splited in two sk_buffs. But req_partial->rq_xid !=
>> > transport->tcp_xid may also happens in some special cases, such as
>> > retransmission occurs?
>>
>> If the server retransmits, then it is broken. The NFSv4.1 protocol does not allow it to retransmit unless the connection breaks.
>
> shaobingqing, are you actually seeing retransmission?  (If so, are we
> setting up the callback client wrong?)
No, not actually. Here I just see that one client can receive two
callback requests with the same xid.
>
> --b.
>
>>
>> > If one callback request is splited in two sk_buffs, xs_tcp_read_callback
>> > will be execute two times. The req_partial should be a static variable,
>> > because  the second execution of xs_tcp_read_callback should use
>> > the rpc_rqst allocated for the first execution, which saves information
>> > copies from the first sk_buff.
>>
>> No! This is a multi-threaded/process environment which can support multiple connection. It is a bug to use a static variable.
>>
>> --
>> Trond Myklebust
>> Linux NFS client maintainer
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
