Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:39213 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754848AbcIPQBf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2016 12:01:35 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: David Vrabel <david.vrabel@citrix.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        "List Linux Network Devel Mailing" <netdev@vger.kernel.org>
Subject: Re: [PATCHv1] sunrpc: fix write space race causing stalls
Date: Fri, 16 Sep 2016 16:01:26 +0000
Message-ID: <DCD6291A-CE72-4888-AD77-37BB259CD026@primarydata.com>
References: <1474028902-19838-1-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1474028902-19838-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 16, 2016, at 08:28, David Vrabel <david.vrabel@citrix.com> wrote:
>=20
> Write space becoming available may race with putting the task to sleep
> in xprt_wait_for_buffer_space().  The existing mechanism to avoid the
> race does not work.
>=20
> This (edited) partial trace illustrates the problem:
>=20
>   [1] rpc_task_run_action: task:43546@5 ... action=3Dcall_transmit
>   [2] xs_write_space <-xs_tcp_write_space
>   [3] xprt_write_space <-xs_write_space
>   [4] rpc_task_sleep: task:43546@5 ...
>   [5] xs_write_space <-xs_tcp_write_space
>=20
> [1] Task 43546 runs but is out of write space.
>=20
> [2] Space becomes available, xs_write_space() clears the
>    SOCKWQ_ASYNC_NOSPACE bit.
>=20
> [3] xprt_write_space() attemts to wake xprt->snd_task (=3D=3D 43546), but
>    this has not yet been queued and the wake up is lost.
>=20
> [4] xs_nospace() is called which calls xprt_wait_for_buffer_space()
>    which queues task 43546.
>=20
> [5] The call to sk->sk_write_space() at the end of xs_nospace() (which
>    is supposed to handle the above race) does not call
>    xprt_write_space() as the SOCKWQ_ASYNC_NOSPACE bit is clear and
>    thus the task is not woken.
>=20
> Fix the race by have xprt_wait_for_buffer_space() check for write
> space after putting the task to sleep.
>=20
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
> include/linux/sunrpc/xprt.h |  1 +
> net/sunrpc/xprt.c           |  4 ++++
> net/sunrpc/xprtsock.c       | 21 +++++++++++++++++++--
> 3 files changed, 24 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index a16070d..621e74b 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -129,6 +129,7 @@ struct rpc_xprt_ops {
> =09void=09=09(*connect)(struct rpc_xprt *xprt, struct rpc_task *task);
> =09void *=09=09(*buf_alloc)(struct rpc_task *task, size_t size);
> =09void=09=09(*buf_free)(void *buffer);
> +=09bool            (*have_write_space)(struct rpc_xprt *task);
> =09int=09=09(*send_request)(struct rpc_task *task);
> =09void=09=09(*set_retrans_timeout)(struct rpc_task *task);
> =09void=09=09(*timer)(struct rpc_xprt *xprt, struct rpc_task *task);
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index ea244b2..d3c1b1e 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -502,6 +502,10 @@ void xprt_wait_for_buffer_space(struct rpc_task *tas=
k, rpc_action action)
>=20
> =09task->tk_timeout =3D RPC_IS_SOFT(task) ? req->rq_timeout : 0;
> =09rpc_sleep_on(&xprt->pending, task, action);
> +
> +=09/* Write space notification may race with putting task to sleep. */
> +=09if (xprt->ops->have_write_space(xprt))
> +=09=09rpc_wake_up_queued_task(&xprt->pending, task);
> }
> EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
>=20
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index bf16883..211de5b 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -472,8 +472,6 @@ static int xs_nospace(struct rpc_task *task)
>=20
> =09spin_unlock_bh(&xprt->transport_lock);
>=20
> -=09/* Race breaker in case memory is freed before above code is called *=
/
> -=09sk->sk_write_space(sk);
> =09return ret;
> }

Instead of these callbacks, why not just add a call to sk_set_bit(SOCKWQ_AS=
YNC_WAITDATA, sk) after queueing the task in xs_nospace()? Won=92t that fix=
 the existing race breaker?

Cheers
  Trond

