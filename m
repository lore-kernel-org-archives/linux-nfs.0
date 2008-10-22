From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: [RFC] [PATCH 1/1] tcp-autotuning-on-recv-window-fix
Date: Wed, 22 Oct 2008 14:30:47 -0700
Message-ID: <48FF9B87.6050909@gmail.com>
References: <48FE200A.6070805@citi.umich.edu> <20081022194605.GA4409@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:29965 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331AbYJVVay (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Oct 2008 17:30:54 -0400
Received: by yw-out-2324.google.com with SMTP id 9so2730ywe.1
        for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2008 14:30:52 -0700 (PDT)
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
>   
>> This patch removes the code that readjust the receive/send buffer sizes for
>> the accepted socket. Previously this code was used to influence the TCP
>> window management behaviour which is no longer needed when autotuning is 
>> enabled. 
>>     
>
> Could we get a really brief summary of the performance improvement for a
> high-speed network, to include in the commit message?
>
> The one remaining worry I recall is that we assume the tcp autotuning
> never decreases the size of the buffer below the size we initially
> requested.  Apparently that assumption is true.  There's some worry
> about whether that's true by design or merely true of the current
> implementation.
>   
If it does happen, I assume the fix there is to set the minimum tcp 
buffer settings big enough for a single request?

In fact, the big impact here I believe is that NFS will finally start 
using the linux tcp buffer settings (like every other tool).  Is there 
any way to
get some documentation out there that this is the case?  Maybe an 
addition to the website would be the right place for now?
Dean
> That doesn't look like a big worry--I'm inclined to apply this patch as
> is--but moving the sk_{rcv,snd}buf assignments to a simple function in
> the networking code and documenting the requirements there might be a
> nice thing to do (as a separate patch).
>
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
