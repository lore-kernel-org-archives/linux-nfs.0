Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:23368 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722AbaJ0BCJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Oct 2014 21:02:09 -0400
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id s9R128lE031587
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 27 Oct 2014 01:02:08 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by ucsinet22.oracle.com (8.14.5+Sun/8.14.5) with ESMTP id s9R0DvYF008678
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 27 Oct 2014 00:13:57 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userz7022.oracle.com (8.14.5+Sun/8.14.4) with ESMTP id s9R0Dv91008670
	for <linux-nfs@vger.kernel.org>; Mon, 27 Oct 2014 00:13:57 GMT
Message-ID: <544D99EF.3030808@oracle.com>
Date: Mon, 27 Oct 2014 09:03:43 +0800
From: Wengang <wen.gang.wang@oracle.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] [SUNRPC]: avoid race between xs_reset_transport and xs_tcp_setup_socket
References: <1413881868-13111-1-git-send-email-wen.gang.wang@oracle.com>
In-Reply-To: <1413881868-13111-1-git-send-email-wen.gang.wang@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Could somebody help to review this patch please?

thanks,
Wengang

于 2014年10月21日 16:57, Wengang Wang 写道:
> A panic with call trace like this:
>
> crash> bt
> PID: 1842   TASK: ffff8824d1d523c0  CPU: 29  COMMAND: "kworker/29:1"
>   #0 [ffff88052a351a40] machine_kexec at ffffffff8103b40d
>   #1 [ffff88052a351ab0] crash_kexec at ffffffff810b98c5
>   #2 [ffff88052a351b80] oops_end at ffffffff815077d8
>   #3 [ffff88052a351bb0] no_context at ffffffff81048dff
>   #4 [ffff88052a351bf0] __bad_area_nosemaphore at ffffffff81048f80
>   #5 [ffff88052a351c40] bad_area_nosemaphore at ffffffff81049183
>   #6 [ffff88052a351c50] do_page_fault at ffffffff8150a32e
>   #7 [ffff88052a351d60] page_fault at ffffffff81506d55
>      [exception RIP: xs_tcp_reuse_connection+24]
>      RIP: ffffffffa0439518  RSP: ffff88052a351e10  RFLAGS: 00010282
>      RAX: ffff8824d1d523c0  RBX: ffff880d0d2d1000  RCX: ffff88407f3ae088
>      RDX: 0000000000000000  RSI: 0000000000001d00  RDI: ffff880d0d2d1000
>      RBP: ffff88052a351e20   R8: ffff88407f3af260   R9: ffffffff819ab880
>      R10: 0000000000000000  R11: ffff883f03de4820  R12: 00000000fffffff5
>      R13: ffff880d0d2d1000  R14: ffff8815e260b840  R15: 0000000000000000
>      ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
>   #8 [ffff88052a351e28] xs_tcp_setup_socket at ffffffffa043b01a [sunrpc]
>   #9 [ffff88052a351e58] process_one_work at ffffffff8108c0d9
> #10 [ffff88052a351ea8] worker_thread at ffffffff8108ca1a
> #11 [ffff88052a351ee8] kthread at ffffffff81090ff7
> #12 [ffff88052a351f48] kernel_thread_helper at ffffffff8150fe84
>
> In xs_tcp_setup_socket, if the xprt->sock is not NULL, it calls
> xs_tcp_reuse_connection. But in xs_tcp_reuse_connection, the sock and
> inet is seen to be zero when crash happened
>
> crash> sock_xprt.sock ffff880d0d2d1000
>    sock = 0x0
> crash> sock_xprt.inet ffff880d0d2d1000
>    inet = 0x0
>
> the xprt.state is 532 which is XPRT_CONNECTING|XPRT_BOUND|XPRT_INITIALIZED
>
> This looks like a race with xs_reset_transport().
>
> The fix is to wait the cancel and wait until connect_worker finishes.
>
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> ---
>   net/sunrpc/xprtsock.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 3b305ab..718c57f 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -869,6 +869,9 @@ static void xs_reset_transport(struct sock_xprt *transport)
>   	if (sk == NULL)
>   		return;
>   
> +	/* avoid a race with xs_tcp_setup_socket */
> +	cancel_delayed_work_sync(&transport->connect_worker);
> +
>   	transport->srcport = 0;
>   
>   	write_lock_bh(&sk->sk_callback_lock);

