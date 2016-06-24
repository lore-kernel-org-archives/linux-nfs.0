Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:22669 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751188AbcFXVbM convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jun 2016 17:31:12 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Fields Bruce <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 09/10] SUNRPC: Change TCP socket space reservation
Date: Fri, 24 Jun 2016 21:31:07 +0000
Message-ID: <A6F54110-7D15-4545-B15B-D058EAB358F0@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-6-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-7-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-8-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-9-git-send-email-trond.myklebust@primarydata.com>
 <20160624211808.GL3287@fieldses.org>
In-Reply-To: <20160624211808.GL3287@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 24, 2016, at 17:18, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Fri, Jun 24, 2016 at 10:55:51AM -0400, Trond Myklebust wrote:
>> Instead of trying (and failing) to predict how much writeable socket space
>> will be available to the RPC call, just fall back to the simple model of
>> deferring processing until the socket is uncongested.
> 
> OK, it would be a relief to get rid of that, I guess that explains the
> previous patch.
> 
> But was there some specific reason you were running into this?

I’ve been testing using a 40GigE network, which easily hits this bottleneck. The result is that each connection saturates long before we’re even near the saturation of the network or even the disk. So we find ourselves with a server that can continue to scale up to several 100 clients, but with each client seeing the same low performance irrespective of the total number of clients.

> 
> In general I could use a little more idea of the motivation for these
> patches.
> 
> --b.
> 
>> 
>> If a limit is neeeded, then set the hard per-connection limit.
>> 
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> net/sunrpc/svcsock.c | 47 ++++-------------------------------------------
>> 1 file changed, 4 insertions(+), 43 deletions(-)
>> 
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index 338d6fe1103d..bc3ef0734f2f 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -431,43 +431,11 @@ static void svc_write_space(struct sock *sk)
>> 
>> static int svc_tcp_has_wspace(struct svc_xprt *xprt)
>> {
>> -	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
>> -	struct svc_serv *serv = svsk->sk_xprt.xpt_server;
>> -	int required;
>> +	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
>> 
>> 	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
>> 		return 1;
>> -	required = atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg;
>> -	if (sk_stream_wspace(svsk->sk_sk) >= required ||
>> -	    (sk_stream_min_wspace(svsk->sk_sk) == 0 &&
>> -	     atomic_read(&xprt->xpt_reserved) == 0))
>> -		return 1;
>> -	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>> -	return 0;
>> -}
>> -
>> -static void svc_tcp_write_space(struct sock *sk)
>> -{
>> -	struct svc_sock *svsk = (struct svc_sock *)(sk->sk_user_data);
>> -	struct socket *sock = sk->sk_socket;
>> -
>> -	if (!svsk)
>> -		return;
>> -
>> -	if (!sk_stream_is_writeable(sk) || !sock)
>> -		return;
>> -	if (svc_tcp_has_wspace(&svsk->sk_xprt)) {
>> -		clear_bit(SOCK_NOSPACE, &sock->flags);
>> -		svc_write_space(sk);
>> -	}
>> -}
>> -
>> -static void svc_tcp_adjust_wspace(struct svc_xprt *xprt)
>> -{
>> -	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
>> -
>> -	if (svc_tcp_has_wspace(xprt))
>> -		clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>> +	return !test_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>> }
>> 
>> /*
>> @@ -1272,7 +1240,6 @@ static struct svc_xprt_ops svc_tcp_ops = {
>> 	.xpo_has_wspace = svc_tcp_has_wspace,
>> 	.xpo_accept = svc_tcp_accept,
>> 	.xpo_secure_port = svc_sock_secure_port,
>> -	.xpo_adjust_wspace = svc_tcp_adjust_wspace,
>> };
>> 
>> static struct svc_xprt_class svc_tcp_class = {
>> @@ -1313,7 +1280,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
>> 		dprintk("setting up TCP socket for reading\n");
>> 		sk->sk_state_change = svc_tcp_state_change;
>> 		sk->sk_data_ready = svc_data_ready;
>> -		sk->sk_write_space = svc_tcp_write_space;
>> +		sk->sk_write_space = svc_write_space;
>> 
>> 		svsk->sk_reclen = 0;
>> 		svsk->sk_tcplen = 0;
>> @@ -1383,14 +1350,8 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
>> 	/* Initialize the socket */
>> 	if (sock->type == SOCK_DGRAM)
>> 		svc_udp_init(svsk, serv);
>> -	else {
>> -		/* initialise setting must have enough space to
>> -		 * receive and respond to one request.
>> -		 */
>> -		svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
>> -					4 * serv->sv_max_mesg);
>> +	else
>> 		svc_tcp_init(svsk, serv);
>> -	}
>> 
>> 	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
>> 				svsk, svsk->sk_sk);
>> -- 
>> 2.7.4
> 

