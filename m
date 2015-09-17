Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:55424 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbIQN5U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 09:57:20 -0400
Date: Thu, 17 Sep 2015 14:57:07 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        AnnaSchumaker <anna.schumaker@netapp.com>
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Message-ID: <20150917135705.GQ21084@n2100.arm.linux.org.uk>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
 <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150911143347.GQ21084@n2100.arm.linux.org.uk>
 <20150911150613.GR21084@n2100.arm.linux.org.uk>
 <1441984723.4619.61.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150911162416.GV21084@n2100.arm.linux.org.uk>
 <20150911164937.GW21084@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20150911164937.GW21084@n2100.arm.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2015 at 05:49:38PM +0100, Russell King - ARM Linux wrote:
> Following that idea, I just tried the patch below, and it seems to work.
> I don't know whether it handles all cases after a call to kernel_connect(),
> but it stops the multiple connection attempts:
> 
>   1   0.000000 armada388 -> n2100 TCP 1009→nfs [SYN] Seq=3794066539 Win=28560 Len=0 MSS=1440 SACK_PERM=1 TSval=15712 TSecr=870317691 WS=128
>   2   0.000414 n2100 -> armada388 TCP nfs→1009 [SYN, ACK] Seq=1884476522 Ack=3794066540 Win=28560 Len=0 MSS=1440 SACK_PERM=1 TSval=870318939 TSecr=15712 WS=64
>   3   0.000787 armada388 -> n2100 TCP 1009→nfs [ACK] Seq=3794066540 Ack=1884476523 Win=28672 Len=0 TSval=15712 TSecr=870318939
>   4   0.001304 armada388 -> n2100 NFS V3 ACCESS Call, FH: 0x905379cc, [Check: RD LU MD XT DL]
>   5   0.001566 n2100 -> armada388 TCP nfs→1009 [ACK] Seq=1884476523 Ack=3794066660 Win=28608 Len=0 TSval=870318939 TSecr=15712
>   6   0.001640 armada388 -> n2100 NFS V3 ACCESS Call, FH: 0x905379cc, [Check: RD LU MD XT DL]
>   7   0.001866 n2100 -> armada388 TCP nfs→1009 [ACK] Seq=1884476523 Ack=3794066780 Win=28608 Len=0 TSval=870318939 TSecr=15712
>   8   0.003070 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 4), [Allowed: RD LU MD XT DL]
>   9   0.003415 armada388 -> n2100 TCP 1009→nfs [ACK] Seq=3794066780 Ack=1884476647 Win=28672 Len=0 TSval=15712 TSecr=870318939
>  10   0.003592 armada388 -> n2100 NFS V3 ACCESS Call, FH: 0xe15fc9c9, [Check: RD LU MD XT DL]
>  11   0.004354 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 6), [Allowed: RD LU MD XT DL]
>  12   0.004682 armada388 -> n2100 NFS V3 ACCESS Call, FH: 0xe15fc9c9, [Check: RD LU MD XT DL]
>  13   0.005365 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 10), [Allowed: RD LU MD XT DL]
>  14   0.005701 armada388 -> n2100 NFS V3 GETATTR Call, FH: 0xe15fc9c9
> ...

NFS people - any comments on this patch?  Is it the correct way to solve
this problem (please see the first message in this thread for the problem.)
Without this patch, NFS is unusable as it tries to launch multiple new
connections from the same port to the NFS server without giving the NFS
server time to respond and establish the TCP connection.

> 
>  net/sunrpc/xprtsock.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index ff5b6a2e62c3..c456d6e51c56 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1450,6 +1450,7 @@ static void xs_tcp_state_change(struct sock *sk)
>  	switch (sk->sk_state) {
>  	case TCP_ESTABLISHED:
>  		spin_lock(&xprt->transport_lock);
> +		xprt_clear_connecting(xprt);
>  		if (!xprt_test_and_set_connected(xprt)) {
>  			struct sock_xprt *transport = container_of(xprt,
>  					struct sock_xprt, xprt);
> @@ -1474,12 +1475,14 @@ static void xs_tcp_state_change(struct sock *sk)
>  		smp_mb__before_atomic();
>  		clear_bit(XPRT_CONNECTED, &xprt->state);
>  		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> +		clear_bit(XPRT_CONNECTING, &xprt->state);		
>  		smp_mb__after_atomic();
>  		break;
>  	case TCP_CLOSE_WAIT:
>  		/* The server initiated a shutdown of the socket */
>  		xprt->connect_cookie++;
>  		clear_bit(XPRT_CONNECTED, &xprt->state);
> +		clear_bit(XPRT_CONNECTING, &xprt->state);
>  		xs_tcp_force_close(xprt);
>  	case TCP_CLOSING:
>  		/*
> @@ -1493,6 +1496,7 @@ static void xs_tcp_state_change(struct sock *sk)
>  		set_bit(XPRT_CLOSING, &xprt->state);
>  		smp_mb__before_atomic();
>  		clear_bit(XPRT_CONNECTED, &xprt->state);
> +		clear_bit(XPRT_CONNECTING, &xprt->state);
>  		smp_mb__after_atomic();
>  		break;
>  	case TCP_CLOSE:
> @@ -2237,11 +2241,13 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>  		xs_tcp_force_close(xprt);
>  		break;
>  	case 0:
> -	case -EINPROGRESS:
>  	case -EALREADY:
>  		xprt_unlock_connect(xprt, transport);
>  		xprt_clear_connecting(xprt);
>  		return;
> +	case -EINPROGRESS:
> +		xprt_unlock_connect(xprt, transport);
> +		return;
>  	case -EINVAL:
>  		/* Happens, for instance, if the user specified a link
>  		 * local IPv6 address without a scope-id.
> 
> 
> -- 
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
