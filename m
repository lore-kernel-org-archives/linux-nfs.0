Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp02.citrix.com ([66.165.176.63]:9393 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754257Ab1KRTEl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Nov 2011 14:04:41 -0500
Message-ID: <4EC6AC47.60404@citrix.com>
Date: Fri, 18 Nov 2011 19:04:39 +0000
From: Andrew Cooper <andrew.cooper3@citrix.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: NFS TCP race condition with SOCK_ASYNC_NOSPACE
References: <4EC6A681.30902@citrix.com> <1321642368.2653.35.camel@lade.trondhjem.org>
In-Reply-To: <1321642368.2653.35.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18/11/11 18:52, Trond Myklebust wrote:
> On Fri, 2011-11-18 at 18:40 +0000, Andrew Cooper wrote: 
>> Hello,
>>
>> As described originally in
>> http://www.spinics.net/lists/linux-nfs/msg25314.html, we were
>> encountering a bug whereby the NFS session was unexpectedly timing out.
>>
>> I believe I have found the source of the race condition causing the timeout.
>>
>> Brief overview of setup:
>>   10GiB network, NFS mounted using TCP.  Problem reproduces with
>> multiple different NICs, with synchronous or asynchronous mounts, and
>> with soft and hard mounts.  Reproduces on 2.6.32 and I am currently
>> trying to reproduce with mainline. (I don't have physical access to the
>> servers so installing stuff is not fantastically easy)
>>
>>
>>
>> In net/sunrpc/xprtsock.c:xs_tcp_send_request(), we try to write data to
>> the sock buffer using xs_sendpages()
>>
>> When the sock buffer is nearly fully, we get an EAGAIN from
>> xs_sendpages() which causes a break out of the loop.  Lower down the
>> function, we switch on status which cases us to call xs_nospace() with
>> the task.
>>
>> In xs_nospace(), we test the SOCK_ASYNC_NOSPACE bit from the socket, and
>> in the rare case where that bit is clear, we return 0 instead of
>> EAGAIN.  This promptly overwrites status in xs_tcp_send_request().
>>
>> The result is that xs_tcp_release_xprt() finds a request which has no
>> error, but has not sent all of the bytes in its send buffer.  It cleans
>> up by setting XPRT_CLOSE_WAIT which causes xprt_clear_locked() to queue
>> xprt->task_cleanup, which closes the TCP connection.
>>
>>
>> Under normal operation, the TCP connection goes down and back up without
>> interruption to the NFS layer.  However, when the NFS server hangs in a
>> half closed state, the client forces a RST of the TCP connection,
>> leading to the timeout.
>>
>> I have tried a few naive fixes such as changing the default return value
>> in xs_nospace() from 0 to -EAGAIN (meaning that 0 will never be
>> returned) but this causes a kernel memory leak.  Can someone who a
>> better understanding of these interactions than me have a look?  It
>> seems that the if (test_bit()) test in xs_nospace() should have an else
>> clause.
> I fully agree with your analysis. The correct thing to do here is to
> always return either EAGAIN or ENOTCONN. Thank you very much for working
> this one out!
>
> Trond

Returning EAGAIN seems to cause a kernel memory leak, as the oomkiller
starts going after processes holding large amounts of LowMem.  Returning
ENOTCONN causes the NFS session to complain about a timeout in the logs,
and in the case of a softmout, give an EIO to the calling process.

>From the looks of the TCP stream, and from the the looks of some
targeted debugging, nothing is actually wrong, so the client should not
be trying to FIN the TCP connection.  Is it possible that there is a
more sinister reason for SOCK_ASYNC_NOSPACE being clear?

I can attempt to find which of the many calls to clear that bit is
actually causing the problem, but I have a feeing that is going to a
little more tricky to narrow down.

-- 
Andrew Cooper - Dom0 Kernel Engineer, Citrix XenServer
T: +44 (0)1223 225 900, http://www.citrix.com

