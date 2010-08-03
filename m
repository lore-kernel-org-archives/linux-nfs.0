Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:48781 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755801Ab0HCKZk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 06:25:40 -0400
Message-ID: <4C57EE9A.7040308@gmail.com>
Date: Tue, 03 Aug 2010 11:25:30 +0100
From: Andy Chittenden <andyc.bluearc@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, eric.dumazet@gmail.com,
        William.Allen.Simpson@gmail.com, gilad@codefidence.com,
        ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] [Bug 16494] NFS client over TCP hangs due to packet loss
References: <4c57cfe8.887b0e0a.2f79.4772@mx.google.com>	<20100803.012144.267950450.davem@davemloft.net> <20100803021110.f0b3877b.akpm@linux-foundation.org>
In-Reply-To: <20100803021110.f0b3877b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-08-03 10:11, Andrew Morton wrote:
> (cc linux-nfs)
>
> On Tue, 03 Aug 2010 01:21:44 -0700 (PDT) David Miller<davem@davemloft.net>  wrote:
>
>> From: "Andy Chittenden"<andyc.bluearc@gmail.com>
>> Date: Tue, 3 Aug 2010 09:14:31 +0100
>>
>>> I don't know whether this patch is the correct fix or not but it enables the
>>> NFS client to recover.
>>>
>>> Kernel version: 2.6.34.1 and 2.6.32.
>>>
>>> Fixes<https://bugzilla.kernel.org/show_bug.cgi?id=16494>. It clears down
>>> any previous shutdown attempts so that reconnects on a socket that's been
>>> shutdown leave the socket in a usable state (otherwise tcp_sendmsg() returns
>>> -EPIPE).
>>
>> If the SunRPC code wants to close a TCP socket then use it again,
>> it should disconnect by doing a connect() with sa_family == AF_UNSPEC

There is code to do that in the SunRPC code in xs_abort_connection() but 
that's conditionally called from xs_tcp_reuse_connection():

static void xs_tcp_reuse_connection(struct rpc_xprt *xprt, struct 
sock_xprt *transport)
{
	unsigned int state = transport->inet->sk_state;

	if (state == TCP_CLOSE && transport->sock->state == SS_UNCONNECTED)
		return;
	if ((1 << state) & (TCPF_ESTABLISHED|TCPF_SYN_SENT))
		return;
	xs_abort_connection(xprt, transport);
}

That's changed since 2.6.26 where it unconditionally did the connect() 
with sa_family == AF_UNSPEC. FWIW we cannot reproduce this problem with 
2.6.26.


