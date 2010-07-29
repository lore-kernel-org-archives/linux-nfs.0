Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p01c12o148.mxlogic.net ([208.65.145.71]:44415 "EHLO
	p01c12o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756166Ab0G2KKT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jul 2010 06:10:19 -0400
Message-ID: <4C515384.6030905@bluearc.com>
Date: Thu, 29 Jul 2010 11:10:12 +0100
From: Andy Chittenden <andyc@bluearc.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>,
        "Linux Kernel Mailing List (linux-kernel@vger.kernel.org)"
	<linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        netdev <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfs client hang
References: <99613C19B13C5D40914FB8930657FA9303365708DE@uk-ex-mbx1.terastack.bluearc.com>	 <4C4E89D4.8040607@bluearc.com>	 <ABFC24E4C13D81489F7F624E14891C8607DDF8D1E4@uk-ex-mbx1.terastack.bluearc.com> <1280233276.2827.175.camel@edumazet-laptop> <4C4F174C.2000308@oracle.com> <ABFC24E4C13D81489F7F624E14891C8607DDF8D3D0@uk-ex-mbx1.terastack.bluearc.com> <4C506AD0.4070608@oracle.com>
In-Reply-To: <4C506AD0.4070608@oracle.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  On 2010-07-28 18:37, Chuck Lever wrote:
> On 07/28/10 03:24 AM, Andy Chittenden wrote:
>> resending as it seems to have been corrupted on LKML!
>>
>>> The RPC client marks the socket closed. and the linger timeout is
>>> cancelled.  At this point, sk_shutdown should be set to zero, correct?
>>> I don't see an xs_error_report() call here, which would confirm that the
>>> socket took a trip through tcp_disconnect().
>>  From my reading of tcp_disconnect(), it calls sk->sk_error_report(sk)
>> unconditionally so as there's no xs_error_report(), that surely means
>> the exact opposite: tcp_disconnect() wasn't called. If it's not
>> called, sk_shutdown is not cleared. And my revised tracing confirmed
>> that it was set to SEND_SHUTDOWN.
> Sorry, that's what I meant above.
>
> An xs_error_report() debugging message at that point in the log would
> confirm that the socket took a trip through tcp_disconnect().  But I
> don't see such a message.
I don't see how tcp_disconnect() gets called if the application does a 
shutdown when the state is TCP_ESTABLISHED (or a myriad of other 
states). It just seems to send a FIN. Should tcp_disconnect() be called? 
If so, how? Alternatively, I wonder whether my patch that set 
sk_shutdown to 0 in tcp_connect_init() is the correct fix after all.

-- 
Andy, BlueArc Engineering

