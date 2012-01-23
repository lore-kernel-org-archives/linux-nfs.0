Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55636 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751909Ab2AWU5D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jan 2012 15:57:03 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q0NKukaV023688
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:56:47 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Add trace events to the sunrpc subsystem
Date: Mon, 23 Jan 2012 20:56:40 +0000
Message-ID: <7A6A4357-9C97-4402-9A4B-D2E1C2BDF5CF@netapp.com>
References: <1327081791-27455-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1327081791-27455-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_568C6206-9C83-4066-B0FE-FEB6A2B14C79";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_568C6206-9C83-4066-B0FE-FEB6A2B14C79
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Are you missing a call to tracepoint_synchronize_unregister in the =
module exit function?

-dros

On Jan 20, 2012, at 12:49 PM, Trond Myklebust wrote:

> Add declarations to allow tracing of RPC call creation, running, =
sleeping,
> and destruction.
>=20
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> include/trace/events/sunrpc.h |  124 =
+++++++++++++++++++++++++++++++++++++++++
> net/sunrpc/sched.c            |   13 ++++
> 2 files changed, 137 insertions(+), 0 deletions(-)
> create mode 100644 include/trace/events/sunrpc.h
>=20
> diff --git a/include/trace/events/sunrpc.h =
b/include/trace/events/sunrpc.h
> new file mode 100644
> index 0000000..1852f11
> --- /dev/null
> +++ b/include/trace/events/sunrpc.h
> @@ -0,0 +1,124 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM sunrpc
> +
> +#if !defined(_TRACE_SUNRPC_H)
> +#define _TRACE_SUNRPC_H
> +
> +#include <linux/sunrpc/sched.h>
> +#include <linux/sunrpc/clnt.h>
> +#include <linux/tracepoint.h>
> +
> +DECLARE_EVENT_CLASS(rpc_task_running,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task =
*task, const void *action),
> +
> +	TP_ARGS(clnt, task, action),
> +
> +	TP_STRUCT__entry(
> +		__field(const struct rpc_clnt *, clnt)
> +		__field(const struct rpc_task *, task)
> +		__field(const void *, action)
> +		__field(unsigned long, runstate)
> +		__field(int, status)
> +		__field(unsigned short, flags)
> +		),
> +
> +	TP_fast_assign(
> +		__entry->clnt =3D clnt;
> +		__entry->task =3D task;
> +		__entry->action =3D action;
> +		__entry->runstate =3D task->tk_runstate;
> +		__entry->status =3D task->tk_status;
> +		__entry->flags =3D task->tk_flags;
> +		),
> +
> +	TP_printk("task:%p@%p flags=3D%4.4x state=3D%4.4lx status=3D%d =
action=3D%pf",
> +		__entry->task,
> +		__entry->clnt,
> +		__entry->flags,
> +		__entry->runstate,
> +		__entry->status,
> +		__entry->action
> +		)
> +);
> +
> +DEFINE_EVENT(rpc_task_running, rpc_task_begin,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task =
*task, const void *action),
> +
> +	TP_ARGS(clnt, task, action)
> +
> +);
> +
> +DEFINE_EVENT(rpc_task_running, rpc_task_run_action,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task =
*task, const void *action),
> +
> +	TP_ARGS(clnt, task, action)
> +
> +);
> +
> +DEFINE_EVENT(rpc_task_running, rpc_task_complete,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task =
*task, const void *action),
> +
> +	TP_ARGS(clnt, task, action)
> +
> +);
> +
> +DECLARE_EVENT_CLASS(rpc_task_queued,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task =
*task, const struct rpc_wait_queue *q),
> +
> +	TP_ARGS(clnt, task, q),
> +
> +	TP_STRUCT__entry(
> +		__field(const struct rpc_clnt *, clnt)
> +		__field(const struct rpc_task *, task)
> +		__field(const struct rpc_wait_queue *, queue)
> +		__field(unsigned long, timeout)
> +		__field(unsigned long, runstate)
> +		__field(int, status)
> +		__field(unsigned short, flags)
> +		),
> +
> +	TP_fast_assign(
> +		__entry->clnt =3D clnt;
> +		__entry->task =3D task;
> +		__entry->queue =3D q;
> +		__entry->timeout =3D task->tk_timeout;
> +		__entry->runstate =3D task->tk_runstate;
> +		__entry->status =3D task->tk_status;
> +		__entry->flags =3D task->tk_flags;
> +		),
> +
> +	TP_printk("task:%p@%p flags=3D%4.4x state=3D%4.4lx status=3D%d =
timeout=3D%lu queue=3D%s",
> +		__entry->task,
> +		__entry->clnt,
> +		__entry->flags,
> +		__entry->runstate,
> +		__entry->status,
> +		__entry->timeout,
> +		rpc_qname(__entry->q)
> +		)
> +);
> +
> +DEFINE_EVENT(rpc_task_queued, rpc_task_sleep,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task =
*task, const struct rpc_wait_queue *q),
> +
> +	TP_ARGS(clnt, task, q)
> +
> +);
> +
> +DEFINE_EVENT(rpc_task_queued, rpc_task_wakeup,
> +
> +	TP_PROTO(const struct rpc_clnt *clnt, const struct rpc_task =
*task, const struct rpc_wait_queue *q),
> +
> +	TP_ARGS(clnt, task, q)
> +
> +);
> +
> +#endif /* _TRACE_SUNRPC_H */
> +
> +#include <trace/define_trace.h>
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index f982dfe..03f452a 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -28,6 +28,9 @@
> #define RPCDBG_FACILITY		RPCDBG_SCHED
> #endif
>=20
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/sunrpc.h>
> +
> /*
>  * RPC slabs and memory pools
>  */
> @@ -251,6 +254,8 @@ static inline void rpc_task_set_debuginfo(struct =
rpc_task *task)
>=20
> static void rpc_set_active(struct rpc_task *task)
> {
> +	trace_rpc_task_begin(task->tk_client, task, NULL);
> +
> 	rpc_task_set_debuginfo(task);
> 	set_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
> }
> @@ -267,7 +272,10 @@ static int rpc_complete_task(struct rpc_task =
*task)
> 	unsigned long flags;
> 	int ret;
>=20
> +	trace_rpc_task_complete(task->tk_client, task, NULL);
> +
> 	spin_lock_irqsave(&wq->lock, flags);
> +
> 	clear_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
> 	ret =3D atomic_dec_and_test(&task->tk_count);
> 	if (waitqueue_active(wq))
> @@ -324,6 +332,8 @@ static void __rpc_sleep_on_priority(struct =
rpc_wait_queue *q,
> 	dprintk("RPC: %5u sleep_on(queue \"%s\" time %lu)\n",
> 			task->tk_pid, rpc_qname(q), jiffies);
>=20
> +	trace_rpc_task_sleep(task->tk_client, task, q);
> +
> 	__rpc_add_wait_queue(q, task, queue_priority);
>=20
> 	BUG_ON(task->tk_callback !=3D NULL);
> @@ -378,6 +388,8 @@ static void __rpc_do_wake_up_task(struct =
rpc_wait_queue *queue, struct rpc_task
> 		return;
> 	}
>=20
> +	trace_rpc_task_wakeup(task->tk_client, task, queue);
> +
> 	__rpc_remove_wait_queue(queue, task);
>=20
> 	rpc_make_runnable(task);
> @@ -701,6 +713,7 @@ static void __rpc_execute(struct rpc_task *task)
> 			if (do_action =3D=3D NULL)
> 				break;
> 		}
> +		trace_rpc_task_run_action(task->tk_client, task, =
task->tk_action);
> 		do_action(task);
>=20
> 		/*
> --=20
> 1.7.7.5
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_568C6206-9C83-4066-B0FE-FEB6A2B14C79
Content-Disposition: attachment; filename="smime.p7s"
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIDTzCCA0sw
ggIzoAMCAQICAQEwCwYJKoZIhvcNAQEFMEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYD
VQQGEwJVUzEeMBwGCSqGSIb3DQEJARYPZHJvc0BuZXRhcHAuY29tMB4XDTExMDYwODIyMDc0NloX
DTEyMDYwNzIyMDc0NlowRjEXMBUGA1UEAwwOV2VzdG9uIEFkYW1zb24xCzAJBgNVBAYTAlVTMR4w
HAYJKoZIhvcNAQkBFg9kcm9zQG5ldGFwcC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC8/tJxtovJEXYRfSsrFOWKHxIZGY7/2mBee1DpWuoGDbVNapefCC7WXe+Nqxz609w2J/Mk
/k3trZ3Ge2NXK0tGnP9NzjkzpGA7rSpM3wUFsvbLMUEGfQpvV24/nYvcLHTvOOEUaDPpHduN94bD
dwvyowzDIRIpF2MeRnOzBNeHkrGHlZdzPmGjm8tkhrDRRkDYHhlxaiG4z30KCfAazxomuINiy1kj
vbndXooYMDoh9H63hgW4NkOedtLdflLa322DXQ3nFU7YbyOIjHVl1tgWJLDWf7WT3lsAB8KvuJZ5
zhsUB+fqxCKPJVRPDO1gjChvvtGiG1tGUUZz0H9Wx00zAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIH
gDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDBDAaBgNVHREEEzARgQ9kcm9zQG5ldGFwcC5jb20wDQYJ
KoZIhvcNAQEFBQADggEBACv0niZSmW+psB1sJXULh3mecDbN2mj0bFpN1YNdjcV7BiOLJ1Rs1ibV
f13h73z8C7SBsPXTM5si8gmJtOnXM5jsgtlql44h/RrjUr8+mtK5DPCZls9J7iz3cGthzwOPvxUj
nMSv3BpRX5oJom5ESgCM9Nn4u/ECTlLMhEIOYnBFiN0eDxcxz+r1cpbHg3r0otIKyxLpeaCjP6AH
F93EHp4T8Rb63y3CcDgxrQGHlTdVi3QvxaMUexUXD81fiA+UqsB/MKmRxB1Hs4Vf3Q/+ejcm78K1
ROF8TNPmNWRlKg3Y7cSFjZGzLuzXsvSsCbw4HLn0oZe/OfgSbarTAxttL5IxggHRMIIBzQIBATBL
MEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYDVQQGEwJVUzEeMBwGCSqGSIb3DQEJARYP
ZHJvc0BuZXRhcHAuY29tAgEBMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
MBwGCSqGSIb3DQEJBTEPFw0xMjAxMjMyMDU2NDBaMCMGCSqGSIb3DQEJBDEWBBTkzWZa1MoJ/2AU
TV22FgFlV4SfFDANBgkqhkiG9w0BAQEFAASCAQCZB0z6l5VNEysrWf+tKEogyZP1zDCqxby2j+2i
DzOBn8KfwhlBLLjdjZ9n06/3wMIDJHPI3NewbugXkC49Gj7Z6tLTdH+k4xLiQolO4z35r/Cqcifu
/CnazYcsI7oidI4NDxACpiI0LRyD/s69ngNbvuU8eNhUzMJrHpD5FuNkAz4td0xvxIpd85oEJYCY
jxIJGofwNix48AWxIeKpf0tf+VemGUHBRPlrFaeOpW2tBbOes03/tzEJUrGNfS1lOyR/fQWmqdMH
+E2hCqj+NsSvq9p/rsmOLNVhGxwNptsiieYR5y2/EdbMnoBFr7xIdeSZNRB1U+clSPsOqf7LRGt2
AAAAAAAA

--Apple-Mail=_568C6206-9C83-4066-B0FE-FEB6A2B14C79--
