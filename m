Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34639 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbbIKNEz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 09:04:55 -0400
Message-ID: <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Date: Fri, 11 Sep 2015 06:04:51 -0700
In-Reply-To: <20150911113839.GO21084@n2100.arm.linux.org.uk>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2015-09-11 at 12:38 +0100, Russell King - ARM Linux wrote:
> I have a recent Marvell Armada 388 board here which uses the mvneta
> driver.  I'm seeing some weird effects with NFS with it acting as a
> client.  Unfortunately, the board does not have a functional RTC.
> 
> The NFS server is the same NFS server that I've used for years with
> multiple other clients (it's my main NFS server) and it continues to
> support all other clients without any ill effect.  The NFS server
> kernel is rather old now, being a 3.x kernel.
> 
> The NFS client appears to connect using TCP/IPv6 and initially is
> accessible.  Everything appears to work normally, and then the NFS
> server appears to stop responding.
> 
> Running tcpdump on the NFS server, and then dumping the captured
> packets
> with tshark (because tcpdump appears not to understand IPv6 SYNs on
> the
> NFS port) shows:
> 
>   3   0.030036 armada388 -> n2100 TCP 843→nfs [SYN] Seq=936803106
> Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=892366 TSecr=0 WS=128

>   4   0.030409 n2100 -> armada388 TCP nfs→843 [SYN, ACK] Seq=409465870
> Ack=936803107 Win=28560 Len=0 MSS=1440 SACK_PERM=1
>  TSval=818169117 TSecr=892366 WS=64

>   5   0.030493 armada388 -> n2100 TCP [TCP Port numbers reused]
> 843→nfs [SYN] Seq=936803633 Win=28800 Len=0 MSS=1440 SACK_PERM=1
> TSval=892366 TSecr=0 WS=128

Yes, this packet looks very wrong. Like two simultaneous connect with
same source port. It is not a retransmit (Seq numbers differ)

>   6   0.030699 n2100 -> armada388 TCP nfs→843 [RST, ACK] Seq=0
> Ack=936803634 Win=0 Len=0
>   7   0.030766 armada388 -> n2100 TCP 843→nfs [RST] Seq=936803107
> Win=0 Len=0

I suspect port reuse in NFS being broken.

Have you tried to apply

commit 099392048cd443349c50310f7fdc96070e40f4e7
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Sat Aug 29 19:11:21 2015 -0700

    SUNRPC: Prevent SYN+SYNACK+RST storms
    
    Add a shutdown() call before we release the socket in order to ensure the
    reset is sent before we try to reconnect.
    
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 214ca9dfb14e..7be90bc1a7c2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -822,6 +822,8 @@ static void xs_reset_transport(struct sock_xprt *transport)
        if (atomic_read(&transport->xprt.swapper))
                sk_clear_memalloc(sk);
 
+       kernel_sock_shutdown(sock, SHUT_RDWR);
+
        write_lock_bh(&sk->sk_callback_lock);
        transport->inet = NULL;
        transport->sock = NULL;


