Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34155 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbdLCUTv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Dec 2017 15:19:51 -0500
Received: by mail-it0-f65.google.com with SMTP id m11so9103269iti.1
        for <linux-nfs@vger.kernel.org>; Sun, 03 Dec 2017 12:19:51 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] SUNRPC: Fix a race in the receive code path
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <1512331965.24703.5.camel@primarydata.com>
Date: Sun, 3 Dec 2017 15:19:49 -0500
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0CE894EE-2CB0-4716-BEFA-C946FBE3A27A@gmail.com>
References: <20171203185012.24473-1-trond.myklebust@primarydata.com> <9F7B84A7-B241-49D3-8F9D-36338669C827@gmail.com> <1512331965.24703.5.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 3, 2017, at 3:12 PM, Trond Myklebust <trondmy@primarydata.com> =
wrote:
>=20
> On Sun, 2017-12-03 at 13:54 -0500, Chuck Lever wrote:
>>> On Dec 3, 2017, at 1:50 PM, Trond Myklebust <trond.myklebust@primar
>>> ydata.com> wrote:
>>>=20
>>> We must ensure that the call to rpc_sleep_on() in xprt_transmit()
>>> cannot
>>> race with the call to xprt_complete_rqst().
>>=20
>> :-( this will kill scalability, we might as well just go back
>> to the old locking scheme.
>=20
> It shouldn't make a huge difference, but I agree that we do want to =
get
> rid of that transport lock.
>=20
> How about the following, then?

This looks better, I'll give it a try!

But touching the recv_lock in the transmit path is what I'd like
to avoid completely, if possible. I'm not clear on why the pending
waitqueue is unprotected. Doesn't it have a lock of its own?


> 8<------------------------------------------------------------------
> =46rom 6a0c507f160d5624d9049281cd9dfe222a866f06 Mon Sep 17 00:00:00 =
2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Sun, 3 Dec 2017 13:37:27 -0500
> Subject: [PATCH v2] SUNRPC: Fix a race in the receive code path
>=20
> We must ensure that the call to rpc_sleep_on() in xprt_transmit() =
cannot
> race with the call to xprt_complete_rqst().
>=20
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Link: https://bugzilla.linux-nfs.org/show_bug.cgi?id=3D317
> Fixes: ce7c252a8c74 ("SUNRPC: Add a separate spinlock to protect..")
> Cc: stable@vger.kernel.org # 4.14+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> net/sunrpc/xprt.c | 18 +++++++++++-------
> 1 file changed, 11 insertions(+), 7 deletions(-)
>=20
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 333b9d697ae5..34f613385319 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1024,6 +1024,7 @@ void xprt_transmit(struct rpc_task *task)
> 	} else if (!req->rq_bytes_sent)
> 		return;
>=20
> +	req->rq_connect_cookie =3D xprt->connect_cookie;
> 	req->rq_xtime =3D ktime_get();
> 	status =3D xprt->ops->send_request(task);
> 	trace_xprt_transmit(xprt, req->rq_xid, status);
> @@ -1048,19 +1049,22 @@ void xprt_transmit(struct rpc_task *task)
> 	xprt->stat.sending_u +=3D xprt->sending.qlen;
> 	xprt->stat.pending_u +=3D xprt->pending.qlen;
>=20
> -	/* Don't race with disconnect */
> -	if (!xprt_connected(xprt))
> -		task->tk_status =3D -ENOTCONN;
> -	else {
> +	spin_unlock_bh(&xprt->transport_lock);
> +
> +	if (!READ_ONCE(req->rq_reply_bytes_recvd) && =
rpc_reply_expected(task)) {
> +		spin_lock(&xprt->recv_lock);
> 		/*
> 		 * Sleep on the pending queue since
> 		 * we're expecting a reply.
> 		 */
> -		if (!req->rq_reply_bytes_recvd && =
rpc_reply_expected(task))
> +		if (!req->rq_reply_bytes_recvd) {
> 			rpc_sleep_on(&xprt->pending, task, xprt_timer);
> -		req->rq_connect_cookie =3D xprt->connect_cookie;
> +			/* Deal with disconnect races */
> +			if (!xprt_connected(xprt))
> +				xprt_wake_pending_tasks(xprt, =
-ENOTCONN);
> +		}
> +		spin_unlock(&xprt->recv_lock);
> 	}
> -	spin_unlock_bh(&xprt->transport_lock);
> }
>=20
> static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task =
*task)
> --=20
> 2.14.3
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> =
N=C2=8B=C2=A7=C4=93=C3=A6=C4=97r=C4=BC=C2=9By=C3=BA=C4=8D=C2=9A=C3=98b=C4=93=
X=C5=BD=C4=B7=C4=AE=C2=A7v=C3=98^=C2=96)=C3=9E=C5=A1{.n=C4=AE+=C2=89=C2=B7=
=C4=A8=C2=8A{=C4=85=C2=9D=C3=BB"=C2=9E=C3=98^n=C2=87r=C4=84=C3=B6=C4=B6z=C3=
=8B=1A=C2=81=C3=ABh=C2=99=C4=BB=C4=8D=C2=AD=C3=9A&=C4=92=C3=B8=1E=C5=AAG=C5=
=A6=C2=9D=C3=A9h=C5=AA=03(=C2=AD=C3=A9=C2=9A=C2=8E=C2=8A=C3=9D=C4=92j"=C2=9D=
=C3=BA=1A=C4=B7=1Bm=C2=A7=C4=B8=C3=AF=C2=81=C4=99=C3=A4z=C4=91=C3=9E=C2=96=
=C2=8A=C4=81=C3=BEf=C4=A2=C4=92=C2=B7h=C2=9A=C2=88=C2=A7~=C2=88m

--
Chuck Lever
chucklever@gmail.com



