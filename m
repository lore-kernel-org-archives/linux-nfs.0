From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
 over NFS
Date: Wed, 13 May 2009 19:45:38 -0400
Message-ID: <1242258338.5407.244.camel@heimdal.trondhjem.org>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	 <20090508120119.8c93cfd7.akpm@linux-foundation.org>
	 <20090511081415.GL4694@kernel.dk>
	 <x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	 <20090511165826.GG4694@kernel.dk>
	 <x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	 <20090512204433.7eb69075.akpm@linux-foundation.org>
	 <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
	 <x49k54ku7i2.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <x49k54ku7i2.fsf@segfault.boston.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-05-13 at 15:29 -0400, Jeff Moyer wrote:
> Hi, netdev folks.  The summary here is:
> 
> A patch added in the 2.6.30 development cycle caused a performance
> regression in my NFS iozone testing.  The patch in question is the
> following:
> 
> commit 47a14ef1af48c696b214ac168f056ddc79793d0e
> Author: Olga Kornievskaia <aglo@citi.umich.edu>
> Date:   Tue Oct 21 14:13:47 2008 -0400
> 
>     svcrpc: take advantage of tcp autotuning
>  
> which is also quoted below.  Using 8 nfsd threads, a single client doing
> 2GB of streaming read I/O goes from 107590 KB/s under 2.6.29 to 65558
> KB/s under 2.6.30-rc4.  I also see more run to run variation under
> 2.6.30-rc4 using the deadline I/O scheduler on the server.  That
> variation disappears (as does the performance regression) when reverting
> the above commit.

It looks to me as if we've got a bug in the svc_tcp_has_wspace() helper
function. I can see no reason why we should stop processing new incoming
RPC requests just because the send buffer happens to be 2/3 full. If we
see that we have space for another reply, then we should just go for it.
OTOH, we do want to ensure that the SOCK_NOSPACE flag remains set, so
that the TCP layer knows that we're congested, and that we'd like it to
increase the send window size, please.

Could you therefore please see if the following (untested) patch helps?

Cheers
  Trond
---------------------------------------------------------------------
>From 1545cbda1b1cda2500cb9db3c760a05fc4f6ed4d Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Wed, 13 May 2009 19:44:58 -0400
Subject: [PATCH] SUNRPC: Fix the TCP server's send buffer accounting

Currently, the sunrpc server is refusing to allow us to process new RPC
calls if the TCP send buffer is 2/3 full, even if we do actually have
enough free space to guarantee that we can send another request.
The following patch fixes svc_tcp_has_wspace() so that we only stop
processing requests if we know that the socket buffer cannot possibly fit
another reply.

It also fixes the tcp write_space() callback so that we only clear the
SOCK_NOSPACE flag when the TCP send buffer is less than 2/3 full.
This should ensure that the send window will grow as per the standard TCP
socket code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/svcsock.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index af31988..8962355 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -386,6 +386,15 @@ static void svc_write_space(struct sock *sk)
 	}
 }
 
+static void svc_tcp_write_space(struct sock *sk)
+{
+	struct socket *sock = sk->sk_socket;
+
+	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk) && sock)
+		clear_bit(SOCK_NOSPACE, &sock->flags);
+	svc_write_space(sk);
+}
+
 /*
  * Copy the UDP datagram's destination address to the rqstp structure.
  * The 'destination' address in this case is the address to which the
@@ -964,23 +973,14 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int required;
-	int wspace;
-
-	/*
-	 * Set the SOCK_NOSPACE flag before checking the available
-	 * sock space.
-	 */
-	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	required = atomic_read(&svsk->sk_xprt.xpt_reserved) + serv->sv_max_mesg;
-	wspace = sk_stream_wspace(svsk->sk_sk);
-
-	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
-		return 0;
-	if (required * 2 > wspace)
-		return 0;
 
-	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	required = (atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg) * 2;
+	if (sk_stream_wspace(svsk->sk_sk) < required)
+		goto out_nospace;
 	return 1;
+out_nospace:
+	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	return 0;
 }
 
 static struct svc_xprt *svc_tcp_create(struct svc_serv *serv,
@@ -1036,7 +1036,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 		dprintk("setting up TCP socket for reading\n");
 		sk->sk_state_change = svc_tcp_state_change;
 		sk->sk_data_ready = svc_tcp_data_ready;
-		sk->sk_write_space = svc_write_space;
+		sk->sk_write_space = svc_tcp_write_space;
 
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
-- 
1.6.0.4



