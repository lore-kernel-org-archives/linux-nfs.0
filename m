Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B62BEC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 22:06:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7530421473
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 22:06:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uu0ItE0O"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730181AbeLQWGo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 17:06:44 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:56908 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726574AbeLQWGo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 17:06:44 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBHM41j3032833;
        Mon, 17 Dec 2018 22:06:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=ch7130DLWr/r0UTpZ3sTJQDM0t7sF+XChwxNvsOfW3U=;
 b=uu0ItE0OXwMwE+ge2a0LQmKg3LGBse8lZ0JxEVV0etX00i9biwQYuGV65vpyVDwlX/6w
 xVG/K0cvZtYELbJMsLdaNWLcKySnxB/lIO8r0r/V+kjvocDyqhwYZ37OVDrlNyLpPb2c
 JkDLF7V+yeJlLCdECQu6Gqb+dPGn7+g6gk9VcZrb7Fc1K/jj+/IY+pGk2SThpMU6fU5T
 LaGRQkrdyugl84JtOSdVtu0Y6IfpON6mTnTM+LLA22bTn/h2euD79+GeDpPcPn3J88Dy
 /FedH1hvW3lSD0cPCsvO4CFS3z3lpWym5nI2V7IXDFihRCRokiE8vqByr8IzG+NI+Uxt nw== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2pcq4dr9d9-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 17 Dec 2018 22:06:39 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBHM6d78016373
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 17 Dec 2018 22:06:39 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBHM6cYY005541;
        Mon, 17 Dec 2018 22:06:38 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 17 Dec 2018 14:06:38 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] SUNRPC: Fix disconnection races
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181217200524.105368-1-trond.myklebust@hammerspace.com>
Date:   Mon, 17 Dec 2018 17:06:36 -0500
Cc:     Dave Wysochanski <dwysocha@redhat.com>,
        Scott Mayhew <smayhew@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <1D3503CB-1B9A-459B-980B-A71D0191CFA9@oracle.com>
References: <20181217200524.105368-1-trond.myklebust@hammerspace.com>
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9110 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812170194
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 17, 2018, at 3:05 PM, Trond Myklebust <trondmy@gmail.com> =
wrote:
>=20
> When the socket is closed, we need to call xprt_disconnect_done() in =
order
> to clean up the XPRT_WRITE_SPACE flag, and wake up the sleeping tasks.
>=20
> However, we also want to ensure that we don't wake them up before the =
socket
> is closed, since that would cause thundering herd issues with everyone
> piling up to retransmit before the TCP shutdown dance has completed.
> Only the task that holds XPRT_LOCKED needs to wake up early in order =
to
> allow the close to complete.
>=20
> Reported-by: Dave Wysochanski <dwysocha@redhat.com>
> Reported-by: Scott Mayhew <smayhew@redhat.com>
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/xprt.c     |  4 +++-
> net/sunrpc/xprtsock.c | 10 ++++------
> 2 files changed, 7 insertions(+), 7 deletions(-)
>=20
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index ce927002862a..089e53a87379 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -680,7 +680,9 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
> 	/* Try to schedule an autoclose RPC call */
> 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) =3D=3D 0)
> 		queue_work(xprtiod_workqueue, &xprt->task_cleanup);
> -	xprt_wake_pending_tasks(xprt, -EAGAIN);
> +	else if (xprt->snd_task)
> +		rpc_wake_up_queued_task_set_status(&xprt->pending,
> +				xprt->snd_task, -ENOTCONN);
> 	spin_unlock_bh(&xprt->transport_lock);
> }
> EXPORT_SYMBOL_GPL(xprt_force_disconnect);

Hrm, well I'm not sure xprt_connect_status is ready to deal with =
-ENOTCONN.

     kworker/2:3-2342  [002]  3706.246289: rpc_task_wakeup:      =
task:39992@5 flags=3D0001 state=3D001e status=3D-107 timeout=3D120000 =
queue=3Dxprt_pending
     kworker/0:7-2424  [000]  3706.246296: xprtrdma_reconnect:   =
peer=3D[192.168.2.55]:20049 r_xprt=3D0xffff88886c465000
  kworker/u25:28-2270  [004]  3706.246321: rpc_task_run_action:  =
