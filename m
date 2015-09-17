Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:56251 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbIQVsM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 17:48:12 -0400
Date: Thu, 17 Sep 2015 22:47:58 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: AnnaSchumaker <anna.schumaker@netapp.com>, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Message-ID: <20150917214758.GW21084@n2100.arm.linux.org.uk>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
 <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150911143347.GQ21084@n2100.arm.linux.org.uk>
 <20150911150613.GR21084@n2100.arm.linux.org.uk>
 <1441984723.4619.61.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150911162416.GV21084@n2100.arm.linux.org.uk>
 <20150911164937.GW21084@n2100.arm.linux.org.uk>
 <20150917135705.GQ21084@n2100.arm.linux.org.uk>
 <1442499509.2865.16.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1442499509.2865.16.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 17, 2015 at 10:18:29AM -0400, Trond Myklebust wrote:
> Hi Russell,
> 
> On Thu, 2015-09-17 at 14:57 +0100, Russell King - ARM Linux wrote:
> > On Fri, Sep 11, 2015 at 05:49:38PM +0100, Russell King - ARM Linux
> > wrote:
> > > Following that idea, I just tried the patch below, and it seems to
> > > work.
> > > I don't know whether it handles all cases after a call to
> > > kernel_connect(),
> > > but it stops the multiple connection attempts:
> > > 
> > >   1   0.000000 armada388 -> n2100 TCP 1009→nfs [SYN] Seq=3794066539
> > > Win=28560 Len=0 MSS=1440 SACK_PERM=1 TSval=15712 TSecr=870317691
> > > WS=128
> > >   2   0.000414 n2100 -> armada388 TCP nfs→1009 [SYN, ACK]
> > > Seq=1884476522 Ack=3794066540 Win=28560 Len=0 MSS=1440 SACK_PERM=1
> > > TSval=870318939 TSecr=15712 WS=64
> > >   3   0.000787 armada388 -> n2100 TCP 1009→nfs [ACK] Seq=3794066540
> > > Ack=1884476523 Win=28672 Len=0 TSval=15712 TSecr=870318939
> > >   4   0.001304 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > > 0x905379cc, [Check: RD LU MD XT DL]
> > >   5   0.001566 n2100 -> armada388 TCP nfs→1009 [ACK] Seq=1884476523
> > > Ack=3794066660 Win=28608 Len=0 TSval=870318939 TSecr=15712
> > >   6   0.001640 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > > 0x905379cc, [Check: RD LU MD XT DL]
> > >   7   0.001866 n2100 -> armada388 TCP nfs→1009 [ACK] Seq=1884476523
> > > Ack=3794066780 Win=28608 Len=0 TSval=870318939 TSecr=15712
> > >   8   0.003070 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 4),
> > > [Allowed: RD LU MD XT DL]
> > >   9   0.003415 armada388 -> n2100 TCP 1009→nfs [ACK] Seq=3794066780
> > > Ack=1884476647 Win=28672 Len=0 TSval=15712 TSecr=870318939
> > >  10   0.003592 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > > 0xe15fc9c9, [Check: RD LU MD XT DL]
> > >  11   0.004354 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 6),
> > > [Allowed: RD LU MD XT DL]
> > >  12   0.004682 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > > 0xe15fc9c9, [Check: RD LU MD XT DL]
> > >  13   0.005365 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 10),
> > > [Allowed: RD LU MD XT DL]
> > >  14   0.005701 armada388 -> n2100 NFS V3 GETATTR Call, FH:
> > > 0xe15fc9c9
> > > ...
> > 
> > NFS people - any comments on this patch?  Is it the correct way to
> > solve
> > this problem (please see the first message in this thread for the
> > problem.)
> > Without this patch, NFS is unusable as it tries to launch multiple
> > new
> > connections from the same port to the NFS server without giving the
> > NFS
> > server time to respond and establish the TCP connection.
> 
> I agree that it addresses a real problem here, however there are a
> couple of issues with the patch itself:
> 
> AFAICS, the 2 possible next states for SYN_SENT are TCP_ESTABLISHED and
> TCP_CLOSE, so if the connection attempt fails, this patch leaves the
> XPRT_CONNECTING flag set.
> There is also the issue that clearing XPRT_CONNECTING in TCP_FIN_WAIT1,
> TCP_CLOSE_WAIT and TCP_CLOSING could interfere with another connection
> attempt by canceling the XPRT_CONNECTING state.
> 
> How about the following? It is based on your patch, but adds a check to
> ensure that xs_tcp_state_change() doesn't clear the 'connecting' state
> more than once (which could otherwise still happen in the TCP_CLOSE
> case).

This patch also seems to fix the problem I've been seeing.

