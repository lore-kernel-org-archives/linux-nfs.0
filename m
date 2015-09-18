Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([207.82.80.143]:10908 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751585AbbIRLTL convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Sep 2015 07:19:11 -0400
Message-ID: <55FBF32C.7030107@arm.com>
Date: Fri, 18 Sep 2015 12:19:08 +0100
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@poochiereds.net>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Marc Zyngier <Marc.Zyngier@arm.com>
Subject: Re: [PATCHv2] SUNRPC: Fix a race in xs_reset_transport
References: <1442394280-24280-1-git-send-email-suzuki.poulose@arm.com>	<1442396149-24775-1-git-send-email-suzuki.poulose@arm.com> <20150916071730.052af53d@tlielax.poochiereds.net>
In-Reply-To: <20150916071730.052af53d@tlielax.poochiereds.net>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16/09/15 12:17, Jeff Layton wrote:
> On Wed, 16 Sep 2015 10:35:49 +0100
> "Suzuki K. Poulose" <suzuki.poulose@arm.com> wrote:
>
>> From: "Suzuki K. Poulose" <suzuki.poulose@arm.com>
>>

...

>> +		write_unlock_bh(&sk->sk_callback_lock);
>> +		return;
>> +	}
>> +	sock = transport->sock;
>> +
>>   	transport->inet = NULL;
>>   	transport->sock = NULL;
>>
>> @@ -833,6 +838,10 @@ static void xs_reset_transport(struct sock_xprt *transport)
>>   	xs_restore_old_callbacks(transport, sk);
>>   	xprt_clear_connected(xprt);
>>   	write_unlock_bh(&sk->sk_callback_lock);
>> +
>> +	if (sock)
>> +		kernel_sock_shutdown(sock, SHUT_RDWR);
>> +
>>   	xs_sock_reset_connection_flags(xprt);
>>
>>   	trace_rpc_socket_close(xprt, sock);
>
> Better, but now I'm wondering...is it problematic to restore the old
> callbacks before calling kernel_sock_shutdown? I can't quite tell
> whether it matters in all cases.
>
> It might be best to just go ahead and take the spinlock twice here. Do
> it once to clear the transport->sock pointer, call
> kernel_sock_shutdown, and then take it again to restore the old
> callbacks, etc.
>
> I don't know though...I get the feeling there are races all over the
> place in this code. It seems like there's a similar one wrt to the
> transport->inet pointer. It seems a little silly that we clear it under
> the sk->sk_callback_lock. You have to dereference that pointer
> in order to get to the lock.
>
> Maybe the right solution is to use an xchg to swap the inet pointer
> with NULL so it can act as a gatekeeper. Whoever gets there first does
> the rest of the shutdown.
>
> Something like this maybe? Would this also fix the original problem?
> Note that this patch is untested...
>
> [PATCH] sunrpc: use xchg to fetch and clear the transport->inet pointer in xs_reset_transport
>
> Reported-by: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>   net/sunrpc/xprtsock.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7be90bc1a7c2..57f79dcab493 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -813,9 +813,10 @@ static void xs_error_report(struct sock *sk)
>   static void xs_reset_transport(struct sock_xprt *transport)
>   {
>   	struct socket *sock = transport->sock;
> -	struct sock *sk = transport->inet;
> +	struct sock *sk;
>   	struct rpc_xprt *xprt = &transport->xprt;
>
> +	sk = xchg(&transport->inet, NULL);
>   	if (sk == NULL)
>   		return;
>
> @@ -825,7 +826,6 @@ static void xs_reset_transport(struct sock_xprt *transport)
>   	kernel_sock_shutdown(sock, SHUT_RDWR);
>
>   	write_lock_bh(&sk->sk_callback_lock);
> -	transport->inet = NULL;
>   	transport->sock = NULL;
>
>   	sk->sk_user_data = NULL;
>


This one seemed to fix it, so if it matters :

Tested-by: Suzuki K. Poulose <suzuki.poulose@arm.com>

Suzuki