task:39992@5 flags=3D0001 state=3D001d status=3D-107 =
action=3Dxprt_connect_status
  kworker/u25:28-2270  [004]  3706.246323: rpc_task_run_action:  =
task:39992@5 flags=3D0001 state=3D001d status=3D-5 =
action=3Dcall_connect_status
  kworker/u25:28-2270  [004]  3706.246323: rpc_connect_status:   =
task:39992@5 status=3D-5
  kworker/u25:28-2270  [004]  3706.246324: rpc_task_run_action:  =
task:39992@5 flags=3D0001 state=3D001d status=3D-5 action=3Drpc_exit_task
  kworker/u25:28-2270  [004]  3706.246327: rpc_stats_latency:    =
task:39992@5 xid=3D0x2f1ad350 nfsv3 READ backlog=3D0 rtt=3D0 =
execute=3D13028
  kworker/u25:28-2270  [004]  3706.246333: xprtrdma_rpc_done:    =
task:39992@5 req=3D0xffff88886a438000 rep=3D(nil)

static void xprt_connect_status(struct rpc_task *task)
{
        switch (task->tk_status) {
        case 0:
                dprintk("RPC: %5u xprt_connect_status: connection =
established\n",
                                task->tk_pid);
                break;
        case -ECONNREFUSED:
        case -ECONNRESET:
        case -ECONNABORTED:
        case -ENETUNREACH:
        case -EHOSTUNREACH:
        case -EPIPE:
        case -EAGAIN:
                dprintk("RPC: %5u xprt_connect_status: retrying\n", =
task->tk_pid);
                break;
        case -ETIMEDOUT:
                dprintk("RPC: %5u xprt_connect_status: connect attempt =
timed "
                                "out\n", task->tk_pid);
                break;
        default:
                dprintk("RPC: %5u xprt_connect_status: error %d =
connecting to "
                                "server %s\n", task->tk_pid, =
-task->tk_status,
                                task->tk_rqstp->rq_xprt->servername);
                task->tk_status =3D -EIO;
        }   =20
}

Maybe the wake-up status should remain -EAGAIN ?


> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 8a5e823e0b33..f0b3700cec95 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1217,6 +1217,8 @@ static void xs_reset_transport(struct sock_xprt =
*transport)
>=20
> 	trace_rpc_socket_close(xprt, sock);
> 	sock_release(sock);
> +
> +	xprt_disconnect_done(xprt);
> }
>=20
> /**
> @@ -1237,8 +1239,6 @@ static void xs_close(struct rpc_xprt *xprt)
>=20
> 	xs_reset_transport(transport);
> 	xprt->reestablish_timeout =3D 0;
> -
> -	xprt_disconnect_done(xprt);
> }
>=20
> static void xs_inject_disconnect(struct rpc_xprt *xprt)
> @@ -1489,8 +1489,6 @@ static void xs_tcp_state_change(struct sock *sk)
> 					&transport->sock_state))
> 			xprt_clear_connecting(xprt);
> 		clear_bit(XPRT_CLOSING, &xprt->state);
> -		if (sk->sk_err)
> -			xprt_wake_pending_tasks(xprt, -sk->sk_err);
> 		/* Trigger the socket release */
> 		xs_tcp_force_close(xprt);
> 	}
> @@ -2092,8 +2090,8 @@ static void xs_udp_setup_socket(struct =
work_struct *work)
> 	trace_rpc_socket_connect(xprt, sock, 0);
> 	status =3D 0;
> out:
> -	xprt_unlock_connect(xprt, transport);
> 	xprt_clear_connecting(xprt);
> +	xprt_unlock_connect(xprt, transport);
> 	xprt_wake_pending_tasks(xprt, status);
> }
>=20
> @@ -2329,8 +2327,8 @@ static void xs_tcp_setup_socket(struct =
work_struct *work)
> 	}
> 	status =3D -EAGAIN;
> out:
> -	xprt_unlock_connect(xprt, transport);
> 	xprt_clear_connecting(xprt);
> +	xprt_unlock_connect(xprt, transport);
> 	xprt_wake_pending_tasks(xprt, status);
> }
>=20
> --=20
> 2.19.2
>=20

--
Chuck Lever



