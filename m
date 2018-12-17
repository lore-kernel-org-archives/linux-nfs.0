Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6DD7C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 18:37:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6F07A2086C
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 18:37:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="FX7Ol7lw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728176AbeLQShn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 13:37:43 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:44616 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728155AbeLQShn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 13:37:43 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBHIT3HF063661;
        Mon, 17 Dec 2018 18:37:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=ekBV17v4B0s1AKQS58HKRPCCAp9JrOtmKWJeqCl4cvs=;
 b=FX7Ol7lwb0FbQIZsYj5U/alm9NV3EMTfFGagLM/MJht3+vjQ8oVGe6f7fZFyMkFfButD
 jFtKRL8iDz0gUqhaY/L9eQD1Zmhe8XCA8FeqxrJL+iybmqOsSzomdRZJ2harz5xBu9ZR
 njOXGSuZBZYMMUnuVHjiPduygAaYZKMzz+5nWpjqIDKmAH2FR4NJUZCSwMRMUVpKPZhf
 YWXbTfFpwaJSFHsmW75bCdHQIvsj63dYsWGfEAVerMMdJ8/94VZEjyoNDXGgfoWUJt6P
 2g2y7DpyoLeXoGE+sJ0agk9Itzzg/iFdc89OQTTkancKDa6tS24ZUiIQWyi7Gtfij6gH PA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2130.oracle.com with ESMTP id 2pcq4dqdgd-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 17 Dec 2018 18:37:39 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBHIbc2A013739
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 17 Dec 2018 18:37:38 GMT
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBHIbZfU000814;
        Mon, 17 Dec 2018 18:37:37 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 17 Dec 2018 10:37:35 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v4 06/30] xprtrdma: Don't wake pending tasks until
 disconnect is done
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <f080c79d6722ad339e47e20c6da72f9b0fc8a297.camel@hammerspace.com>
Date:   Mon, 17 Dec 2018 13:37:34 -0500
Cc:     "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <FD0CDDF9-EDEF-41C6-83F5-C956F3FF098E@oracle.com>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
 <20181217163953.24133.29214.stgit@manet.1015granger.net>
 <f080c79d6722ad339e47e20c6da72f9b0fc8a297.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9110 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812170162
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 17, 2018, at 12:28 PM, Trond Myklebust =
<trondmy@hammerspace.com> wrote:
>=20
> On Mon, 2018-12-17 at 11:39 -0500, Chuck Lever wrote:
>> Transport disconnect processing does a "wake pending tasks" at
>> various points.
>>=20
>> Suppose an RPC Reply is being processed. The RPC task that Reply
>> goes with is waiting on the pending queue. If a disconnect wake-up
>> happens before reply processing is done, that reply, even if it is
>> good, is thrown away, and the RPC has to be sent again.
>>=20
>> This window apparently does not exist for socket transports because
>> there is a lock held while a reply is being received which prevents
>> the wake-up call until after reply processing is done.
>>=20
>> To resolve this, all RPC replies being processed on an RPC-over-RDMA
>> transport have to complete before pending tasks are awoken due to a
>> transport disconnect.
>>=20
>> Callers that already hold the transport write lock may invoke
>> ->ops->close directly. Others use a generic helper that schedules
>> a close when the write lock can be taken safely.
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/xprt.h                |    1 +
>> net/sunrpc/xprt.c                          |   19
>> +++++++++++++++++++
>> net/sunrpc/xprtrdma/backchannel.c          |   13 +++++++------
>> net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    8 +++++---
>> net/sunrpc/xprtrdma/transport.c            |   16 ++++++++++------
>> net/sunrpc/xprtrdma/verbs.c                |    5 ++---
>> 6 files changed, 44 insertions(+), 18 deletions(-)
>>=20
>> diff --git a/include/linux/sunrpc/xprt.h
>> b/include/linux/sunrpc/xprt.h
>> index a4ab4f8..ee94ed0 100644
>> --- a/include/linux/sunrpc/xprt.h
>> +++ b/include/linux/sunrpc/xprt.h
>> @@ -401,6 +401,7 @@ static inline __be32
>> *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *
>> bool			xprt_request_get_cong(struct rpc_xprt *xprt,
>> struct rpc_rqst *req);
>> void			xprt_disconnect_done(struct rpc_xprt *xprt);
>> void			xprt_force_disconnect(struct rpc_xprt *xprt);
>> +void			xprt_disconnect_nowake(struct rpc_xprt =
*xprt);
>> void			xprt_conditional_disconnect(struct rpc_xprt
>> *xprt, unsigned int cookie);
>>=20
>> bool			xprt_lock_connect(struct rpc_xprt *, struct
>> rpc_task *, void *);
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index ce92700..afe412e 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -685,6 +685,25 @@ void xprt_force_disconnect(struct rpc_xprt
>> *xprt)
>> }
>> EXPORT_SYMBOL_GPL(xprt_force_disconnect);
>>=20
>> +/**
>> + * xprt_disconnect_nowake - force a call to xprt->ops->close
>> + * @xprt: transport to disconnect
>> + *
>> + * The caller must ensure that xprt_wake_pending_tasks() is
>> + * called later.
>> + */
>> +void xprt_disconnect_nowake(struct rpc_xprt *xprt)
>> +{
>> +       /* Don't race with the test_bit() in xprt_clear_locked() */
>> +       spin_lock_bh(&xprt->transport_lock);
>> +       set_bit(XPRT_CLOSE_WAIT, &xprt->state);
>> +       /* Try to schedule an autoclose RPC call */
>> +       if (test_and_set_bit(XPRT_LOCKED, &xprt->state) =3D=3D 0)
>> +               queue_work(xprtiod_workqueue, &xprt->task_cleanup);
>> +       spin_unlock_bh(&xprt->transport_lock);
>> +}
>> +EXPORT_SYMBOL_GPL(xprt_disconnect_nowake);
>> +
>=20
> We shouldn't need both xprt_disconnect_nowake() and
> xprt_force_disconnect() to be exported given that you can build the
> latter from the former + xprt_wake_pending_tasks() (which is also
> already exported).

