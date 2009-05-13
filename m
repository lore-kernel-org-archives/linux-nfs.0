Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42448 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751914AbZEMDuV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 May 2009 23:50:21 -0400
Date: Tue, 12 May 2009 20:44:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        "J. Bruce Fields" <bfields@fieldses.org>, Jim Rees <rees@umich.edu>,
        linux-nfs@vger.kernel.org
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
 over NFS
Message-Id: <20090512204433.7eb69075.akpm@linux-foundation.org>
In-Reply-To: <x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	<20090508120119.8c93cfd7.akpm@linux-foundation.org>
	<20090511081415.GL4694@kernel.dk>
	<x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	<20090511165826.GG4694@kernel.dk>
	<x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

(obvious cc's added...)

It's an iozone performance regression.

On Tue, 12 May 2009 23:29:30 -0400 Jeff Moyer <jmoyer@redhat.com> wrote:

> Jens Axboe <jens.axboe@oracle.com> writes:
> 
> > On Mon, May 11 2009, Jeff Moyer wrote:
> >> Jens Axboe <jens.axboe@oracle.com> writes:
> >> 
> >> > On Fri, May 08 2009, Andrew Morton wrote:
> >> >> On Thu, 23 Apr 2009 10:01:58 -0400
> >> >> Jeff Moyer <jmoyer@redhat.com> wrote:
> >> >> 
> >> >> > Hi,
> >> >> > 
> >> >> > I've been working on CFQ improvements for interleaved I/Os between
> >> >> > processes, and noticed a regression in performance when using the
> >> >> > deadline I/O scheduler.  The test uses a server configured with a cciss
> >> >> > array and 1Gb/s ethernet.
> >> >> > 
> >> >> > The iozone command line was:
> >> >> >   iozone -s 2000000 -r 64 -f /mnt/test/testfile -i 1 -w
> >> >> > 
> >> >> > The numbers in the nfsd's row represent the number of nfsd "threads".
> >> >> > These numbers (in MB/s) represent the average of 5 runs.
> >> >> > 
> >> >> >                v2.6.29
> >> >> > 
> >> >> > nfsd's  |   1    |  2   |   4   |   8
> >> >> > --------+---------------+-------+------
> >> >> > deadline| 43207 | 67436 | 96289 | 107590
> >> >> > 
> >> >> >               2.6.30-rc1
> >> >> > 
> >> >> > nfsd's  |   1   |   2   |   4   |   8
> >> >> > --------+---------------+-------+------
> >> >> > deadline| 43732 | 68059 | 76659 | 83231
> >> >> > 
> >> >> >     2.6.30-rc3.block-for-linus
> >> >> > 
> >> >> > nfsd's  |   1   |   2   |   4   |   8
> >> >> > --------+---------------+-------+------
> >> >> > deadline| 46102 | 71151 | 83120 | 82330
> >> >> > 
> >> >> > 
> >> >> > Notice the drop for 4 and 8 threads.  It may be worth noting that the
> >> >> > default number of NFSD threads is 8.
> >> >> > 
> >> >> 
> >> >> I guess we should ask Rafael to add this to the post-2.6.29 regression
> >> >> list.
> >> >
> >> > I agree. It'd be nice to bisect this one down, I'm guessing some mm
> >> > change has caused this writeout regression.
> >> 
> >> It's not writeout, it's a read test.
> >
> > Doh sorry, I even ran these tests as well a few weeks back. So perhaps
> > some read-ahead change, I didn't look into it. FWIW, on a single SATA
> > drive here, it didn't show any difference.
> 
> OK, I bisected this to the following commit.  The mount is done using
> NFSv3, by the way.
> 
> commit 47a14ef1af48c696b214ac168f056ddc79793d0e
> Author: Olga Kornievskaia <aglo@citi.umich.edu>
> Date:   Tue Oct 21 14:13:47 2008 -0400
> 
>     svcrpc: take advantage of tcp autotuning
>     
>     Allow the NFSv4 server to make use of TCP autotuning behaviour, which
>     was previously disabled by setting the sk_userlocks variable.
>     
>     Set the receive buffers to be big enough to receive the whole RPC
>     request, and set this for the listening socket, not the accept socket.
>     
>     Remove the code that readjusts the receive/send buffer sizes for the
>     accepted socket. Previously this code was used to influence the TCP
>     window management behaviour, which is no longer needed when autotuning
>     is enabled.
>     
>     This can improve IO bandwidth on networks with high bandwidth-delay
>     products, where a large tcp window is required.  It also simplifies
>     performance tuning, since getting adequate tcp buffers previously
>     required increasing the number of nfsd threads.
>     
>     Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
>     Cc: Jim Rees <rees@umich.edu>
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 5763e64..7a2a90f 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -345,7 +345,6 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
>  	lock_sock(sock->sk);
>  	sock->sk->sk_sndbuf = snd * 2;
>  	sock->sk->sk_rcvbuf = rcv * 2;
> -	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
>  	release_sock(sock->sk);
>  #endif
>  }
> @@ -797,23 +796,6 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  		test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags),
>  		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
>  
> -	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
> -		/* sndbuf needs to have room for one request
> -		 * per thread, otherwise we can stall even when the
> -		 * network isn't a bottleneck.
> -		 *
> -		 * We count all threads rather than threads in a
> -		 * particular pool, which provides an upper bound
> -		 * on the number of threads which will access the socket.
> -		 *
> -		 * rcvbuf just needs to be able to hold a few requests.
> -		 * Normally they will be removed from the queue
> -		 * as soon a a complete request arrives.
> -		 */
> -		svc_sock_setbufsize(svsk->sk_sock,
> -				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
> -				    3 * serv->sv_max_mesg);
> -
>  	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  
>  	/* Receive data. If we haven't got the record length yet, get
> @@ -1061,15 +1043,6 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
>  
>  		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
>  
> -		/* initialise setting must have enough space to
> -		 * receive and respond to one request.
> -		 * svc_tcp_recvfrom will re-adjust if necessary
> -		 */
> -		svc_sock_setbufsize(svsk->sk_sock,
> -				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
> -				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
> -
> -		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
>  		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  		if (sk->sk_state != TCP_ESTABLISHED)
>  			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
> @@ -1140,8 +1113,14 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
>  	/* Initialize the socket */
>  	if (sock->type == SOCK_DGRAM)
>  		svc_udp_init(svsk, serv);
> -	else
> +	else {
> +		/* initialise setting must have enough space to
> +		 * receive and respond to one request.
> +		 */
> +		svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
> +					4 * serv->sv_max_mesg);
>  		svc_tcp_init(svsk, serv);
> +	}
>  
>  	/*
>  	 * We start one listener per sv_serv.  We want AF_INET
