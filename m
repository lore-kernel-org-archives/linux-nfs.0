Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:39472 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726046AbeIEVFk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 17:05:40 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2 23/34] SUNRPC: Move RPC retransmission stat counter to
 xprt_transmit()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <ef24000fac4084d52eabc141e3f3b768542431a4.camel@hammerspace.com>
Date: Wed, 5 Sep 2018 12:34:37 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4961AEA0-E628-4F6B-A527-43FC1EF8A13E@oracle.com>
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
 <0A486690-38DA-4377-8968-DF0008113479@oracle.com>
 <4165cdf8162f9ca6aa1165c71e880632fda259ec.camel@hammerspace.com>
 <85D647A8-CD05-4B29-BD69-08F653EEF122@oracle.com>
 <ef24000fac4084d52eabc141e3f3b768542431a4.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Sep 5, 2018, at 12:07 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Wed, 2018-09-05 at 11:31 -0400, Chuck Lever wrote:
>>> On Sep 5, 2018, at 11:28 AM, Trond Myklebust <
>>> trondmy@hammerspace.com> wrote:
>>>=20
>>> On Wed, 2018-09-05 at 10:30 -0400, Chuck Lever wrote:
>>>>> On Sep 4, 2018, at 5:05 PM, Trond Myklebust <trondmy@gmail.com>
>>>>> wrote:
>>>>>=20
>>>>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com
>>>>>>=20
>>>>> ---
>>>>> net/sunrpc/clnt.c |  6 ------
>>>>> net/sunrpc/xprt.c | 13 ++++++-------
>>>>> 2 files changed, 6 insertions(+), 13 deletions(-)
>>>>>=20
>>>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>>>> index 032b7042adb6..21713bed812a 100644
>>>>> --- a/net/sunrpc/clnt.c
>>>>> +++ b/net/sunrpc/clnt.c
>>>>> @@ -1967,8 +1967,6 @@ call_connect_status(struct rpc_task
>>>>> *task)
>>>>> static void
>>>>> call_transmit(struct rpc_task *task)
>>>>> {
>>>>> -	int is_retrans =3D RPC_WAS_SENT(task);
>>>>> -
>>>>> 	dprint_status(task);
>>>>>=20
>>>>> 	task->tk_action =3D call_transmit_status;
>>>>> @@ -1979,10 +1977,6 @@ call_transmit(struct rpc_task *task)
>>>>> 	if (!xprt_prepare_transmit(task))
>>>>> 		return;
>>>>> 	xprt_transmit(task);
>>>>> -	if (task->tk_status < 0)
>>>>> -		return;
>>>>> -	if (is_retrans)
>>>>> -		task->tk_client->cl_stats->rpcretrans++;
>>>>> }
>>>>>=20
>>>>> /*
>>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>>> index f1301d391399..e2f5b4668a66 100644
>>>>> --- a/net/sunrpc/xprt.c
>>>>> +++ b/net/sunrpc/xprt.c
>>>>> @@ -191,8 +191,6 @@ int xprt_reserve_xprt(struct rpc_xprt
>>>>> *xprt,
>>>>> struct rpc_task *task)
>>>>> 		goto out_sleep;
>>>>> 	}
>>>>> 	xprt->snd_task =3D task;
>>>>> -	if (req !=3D NULL)
>>>>> -		req->rq_ntrans++;
>>>>>=20
>>>>> 	return 1;
>>>>>=20
>>>>> @@ -247,7 +245,6 @@ int xprt_reserve_xprt_cong(struct rpc_xprt
>>>>> *xprt, struct rpc_task *task)
>>>>> 	}
>>>>> 	if (__xprt_get_cong(xprt, task)) {
>>>>> 		xprt->snd_task =3D task;
>>>>> -		req->rq_ntrans++;
>>>>> 		return 1;
>>>>> 	}
>>>>> 	xprt_clear_locked(xprt);
>>>>> @@ -281,12 +278,8 @@ static inline int xprt_lock_write(struct
>>>>> rpc_xprt *xprt, struct rpc_task *task)
>>>>> static bool __xprt_lock_write_func(struct rpc_task *task, void
>>>>> *data)
>>>>> {
>>>>> 	struct rpc_xprt *xprt =3D data;
>>>>> -	struct rpc_rqst *req;
>>>>>=20
>>>>> -	req =3D task->tk_rqstp;
>>>>> 	xprt->snd_task =3D task;
>>>>> -	if (req)
>>>>> -		req->rq_ntrans++;
>>>>> 	return true;
>>>>> }
>>>>>=20
>>>>> @@ -1126,6 +1119,7 @@ void xprt_transmit(struct rpc_task *task)
>>>>> 	struct rpc_rqst	*req =3D task->tk_rqstp;
>>>>> 	struct rpc_xprt	*xprt =3D req->rq_xprt;
>>>>> 	unsigned int connect_cookie;
>>>>> +	int is_retrans =3D RPC_WAS_SENT(task);
>>>>> 	int status;
>>>>>=20
>>>>> 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid,
>>>>> req-
>>>>>> rq_slen);
>>>>>=20
>>>>> @@ -1140,6 +1134,8 @@ void xprt_transmit(struct rpc_task *task)
>>>>> 		}
>>>>> 	}
>>>>>=20
>>>>> +	req->rq_ntrans++;
>>>>> +
>>>>=20
>>>> rq_ntrans is used in two places:
>>>>=20
>>>> 1. rpc_update_rtt
>>>> 2. rpc_count_iostats_metrics
>>>>=20
>>>> Both of these appear to assume that rq_ntrans is counting
>>>> full successful transmissions (ie, calls that appear on the
>>>> wire), not invocations of ->send_request().
>>>>=20
>>>> Can this counter be moved down to where rpcretrans is updated?
>>>>=20
>>>=20
>>> The reason why I don't want to update req->rq_ntrans after
>>> transmission
>>> is because that would race with the reply from the server (which is
>>> not
>>> blocked by the XPRT_LOCK). In that race scenario, rpc_update_rtt()
>>> could update the RTT value before we've updated the req->rq_ntrans,
>>> meaning that we might be measuring the response time against a
>>> reply to
>>> the original transmission or to the retransmission that was just
>>> sent.
>>> That would end up breaking Van Jacobsen congestion control, since
>>> we
>>> risk significantly underestimating the RTT value.
>>=20
>> But for transports that don't use xprt_update_rtt, error
>> returns from ->send_request() (like -EAGAIN or -ENOBUFS)
>> means that rq_ntrans is counted twice, and it shows up as
>> false retransmissions.
>=20
> That's the way it has always worked.

Not quite: the current xprt_reserve_xprt_cong has a latch -- rq_cong.
req->rq_ntrans is bumped only once when it gets a congestion credit.

The transport send lock is held until enough ->send_request calls
have been done to transmit the whole Call message, but rq_ntrans
is bumped only once per full RPC Call message.

Note that this code is a little dodgy for xprt_reserve_xprt: when
driving a connect, the RPC task takes and releases the transport
send lock twice, and both times it bumps rq_ntrans, which is a bug.
This patch appears to fix that.


> The Van Jacobsen code was
> implemented long before the per-request stats were introduced, and so
> the behaviour of req->rq_ntrans has always been to update the value
> before we transmit.

>> What if rq_ntrans was bumped in the transport code instead?
>=20
> If we must change the behaviour, then why not just have the generic
> layer 'unbump' the counter on an incomplete transmission?

OK. There's no way for a reply to arrive if the call hasn't been
fully transmitted, so a race is avoided in that case.

--
Chuck Lever
