From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone over NFS
Date: Wed, 13 May 2009 15:29:09 -0400
Message-ID: <x49k54ku7i2.fsf@segfault.boston.devel.redhat.com>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	<20090508120119.8c93cfd7.akpm@linux-foundation.org>
	<20090511081415.GL4694@kernel.dk>
	<x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	<20090511165826.GG4694@kernel.dk>
	<x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	<20090512204433.7eb69075.akpm@linux-foundation.org>
	<x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com> (Jeff Moyer's
	message of "Wed, 13 May 2009 10:58:39 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, netdev folks.  The summary here is:

A patch added in the 2.6.30 development cycle caused a performance
regression in my NFS iozone testing.  The patch in question is the
following:

commit 47a14ef1af48c696b214ac168f056ddc79793d0e
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Tue Oct 21 14:13:47 2008 -0400

    svcrpc: take advantage of tcp autotuning
 
which is also quoted below.  Using 8 nfsd threads, a single client doing
2GB of streaming read I/O goes from 107590 KB/s under 2.6.29 to 65558
KB/s under 2.6.30-rc4.  I also see more run to run variation under
2.6.30-rc4 using the deadline I/O scheduler on the server.  That
variation disappears (as does the performance regression) when reverting
the above commit.

Olga had the following to say about the regression:

>> On Wed, 13 May 2009 12:20:57 -0400 Olga Kornievskaia <aglo@citi.umich.edu> wrote:
>>
>>> I believe what you are seeing is how well TCP autotuning performs.
>>> What old NFS code was doing is disabling autotuning and instead using
>>> #nfsd thread to scale TCP recv window. You are providing an example of
>>> where setting TCP buffer sizes outperforms TCP autotuning. While this
>>> is a valid example, there is also an alternative example of where old
>>> NFS design hurts performance.

> We realize that decrease performance is a problem and understand that
> reverting the patch might be the appropriate course of action!

> But we are curious why this is happening. Jeff if it's not too much trouble
> could you generate tcpdumps for both cases. We are curious what are
> the max window sizes in both cases? Also could you give us your tcp and
> network sysctl values for the testing environment (both client and server
> values) that you can get with "sysctl -a | grep tcp" and also
> " | grep net.core".

The requested data can be found here:
http://people.redhat.com/jmoyer/iozone-regression.tar

> Poor performance using TCP autotuning can be demonstrated outside
> of NFS but using Iperf. It can be shown that iperf will work better if "-w"
> flag is used. When this flag is set, Iperf calls setsockopt() call which in
> the kernel turns off autotuning.
>
> As for fixing this it would be great if we could get some help from the
> TCP kernel folks?

And so I've CC'd netdev.

Jim Rees had the following to add:

> TCP autotuning can reduce performance by up to about 10% in some cases.
> Jeff found one of these cases.  While the autotuning penalty never exceeds
> 10% as far as I know, I can provide examples of other cases where autotuning
> improves nfsd performance by more than a factor of 100.
> 
> The right thing is to fix autotuning.  If autotuning is considered too
> broken to use, it should be turned off everywhere, not just in nfsd, as it
> hurts/benefits all TCP clients, not just nfs.

> This topic has been discussed before on netdev:
> http://www.spinics.net/lists/netdev/msg68650.html
> http://www.spinics.net/lists/netdev/msg68155.html

I'd like to point out that the penalty is much greater than 10% in my
case.

Here are the data points:

Jeff Moyer <jmoyer@redhat.com> writes:

>>> >> >> Jeff Moyer <jmoyer@redhat.com> wrote:
>>> >> >> 
>>> >> >> > Hi,
>>> >> >> > 
>>> >> >> > I've been working on CFQ improvements for interleaved I/Os between
>>> >> >> > processes, and noticed a regression in performance when using the
>>> >> >> > deadline I/O scheduler.  The test uses a server configured with a cciss
>>> >> >> > array and 1Gb/s ethernet.
>>> >> >> > 
>>> >> >> > The iozone command line was:
>>> >> >> >   iozone -s 2000000 -r 64 -f /mnt/test/testfile -i 1 -w
>>> >> >> > 
>>> >> >> > The numbers in the nfsd's row represent the number of nfsd "threads".
>>> >> >> > These numbers (in MB/s) represent the average of 5 runs.
>>> >> >> > 
>>> >> >> >                v2.6.29
>>> >> >> > 
>>> >> >> > nfsd's  |   1    |  2   |   4   |   8
>>> >> >> > --------+---------------+-------+------
>>> >> >> > deadline| 43207 | 67436 | 96289 | 107590
>>> >> >> > 
>>> >> >> >               2.6.30-rc1
>>> >> >> > 
>>> >> >> > nfsd's  |   1   |   2   |   4   |   8
>>> >> >> > --------+---------------+-------+------
>>> >> >> > deadline| 43732 | 68059 | 76659 | 83231
>>> >> >> > 
>>> >> >> >     2.6.30-rc3.block-for-linus
>>> >> >> > 
>>> >> >> > nfsd's  |   1   |   2   |   4   |   8
>>> >> >> > --------+---------------+-------+------
>>> >> >> > deadline| 46102 | 71151 | 83120 | 82330
>>> >> >> > 
>>> >> >> > 
>>> >> >> > Notice the drop for 4 and 8 threads.  It may be worth noting that the
>>> >> >> > default number of NFSD threads is 8.
>
> Just following up with numbers:
>
>   2.6.30-rc4
>
> nfsd's  |   8
> --------+------
> cfq     | 51632   (49791 52436 52308 51488 52141)
> deadline| 65558   (41675 42559 74820 87518 81221)
>
>    2.6.30-rc4 reverting the sunrpc "fix"
>
> nfsd's  |   8
> --------+------
> cfq     |  82513  (81650 82762 83147 82935 82073)
> deadline| 107827  (109730 106077 107175 108524 107632)
>
> The numbers in parenthesis are the individual runs.  Notice how
> 2.6.30-rc4 has some pretty wide variations for deadline.
>
>>> OK, I bisected this to the following commit.  The mount is done using
>>> NFSv3, by the way.
>>> 
>>> commit 47a14ef1af48c696b214ac168f056ddc79793d0e
>>> Author: Olga Kornievskaia <aglo@citi.umich.edu>
>>> Date:   Tue Oct 21 14:13:47 2008 -0400
>>> 
>>>     svcrpc: take advantage of tcp autotuning
>>>     
>>>     Allow the NFSv4 server to make use of TCP autotuning behaviour, which
>>>     was previously disabled by setting the sk_userlocks variable.
>>>     
>>>     Set the receive buffers to be big enough to receive the whole RPC
>>>     request, and set this for the listening socket, not the accept socket.
>>>     
>>>     Remove the code that readjusts the receive/send buffer sizes for the
>>>     accepted socket. Previously this code was used to influence the TCP
>>>     window management behaviour, which is no longer needed when autotuning
>>>     is enabled.
>>>     
>>>     This can improve IO bandwidth on networks with high bandwidth-delay
>>>     products, where a large tcp window is required.  It also simplifies
>>>     performance tuning, since getting adequate tcp buffers previously
>>>     required increasing the number of nfsd threads.
>>>     
>>>     Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
>>>     Cc: Jim Rees <rees@umich.edu>
>>>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>> 
>>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>>> index 5763e64..7a2a90f 100644
>>> --- a/net/sunrpc/svcsock.c
>>> +++ b/net/sunrpc/svcsock.c
>>> @@ -345,7 +345,6 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
>>>  	lock_sock(sock->sk);
>>>  	sock->sk->sk_sndbuf = snd * 2;
>>>  	sock->sk->sk_rcvbuf = rcv * 2;
>>> -	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
>>>  	release_sock(sock->sk);
>>>  #endif
>>>  }
>>> @@ -797,23 +796,6 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>>>  		test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags),
>>>  		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
>>>  
>>> -	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
>>> -		/* sndbuf needs to have room for one request
>>> -		 * per thread, otherwise we can stall even when the
>>> -		 * network isn't a bottleneck.
>>> -		 *
>>> -		 * We count all threads rather than threads in a
>>> -		 * particular pool, which provides an upper bound
>>> -		 * on the number of threads which will access the socket.
>>> -		 *
>>> -		 * rcvbuf just needs to be able to hold a few requests.
>>> -		 * Normally they will be removed from the queue
>>> -		 * as soon a a complete request arrives.
>>> -		 */
>>> -		svc_sock_setbufsize(svsk->sk_sock,
>>> -				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
>>> -				    3 * serv->sv_max_mesg);
>>> -
>>>  	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>>>  
>>>  	/* Receive data. If we haven't got the record length yet, get
>>> @@ -1061,15 +1043,6 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
>>>  
>>>  		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
>>>  
>>> -		/* initialise setting must have enough space to
>>> -		 * receive and respond to one request.
>>> -		 * svc_tcp_recvfrom will re-adjust if necessary
>>> -		 */
>>> -		svc_sock_setbufsize(svsk->sk_sock,
>>> -				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
>>> -				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
>>> -
>>> -		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
>>>  		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>>>  		if (sk->sk_state != TCP_ESTABLISHED)
>>>  			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
>>> @@ -1140,8 +1113,14 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
>>>  	/* Initialize the socket */
>>>  	if (sock->type == SOCK_DGRAM)
>>>  		svc_udp_init(svsk, serv);
>>> -	else
>>> +	else {
>>> +		/* initialise setting must have enough space to
>>> +		 * receive and respond to one request.
>>> +		 */
>>> +		svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
>>> +					4 * serv->sv_max_mesg);
>>>  		svc_tcp_init(svsk, serv);
>>> +	}
>>>  
>>>  	/*
>>>  	 * We start one listener per sv_serv.  We want AF_INET
