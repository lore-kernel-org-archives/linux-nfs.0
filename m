Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F01D4C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 19:00:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B8415214C6
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 19:00:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="kbz85/EE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733057AbeLQTAT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 14:00:19 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:36114 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727705AbeLQTAT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 14:00:19 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBHIxJ73087017;
        Mon, 17 Dec 2018 19:00:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=t2sScUu1gRpDTPn2nG8B0EflTH9C+JOKcoCTJzLctdc=;
 b=kbz85/EEpnicMvBS7aLHlql4jyT6/6FwSgmlitTczTTnl0igM1R6vLlxss8znLO1b9kZ
 0kNiRvUTWk5CkVYY1tjGhQXGVL1Qba7B+DTkxAL2zQ4GJ70azXRTtsk8CY9BbhhiVczQ
 tSV0Nj6O079c0ZlJ3/pE3c5e885WcRLwSNOi9HfDy6BA1nNFKJdFH5Dztfie1U2Dvtb+
 LF/4mSazDZGgm86t1Z8BxMiw5ZR4tEcVXhKO5ApYWNev/DwUPS/CDSVMkNnkz3gbgAX/
 hw9hpIA3VauyLy+z+7NU99NVwgWHKY7ppnqh0Y0bgHxf1uhkGGo+eEy5gCgNro/j/9O+ mw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2130.oracle.com with ESMTP id 2pcq4dqgjk-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 17 Dec 2018 19:00:13 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBHJ0Dle006272
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 17 Dec 2018 19:00:13 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBHJ0DSU016725;
        Mon, 17 Dec 2018 19:00:13 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 17 Dec 2018 11:00:13 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v4 06/30] xprtrdma: Don't wake pending tasks until
 disconnect is done
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <c639c203e1c9a5c0016a46e95ceb690744480583.camel@hammerspace.com>
Date:   Mon, 17 Dec 2018 14:00:11 -0500
Cc:     "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <6A4F0F5B-2D29-4A51-BC21-AF23B64D6ED7@oracle.com>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
 <20181217163953.24133.29214.stgit@manet.1015granger.net>
 <f080c79d6722ad339e47e20c6da72f9b0fc8a297.camel@hammerspace.com>
 <FD0CDDF9-EDEF-41C6-83F5-C956F3FF098E@oracle.com>
 <c639c203e1c9a5c0016a46e95ceb690744480583.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9110 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812170167
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 17, 2018, at 1:55 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Mon, 2018-12-17 at 13:37 -0500, Chuck Lever wrote:
>>> On Dec 17, 2018, at 12:28 PM, Trond Myklebust <
>>> trondmy@hammerspace.com> wrote:
>>>=20
>>> On Mon, 2018-12-17 at 11:39 -0500, Chuck Lever wrote:
>>>> Transport disconnect processing does a "wake pending tasks" at
>>>> various points.
>>>>=20
>>>> Suppose an RPC Reply is being processed. The RPC task that Reply
>>>> goes with is waiting on the pending queue. If a disconnect wake-
>>>> up
>>>> happens before reply processing is done, that reply, even if it
>>>> is
>>>> good, is thrown away, and the RPC has to be sent again.
>>>>=20
>>>> This window apparently does not exist for socket transports
>>>> because
>>>> there is a lock held while a reply is being received which
>>>> prevents
>>>> the wake-up call until after reply processing is done.
>>>>=20
>>>> To resolve this, all RPC replies being processed on an RPC-over-
>>>> RDMA
>>>> transport have to complete before pending tasks are awoken due to
>>>> a
>>>> transport disconnect.
>>>>=20
>>>> Callers that already hold the transport write lock may invoke
>>>> ->ops->close directly. Others use a generic helper that schedules
>>>> a close when the write lock can be taken safely.
>>>>=20
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> include/linux/sunrpc/xprt.h                |    1 +
>>>> net/sunrpc/xprt.c                          |   19
>>>> +++++++++++++++++++
>>>> net/sunrpc/xprtrdma/backchannel.c          |   13 +++++++------
>>>> net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    8 +++++---
>>>> net/sunrpc/xprtrdma/transport.c            |   16 ++++++++++-----
>>>> -
>>>> net/sunrpc/xprtrdma/verbs.c                |    5 ++---
>>>> 6 files changed, 44 insertions(+), 18 deletions(-)
>>>>=20
>>>> diff --git a/include/linux/sunrpc/xprt.h
>>>> b/include/linux/sunrpc/xprt.h
>>>> index a4ab4f8..ee94ed0 100644
>>>> --- a/include/linux/sunrpc/xprt.h
>>>> +++ b/include/linux/sunrpc/xprt.h
>>>> @@ -401,6 +401,7 @@ static inline __be32
>>>> *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *
>>>> bool			xprt_request_get_cong(struct rpc_xprt
>>>> *xprt,
>>>> struct rpc_rqst *req);
>>>> void			xprt_disconnect_done(struct rpc_xprt
>>>> *xprt);
>>>> void			xprt_force_disconnect(struct rpc_xprt
>>>> *xprt);
>>>> +void			xprt_disconnect_nowake(struct rpc_xprt
>>>> *xprt);
>>>> void			xprt_conditional_disconnect(struct
>>>> rpc_xprt
>>>> *xprt, unsigned int cookie);
>>>>=20
>>>> bool			xprt_lock_connect(struct rpc_xprt *,
>>>> struct
>>>> rpc_task *, void *);
>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>> index ce92700..afe412e 100644
>>>> --- a/net/sunrpc/xprt.c
>>>> +++ b/net/sunrpc/xprt.c
>>>> @@ -685,6 +685,25 @@ void xprt_force_disconnect(struct rpc_xprt
>>>> *xprt)
>>>> }
>>>> EXPORT_SYMBOL_GPL(xprt_force_disconnect);
>>>>=20
>>>> +/**
>>>> + * xprt_disconnect_nowake - force a call to xprt->ops->close
>>>> + * @xprt: transport to disconnect
>>>> + *
>>>> + * The caller must ensure that xprt_wake_pending_tasks() is
>>>> + * called later.
>>>> + */
>>>> +void xprt_disconnect_nowake(struct rpc_xprt *xprt)
>>>> +{
>>>> +       /* Don't race with the test_bit() in xprt_clear_locked()
>>>> */
>>>> +       spin_lock_bh(&xprt->transport_lock);
>>>> +       set_bit(XPRT_CLOSE_WAIT, &xprt->state);
>>>> +       /* Try to schedule an autoclose RPC call */
>>>> +       if (test_and_set_bit(XPRT_LOCKED, &xprt->state) =3D=3D 0)
>>>> +               queue_work(xprtiod_workqueue, &xprt-
>>>>> task_cleanup);
>>>> +       spin_unlock_bh(&xprt->transport_lock);
>>>> +}
>>>> +EXPORT_SYMBOL_GPL(xprt_disconnect_nowake);
>>>> +
>>>=20
>>> We shouldn't need both xprt_disconnect_nowake() and
>>> xprt_force_disconnect() to be exported given that you can build the
>>> latter from the former + xprt_wake_pending_tasks() (which is also
>>> already exported).
>>=20
>> Thanks for your review!
>>=20
>> I can get rid of xprt_disconnect_nowake. There are some variations,
>> depending on why wake_pending_tasks is protected by xprt-
>>> transport_lock.
>=20
> I'm having some second thoughts about the patch that Scott sent out
> last week to fix the issue that Dave and he were seeing. I think that
> what we really need to do to fix his issue is to call
> xprt_disconnect_done() after we've released the TCP socket.
>=20
> Given that realisation, I think that we can fix up
> xprt_force_disconnect() to only wake up the task that holds the
> XPRT_LOCKED instead of doing a thundering herd wakeup like we do =
today.
> That should (I think) obviate the need for a separate
> xprt_disconnect_nowake().

For RPC-over-RDMA, there really is a dangerous race between the waking
task(s) and work being done by the deferred RPC completion handler. IMO
the only safe thing RPC-over-RDMA can do is not wake anything until the
deferred queue is well and truly drained.

As you observed when we last spoke, socket transports are already
protected from this race by the socket lock.... RPC-over-RDMA is going
to have to be more careful.


> A patch is forthcoming later today. I'll make sure you are Cced so you
> can comment.
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

--
Chuck Lever



