Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:40228 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726046AbeIETBC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 15:01:02 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2 23/34] SUNRPC: Move RPC retransmission stat counter to
 xprt_transmit()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180904210549.81673-24-trond.myklebust@hammerspace.com>
Date: Wed, 5 Sep 2018 10:30:26 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0A486690-38DA-4377-8968-DF0008113479@oracle.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
 <20180904210549.81673-2-trond.myklebust@hammerspace.com>
 <20180904210549.81673-3-trond.myklebust@hammerspace.com>
 <20180904210549.81673-4-trond.myklebust@hammerspace.com>
 <20180904210549.81673-5-trond.myklebust@hammerspace.com>
 <20180904210549.81673-6-trond.myklebust@hammerspace.com>
 <20180904210549.81673-7-trond.myklebust@hammerspace.com>
 <20180904210549.81673-8-trond.myklebust@hammerspace.com>
 <20180904210549.81673-9-trond.myklebust@hammerspace.com>
 <20180904210549.81673-10-trond.myklebust@hammerspace.com>
 <20180904210549.81673-11-trond.myklebust@hammerspace.com>
 <20180904210549.81673-12-trond.myklebust@hammerspace.com>
 <20180904210549.81673-13-trond.myklebust@hammerspace.com>
 <20180904210549.81673-14-trond.myklebust@hammerspace.com>
 <20180904210549.81673-15-trond.myklebust@hammerspace.com>
 <20180904210549.81673-16-trond.myklebust@hammerspace.com>
 <20180904210549.81673-17-trond.myklebust@hammerspace.com>
 <20180904210549.81673-18-trond.myklebust@hammerspace.com>
 <20180904210549.81673-19-trond.myklebust@hammerspace.com>
 <20180904210549.81673-20-trond.myklebust@hammerspace.com>
 <20180904210549.81673-21-trond.myklebust@hammerspace.com>
 <20180904210549.81673-22-trond.myklebust@hammerspace.com>
 <20180904210549.81673-23-trond.myklebust@hammerspace.com>
 <20180904210549.81673-24-trond.myklebust@hammerspace.com>
To: Trond Myklebust <trondmy@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Sep 4, 2018, at 5:05 PM, Trond Myklebust <trondmy@gmail.com> wrote:
>=20
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/clnt.c |  6 ------
> net/sunrpc/xprt.c | 13 ++++++-------
> 2 files changed, 6 insertions(+), 13 deletions(-)
>=20
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 032b7042adb6..21713bed812a 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1967,8 +1967,6 @@ call_connect_status(struct rpc_task *task)
> static void
> call_transmit(struct rpc_task *task)
> {
> -	int is_retrans =3D RPC_WAS_SENT(task);
> -
> 	dprint_status(task);
>=20
> 	task->tk_action =3D call_transmit_status;
> @@ -1979,10 +1977,6 @@ call_transmit(struct rpc_task *task)
> 	if (!xprt_prepare_transmit(task))
> 		return;
> 	xprt_transmit(task);
> -	if (task->tk_status < 0)
> -		return;
> -	if (is_retrans)
> -		task->tk_client->cl_stats->rpcretrans++;
> }
>=20
> /*
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index f1301d391399..e2f5b4668a66 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -191,8 +191,6 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, =
struct rpc_task *task)
> 		goto out_sleep;
> 	}
> 	xprt->snd_task =3D task;
> -	if (req !=3D NULL)
> -		req->rq_ntrans++;
>=20
> 	return 1;
>=20
> @@ -247,7 +245,6 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, =
struct rpc_task *task)
> 	}
> 	if (__xprt_get_cong(xprt, task)) {
> 		xprt->snd_task =3D task;
> -		req->rq_ntrans++;
> 		return 1;
> 	}
> 	xprt_clear_locked(xprt);
> @@ -281,12 +278,8 @@ static inline int xprt_lock_write(struct rpc_xprt =
*xprt, struct rpc_task *task)
> static bool __xprt_lock_write_func(struct rpc_task *task, void *data)
> {
> 	struct rpc_xprt *xprt =3D data;
> -	struct rpc_rqst *req;
>=20
> -	req =3D task->tk_rqstp;
> 	xprt->snd_task =3D task;
> -	if (req)
> -		req->rq_ntrans++;
> 	return true;
> }
>=20
> @@ -1126,6 +1119,7 @@ void xprt_transmit(struct rpc_task *task)
> 	struct rpc_rqst	*req =3D task->tk_rqstp;
> 	struct rpc_xprt	*xprt =3D req->rq_xprt;
> 	unsigned int connect_cookie;
> +	int is_retrans =3D RPC_WAS_SENT(task);
> 	int status;
>=20
> 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, =
req->rq_slen);
> @@ -1140,6 +1134,8 @@ void xprt_transmit(struct rpc_task *task)
> 		}
> 	}
>=20
> +	req->rq_ntrans++;
> +

rq_ntrans is used in two places:

1. rpc_update_rtt
2. rpc_count_iostats_metrics

Both of these appear to assume that rq_ntrans is counting
full successful transmissions (ie, calls that appear on the
wire), not invocations of ->send_request().

Can this counter be moved down to where rpcretrans is updated?


> 	connect_cookie =3D xprt->connect_cookie;
> 	status =3D xprt->ops->send_request(req, task);
> 	trace_xprt_transmit(xprt, req->rq_xid, status);
> @@ -1148,6 +1144,9 @@ void xprt_transmit(struct rpc_task *task)
> 		return;
> 	}
>=20
> +	if (is_retrans)
> +		task->tk_client->cl_stats->rpcretrans++;
> +
> 	xprt_inject_disconnect(xprt);
>=20
> 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
> --=20
> 2.17.1
>=20

--
Chuck Lever