Thanks for your review!

I can get rid of xprt_disconnect_nowake. There are some variations,
depending on why wake_pending_tasks is protected by =
xprt->transport_lock.

static void xs_tcp_force_close(struct rpc_xprt *xprt)
{
        xprt_force_disconnect(xprt);
        xprt_wake_pending_tasks(xprt, -EAGAIN);
}   =20

Or,

static void xs_tcp_force_close(struct rpc_xprt *xprt)
{
        xprt_force_disconnect(xprt);
        spin_lock_bh(&xprt->transport_lock);
        xprt_wake_pending_tasks(xprt, -EAGAIN);
        spin_lock_bh(&xprt->transport_lock);
}   =20

Or,

void xprt_force_disconnect(struct rpc_xprt *xprt, bool wake)
{
        /* Don't race with the test_bit() in xprt_clear_locked() */
        spin_lock_bh(&xprt->transport_lock);
        set_bit(XPRT_CLOSE_WAIT, &xprt->state);
        /* Try to schedule an autoclose RPC call */
        if (test_and_set_bit(XPRT_LOCKED, &xprt->state) =3D=3D 0)
                queue_work(xprtiod_workqueue, &xprt->task_cleanup);
        if (wake)
                xprt_wake_pending_tasks(xprt, -EAGAIN);
        spin_unlock_bh(&xprt->transport_lock);
}

Which do you prefer?