Yes, I wasn't sure about my patch - I didn't spend much time properly
reading and understanding the sunrpc code, beyond analysing what was
going on to cause the problem and deciding on a way to stop it happening.
I really wasn't sure that clearing the connecting flag everywhere I did
was the right thing, which is why I didn't send the patch properly
dressed up.

> 8<-------------------------------------------------------------------
> >From 4dbfdebbc09982a9248866f8256549456e2b2efd Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Wed, 16 Sep 2015 23:43:17 -0400
> Subject: [PATCH] SUNRPC: Ensure that we wait for connections to complete
>  before retrying
> 
> Commit 718ba5b87343, moved the responsibility for unlocking the socket to
> xs_tcp_setup_socket, meaning that the socket will be unlocked before we
> know that it has finished trying to connect. The following patch is based on
> an initial patch by Russell King to ensure that we delay clearing the
> XPRT_SOCK_CONNECTING flag until we either know that we failed to initiate
> a connection attempt, or the connection attempt itself failed.
> 
> Fixes: 718ba5b87343 ("SUNRPC: Add helpers to prevent socket create from racing")
> Reported-by: Russell King <linux@arm.linux.org.uk>

Reported-by: Russell King <rmk+kernel@arm.linux.org.uk>
Tested-by: Russell King <rmk+kernel@arm.linux.org.uk>

Thanks.

> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  include/linux/sunrpc/xprtsock.h |  3 +++
>  net/sunrpc/xprtsock.c           | 11 ++++++++---
>  2 files changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
> index 7591788e9fbf..357e44c1a46b 100644
> --- a/include/linux/sunrpc/xprtsock.h
> +++ b/include/linux/sunrpc/xprtsock.h
> @@ -42,6 +42,7 @@ struct sock_xprt {
>  	/*
>  	 * Connection of transports
>  	 */
> +	unsigned long		sock_state;
>  	struct delayed_work	connect_worker;
>  	struct sockaddr_storage	srcaddr;
>  	unsigned short		srcport;
> @@ -76,6 +77,8 @@ struct sock_xprt {
>   */
>  #define TCP_RPC_REPLY		(1UL << 6)
>  
> +#define XPRT_SOCK_CONNECTING	1U
> +
>  #endif /* __KERNEL__ */
>  
>  #endif /* _LINUX_SUNRPC_XPRTSOCK_H */
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7be90bc1a7c2..5bac27983e2a 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1435,6 +1435,7 @@ out:
>  static void xs_tcp_state_change(struct sock *sk)
>  {
>  	struct rpc_xprt *xprt;
> +	struct sock_xprt *transport;
>  
>  	read_lock_bh(&sk->sk_callback_lock);
>  	if (!(xprt = xprt_from_sock(sk)))
> @@ -1446,13 +1447,12 @@ static void xs_tcp_state_change(struct sock *sk)
>  			sock_flag(sk, SOCK_ZAPPED),
>  			sk->sk_shutdown);
>  
> +	transport = container_of(xprt, struct sock_xprt, xprt);
>  	trace_rpc_socket_state_change(xprt, sk->sk_socket);
>  	switch (sk->sk_state) {
>  	case TCP_ESTABLISHED:
>  		spin_lock(&xprt->transport_lock);
>  		if (!xprt_test_and_set_connected(xprt)) {
> -			struct sock_xprt *transport = container_of(xprt,
> -					struct sock_xprt, xprt);
>  
>  			/* Reset TCP record info */
>  			transport->tcp_offset = 0;
> @@ -1461,6 +1461,8 @@ static void xs_tcp_state_change(struct sock *sk)
>  			transport->tcp_flags =
>  				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
>  			xprt->connect_cookie++;
> +			clear_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
> +			xprt_clear_connecting(xprt);
>  
>  			xprt_wake_pending_tasks(xprt, -EAGAIN);
>  		}
> @@ -1496,6 +1498,9 @@ static void xs_tcp_state_change(struct sock *sk)
>  		smp_mb__after_atomic();
>  		break;
>  	case TCP_CLOSE:
> +		if (test_and_clear_bit(XPRT_SOCK_CONNECTING,
> +					&transport->sock_state))
> +			xprt_clear_connecting(xprt);
>  		xs_sock_mark_closed(xprt);
>  	}
>   out:
> @@ -2179,6 +2184,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>  	/* Tell the socket layer to start connecting... */
>  	xprt->stat.connect_count++;
>  	xprt->stat.connect_start = jiffies;
> +	set_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
>  	ret = kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
>  	switch (ret) {
>  	case 0:
> @@ -2240,7 +2246,6 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>  	case -EINPROGRESS:
>  	case -EALREADY:
>  		xprt_unlock_connect(xprt, transport);
> -		xprt_clear_connecting(xprt);
>  		return;
>  	case -EINVAL:
>  		/* Happens, for instance, if the user specified a link
> -- 
> 2.4.3
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> 
> 
> 

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
