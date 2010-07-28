Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:29030 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab0G1Rix (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jul 2010 13:38:53 -0400
Message-ID: <4C506AD0.4070608@oracle.com>
Date: Wed, 28 Jul 2010 13:37:20 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Andy Chittenden <andyc@bluearc.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>,
        "Linux Kernel Mailing List (linux-kernel@vger.kernel.org)"
	<linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        netdev <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfs client hang
References: <99613C19B13C5D40914FB8930657FA9303365708DE@uk-ex-mbx1.terastack.bluearc.com>	 <4C4E89D4.8040607@bluearc.com>	 <ABFC24E4C13D81489F7F624E14891C8607DDF8D1E4@uk-ex-mbx1.terastack.bluearc.com> <1280233276.2827.175.camel@edumazet-laptop> <4C4F174C.2000308@oracle.com> <ABFC24E4C13D81489F7F624E14891C8607DDF8D3D0@uk-ex-mbx1.terastack.bluearc.com>
In-Reply-To: <ABFC24E4C13D81489F7F624E14891C8607DDF8D3D0@uk-ex-mbx1.terastack.bluearc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/28/10 03:24 AM, Andy Chittenden wrote:
> resending as it seems to have been corrupted on LKML!
>
>> The RPC client marks the socket closed. and the linger timeout is
>> cancelled.  At this point, sk_shutdown should be set to zero, correct?
>> I don't see an xs_error_report() call here, which would confirm that the
>> socket took a trip through tcp_disconnect().
>
> From my reading of tcp_disconnect(), it calls sk->sk_error_report(sk)
> unconditionally so as there's no xs_error_report(), that surely means
> the exact opposite: tcp_disconnect() wasn't called. If it's not
> called, sk_shutdown is not cleared. And my revised tracing confirmed
> that it was set to SEND_SHUTDOWN.

Sorry, that's what I meant above.

An xs_error_report() debugging message at that point in the log would 
confirm that the socket took a trip through tcp_disconnect().  But I 
don't see such a message.
