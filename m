From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: [RFC] [PATCH 1/1] tcp-autotuning-on-recv-window-fix
Date: Thu, 23 Oct 2008 11:17:37 -0400
Message-ID: <49009591.2000306@citi.umich.edu>
References: <48FE200A.6070805@citi.umich.edu> <20081022194605.GA4409@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:22133 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753797AbYJWPRk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2008 11:17:40 -0400
In-Reply-To: <20081022194605.GA4409@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> On Tue, Oct 21, 2008 at 02:31:38PM -0400, Olga Kornievskaia wrote:
>   
>> From: Olga Kornievskaia <aglo@citi.umich.edu>
>> Date: Tue, 21 Oct 2008 14:13:47 -0400
>> Subject: [RFC] [PATCH 1/1] tcp-autotuning-on-recv-window-fix
>>
>> This patch allows for the NFSv4 server to make use of TCP autotuning behaviour
>> which was previously disabled by setting sk_userlocks variable. 
>>
>> This patch sets the receive buffers to be big enough to receive the whole 
>> RPC request. This buffer size had to be set for the listening socket and not
>> the accept socket as it was previously done. 
>>     
>
> The point there being that our previous buffer-size settings were made
> too late to actually have an affect?
>   
I would say they didn't have a desired effect. Actually modifying the 
receive/send buffer sizes on the accept socket does have an influence on 
the TCP behavior. I won't claim I understand what happens but from my 
observations I see that it messed up TCP autotuning behavior. It leads 
to an advertised window to be "clamped" at the value set for the 
listening socket.
>> This patch removes the code that readjust the receive/send buffer sizes for
>> the accepted socket. Previously this code was used to influence the TCP
>> window management behaviour which is no longer needed when autotuning is 
>> enabled. 
>>     
>
> Could we get a really brief summary of the performance improvement for a
> high-speed network, to include in the commit message?
>   
Here's a pick from some LAN performance #s: w/o 237479Mb/s => w/ 343669Mb/s.
> The one remaining worry I recall is that we assume the tcp autotuning
> never decreases the size of the buffer below the size we initially
> requested.  Apparently that assumption is true.  There's some worry
> about whether that's true by design or merely true of the current
> implementation.
>
> That doesn't look like a big worry--I'm inclined to apply this patch as
> is--but moving the sk_{rcv,snd}buf assignments to a simple function in
> the networking code and documenting the requirements there might be a
> nice thing to do (as a separate patch).
>   
Are you asking for svc_sock_setbufsize() function in svcsock.c to be 
moved to svc_xprt.c? Why? It really belongs in svcsock.c with the rest 
of the socket management code.
> --b.
>
>   
>> Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
>> ---
>>  net/sunrpc/svcsock.c |   35 +++++++----------------------------
>>  1 files changed, 7 insertions(+), 28 deletions(-)
>>
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index 3e65719..4bb535e 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -349,7 +349,6 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
>>  	lock_sock(sock->sk);
>>  	sock->sk->sk_sndbuf = snd * 2;
>>  	sock->sk->sk_rcvbuf = rcv * 2;
>> -	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
>>  	release_sock(sock->sk);
>>  #endif
>>  }
>> @@ -801,23 +800,6 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>>  		test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags),
>>  		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
>>  
>> -	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
>> -		/* sndbuf needs to have room for one request
>> -		 * per thread, otherwise we can stall even when the
>> -		 * network isn't a bottleneck.
>> -		 *
>> -		 * We count all threads rather than threads in a
>> -		 * particular pool, which provides an upper bound
>> -		 * on the number of threads which will access the socket.
>> -		 *
>> -		 * rcvbuf just needs to be able to hold a few requests.
>> -		 * Normally they will be removed from the queue
>> -		 * as soon a a complete request arrives.
>> -		 */
>> -		svc_sock_setbufsize(svsk->sk_sock,
>> -				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
>> -				    3 * serv->sv_max_mesg);
>> -
>>  	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>>  
>>  	/* Receive data. If we haven't got the record length yet, get
>> @@ -1065,15 +1047,6 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
>>  
>>  		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
>>  
>> -		/* initialise setting must have enough space to
>> -		 * receive and respond to one request.
>> -		 * svc_tcp_recvfrom will re-adjust if necessary
>> -		 */
>> -		svc_sock_setbufsize(svsk->sk_sock,
>> -				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
>> -				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
>> -
>> -		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
>>  		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>>  		if (sk->sk_state != TCP_ESTABLISHED)
>>  			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
>> @@ -1143,8 +1116,14 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
>>  	/* Initialize the socket */
>>  	if (sock->type == SOCK_DGRAM)
>>  		svc_udp_init(svsk, serv);
>> -	else
>> +	else {
>> +		/* initialise setting must have enough space to
>>     
>
> s/initialise/initial/
>
>   
>> +		 * receive and respond to one request.
>> +		 */
>> +		svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
>> +					4 * serv->sv_max_mesg);
>>  		svc_tcp_init(svsk, serv);
>> +	}
>>  
>>  	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
>>  				svsk, svsk->sk_sk);
>> -- 
>> 1.5.0.2
>>
>>     
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   