>> static unsigned int
>> xprt_connect_cookie(struct rpc_xprt *xprt)
>> {
>> diff --git a/net/sunrpc/xprtrdma/backchannel.c
>> b/net/sunrpc/xprtrdma/backchannel.c
>> index 2cb07a3..5d462e8 100644
>> --- a/net/sunrpc/xprtrdma/backchannel.c
>> +++ b/net/sunrpc/xprtrdma/backchannel.c
>> @@ -193,14 +193,15 @@ static int rpcrdma_bc_marshal_reply(struct
>> rpc_rqst *rqst)
>>  */
>> int xprt_rdma_bc_send_reply(struct rpc_rqst *rqst)
>> {
>> -	struct rpcrdma_xprt *r_xprt =3D rpcx_to_rdmax(rqst->rq_xprt);
>> +	struct rpc_xprt *xprt =3D rqst->rq_xprt;
>> +	struct rpcrdma_xprt *r_xprt =3D rpcx_to_rdmax(xprt);
>> 	struct rpcrdma_req *req =3D rpcr_to_rdmar(rqst);
>> 	int rc;
>>=20
>> -	if (!xprt_connected(rqst->rq_xprt))
>> -		goto drop_connection;
>> +	if (!xprt_connected(xprt))
>> +		return -ENOTCONN;
>>=20
>> -	if (!xprt_request_get_cong(rqst->rq_xprt, rqst))
>> +	if (!xprt_request_get_cong(xprt, rqst))
>> 		return -EBADSLT;
>>=20
>> 	rc =3D rpcrdma_bc_marshal_reply(rqst);
>> @@ -215,7 +216,7 @@ int xprt_rdma_bc_send_reply(struct rpc_rqst
>> *rqst)
>> 	if (rc !=3D -ENOTCONN)
>> 		return rc;
>> drop_connection:
>> -	xprt_disconnect_done(rqst->rq_xprt);
>> +	xprt->ops->close(xprt);
>=20
> Why use an indirect call here? Is this ever going to be different to
> xprt_rdma_close()?
>=20
>> 	return -ENOTCONN;
>> }
>>=20
>> @@ -338,7 +339,7 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt
>> *r_xprt,
>>=20
>> out_overflow:
>> 	pr_warn("RPC/RDMA backchannel overflow\n");
>> -	xprt_disconnect_done(xprt);
>> +	xprt_disconnect_nowake(xprt);
>> 	/* This receive buffer gets reposted automatically
>> 	 * when the connection is re-established.
>> 	 */
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>> b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>> index f3c147d..b908f2c 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>> @@ -200,11 +200,10 @@ static int svc_rdma_bc_sendto(struct
>> svcxprt_rdma *rdma,
>> 		svc_rdma_send_ctxt_put(rdma, ctxt);
>> 		goto drop_connection;
>> 	}
>> -	return rc;
>> +	return 0;
>>=20
>> drop_connection:
>> 	dprintk("svcrdma: failed to send bc call\n");
>> -	xprt_disconnect_done(xprt);
>> 	return -ENOTCONN;
>> }
>>=20
>> @@ -225,8 +224,11 @@ static int svc_rdma_bc_sendto(struct
>> svcxprt_rdma *rdma,
>>=20
>> 	ret =3D -ENOTCONN;
>> 	rdma =3D container_of(sxprt, struct svcxprt_rdma, sc_xprt);
>> -	if (!test_bit(XPT_DEAD, &sxprt->xpt_flags))
>> +	if (!test_bit(XPT_DEAD, &sxprt->xpt_flags)) {
>> 		ret =3D rpcrdma_bc_send_request(rdma, rqst);
>> +		if (ret =3D=3D -ENOTCONN)
>> +			svc_close_xprt(sxprt);
>> +	}
>>=20
>> 	mutex_unlock(&sxprt->xpt_mutex);
>>=20
>> diff --git a/net/sunrpc/xprtrdma/transport.c
>> b/net/sunrpc/xprtrdma/transport.c
>> index 91c476a..a16296b 100644
>> --- a/net/sunrpc/xprtrdma/transport.c
>> +++ b/net/sunrpc/xprtrdma/transport.c
>> @@ -453,13 +453,13 @@
>>=20
>> 	if (test_and_clear_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags)) {
>> 		rpcrdma_ia_remove(ia);
>> -		return;
>> +		goto out;
>> 	}
>> +
>> 	if (ep->rep_connected =3D=3D -ENODEV)
>> 		return;
>> 	if (ep->rep_connected > 0)
>> 		xprt->reestablish_timeout =3D 0;
>> -	xprt_disconnect_done(xprt);
>> 	rpcrdma_ep_disconnect(ep, ia);
>>=20
>> 	/* Prepare @xprt for the next connection by reinitializing
>> @@ -467,6 +467,10 @@
>> 	 */
>> 	r_xprt->rx_buf.rb_credits =3D 1;
>> 	xprt->cwnd =3D RPC_CWNDSHIFT;
>> +
>> +out:
>> +	++xprt->connect_cookie;
>> +	xprt_disconnect_done(xprt);
>> }
>>=20
>> /**
>> @@ -515,7 +519,7 @@
>> static void
>> xprt_rdma_timer(struct rpc_xprt *xprt, struct rpc_task *task)
>> {
>> -	xprt_force_disconnect(xprt);
>> +	xprt_disconnect_nowake(xprt);
>> }
>>=20
>> /**
>> @@ -717,7 +721,7 @@
>> #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
>>=20
>> 	if (!xprt_connected(xprt))
>> -		goto drop_connection;
>> +		return -ENOTCONN;
>>=20
>> 	if (!xprt_request_get_cong(xprt, rqst))
>> 		return -EBADSLT;
>> @@ -749,8 +753,8 @@
>> 	if (rc !=3D -ENOTCONN)
>> 		return rc;
>> drop_connection:
>> -	xprt_disconnect_done(xprt);
>> -	return -ENOTCONN;	/* implies disconnect */
>> +	xprt_rdma_close(xprt);
>> +	return -ENOTCONN;
>> }
>>=20
>> void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file
>> *seq)
>> diff --git a/net/sunrpc/xprtrdma/verbs.c
>> b/net/sunrpc/xprtrdma/verbs.c
>> index 9a0a765..38a757c 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -252,7 +252,7 @@ static void rpcrdma_xprt_drain(struct
>> rpcrdma_xprt *r_xprt)
>> #endif
>> 		set_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags);
>> 		ep->rep_connected =3D -ENODEV;
>> -		xprt_force_disconnect(xprt);
>> +		xprt_disconnect_nowake(xprt);
>> 		wait_for_completion(&ia->ri_remove_done);
>>=20
>> 		ia->ri_id =3D NULL;
>> @@ -280,10 +280,9 @@ static void rpcrdma_xprt_drain(struct
>> rpcrdma_xprt *r_xprt)
>> 			ep->rep_connected =3D -EAGAIN;
>> 		goto disconnected;
>> 	case RDMA_CM_EVENT_DISCONNECTED:
>> -		++xprt->connect_cookie;
>> 		ep->rep_connected =3D -ECONNABORTED;
>> disconnected:
>> -		xprt_force_disconnect(xprt);
>> +		xprt_disconnect_nowake(xprt);
>> 		wake_up_all(&ep->rep_connect_wait);
>> 		break;
>> 	default:
>>=20
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

--
Chuck Lever



