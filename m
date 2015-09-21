Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([207.82.80.143]:28098 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932348AbbIUNsz convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2015 09:48:55 -0400
Message-ID: <56000AC3.80402@arm.com>
Date: Mon, 21 Sep 2015 14:48:51 +0100
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>
CC: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Marc Zyngier <Marc.Zyngier@arm.com>
Subject: Re: [PATCHv2] SUNRPC: Fix a race in xs_reset_transport
References: <1442394280-24280-1-git-send-email-suzuki.poulose@arm.com>	 <1442396149-24775-1-git-send-email-suzuki.poulose@arm.com>	 <20150916071730.052af53d@tlielax.poochiereds.net>	 <55FBF32C.7030107@arm.com> <1442595095.11370.13.camel@primarydata.com> <1442613607.11370.18.camel@primarydata.com>
In-Reply-To: <1442613607.11370.18.camel@primarydata.com>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18/09/15 23:00, Trond Myklebust wrote:
> On Fri, 2015-09-18 at 12:51 -0400, Trond Myklebust wrote:
>> On Fri, 2015-09-18 at 12:19 +0100, Suzuki K. Poulose wrote:
>>> On 16/09/15 12:17, Jeff Layton wrote:
>>>> On Wed, 16 Sep 2015 10:35:49 +0100
>>>> "Suzuki K. Poulose" <suzuki.poulose@arm.com> wrote:
>>>>
>>>>> From: "Suzuki K. Poulose" <suzuki.poulose@arm.com>
>>>>>
>>>
>>> ...
>>>
>>>>> +		write_unlock_bh(&sk->sk_callback_lock);
>>>>> +		return;
>>>>> +	}
>>>>> +	sock = transport->sock;
>>>>> +
>>>>>    	transport->inet = NULL;
>>>>>    	transport->sock = NULL;
>>>>>
>>>>> @@ -833,6 +838,10 @@ static void xs_reset_transport(struct
>>>>> sock_xprt *transport)
>>>>>    	xs_restore_old_callbacks(transport, sk);
>>>>>    	xprt_clear_connected(xprt);
>>>>>    	write_unlock_bh(&sk->sk_callback_lock);
>>>>> +

...

>>
>> So how about the following patch? It should apply cleanly on top of
>> the
>> first one (which is still needed, btw).
>
> Having thought some more about this, I think the safest thing in order
> to avoid races is simply to have the shutdown set XPRT_LOCKED. That way
> we can keep the current desirable behaviour of closing the socket
> automatically any time the server initiates a close, while still
> preventing it during shutdown.
>
> 8<-------------------------------------------------------------------
>  From 3e1c9d8092e2fa4509d84a00fcf21e7e0c581fe2 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Fri, 18 Sep 2015 15:53:24 -0400
> Subject: [PATCH] SUNRPC: Lock the transport layer on shutdown
>
> Avoid all races with the connect/disconnect handlers by taking the
> transport lock.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>   net/sunrpc/xprt.c | 6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index ab5dd621ae0c..2e98f4a243e5 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -614,6 +614,7 @@ static void xprt_autoclose(struct work_struct *work)
>   	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
>   	xprt->ops->close(xprt);
>   	xprt_release_write(xprt, NULL);
> +	wake_up_bit(&xprt->state, XPRT_LOCKED);
>   }
>
>   /**
> @@ -723,6 +724,7 @@ void xprt_unlock_connect(struct rpc_xprt *xprt, void *cookie)
>   	xprt->ops->release_xprt(xprt, NULL);
>   out:
>   	spin_unlock_bh(&xprt->transport_lock);
> +	wake_up_bit(&xprt->state, XPRT_LOCKED);
>   }
>
>   /**
> @@ -1394,6 +1396,10 @@ out:
>   static void xprt_destroy(struct rpc_xprt *xprt)
>   {
>   	dprintk("RPC:       destroying transport %p\n", xprt);
> +
> +	/* Exclude transport connect/disconnect handlers */
> +	wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_UNINTERRUPTIBLE);
> +
>   	del_timer_sync(&xprt->timer);
>
>   	rpc_xprt_debugfs_unregister(xprt);
>


That works for me, please feel free to add:

Reported-by: Suzuki K. Poulose <suzuki.poulose@arm.com>
Tested-by: Suzuki K. Poulose <suzuki.poulose@arm.com>



Thanks
Suzuki


