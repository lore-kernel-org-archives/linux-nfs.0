Return-Path: <SRS0=ZJCY=PT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E045C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Jan 2019 22:27:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 321E020657
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Jan 2019 22:27:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="zb8kCLUQ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725783AbfAKW1j (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 11 Jan 2019 17:27:39 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:41076 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725767AbfAKW1j (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jan 2019 17:27:39 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0BMOEu2189047;
        Fri, 11 Jan 2019 22:27:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=efKGSVs8KPsaec53v5C4Bi3UeXVOoKnyli5QYLvFn0Y=;
 b=zb8kCLUQgnx9ik8jgeB4zk1hO8XQU/dRS+jZ94Dty9uEy3VtRgzHivip5n62H4ZhuNf9
 JFU/1qCIzEvwFkkZCHcP0ZW03kN0cTzw3xpRhY9mZU4sCVrXXvdZZMizh3LPrUX+LfgJ
 GyqDTPbAyqKuSFq4gCnoEFpkh0veCCvG/KFcGR42RUWMtYycxtmy04Ty2EJOwiYa0Sj8
 3ZeA2GDoQzyQ4pyMARyN4kBKW958B0Yjqeh90siws8nCvexWPK08w20lYOtEuYrqnqRB
 1OsgSz+FLYI7tIt/WZI4mxpycPnpjufkKG++tPPq+ESxhVOupphCXpJviqqoe9Lh3Kdx Cg== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2130.oracle.com with ESMTP id 2ptm0uqcp5-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 11 Jan 2019 22:27:35 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0BMRZ7d006479
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 11 Jan 2019 22:27:35 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0BMRWog016512;
        Fri, 11 Jan 2019 22:27:34 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 11 Jan 2019 14:27:32 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190111221030.GA28794@fieldses.org>
Date:   Fri, 11 Jan 2019 17:27:30 -0500
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <A33F8CE5-3E5D-4359-8061-8DB8214B012B@oracle.com>
References: <20190104173912.GC11787@fieldses.org>
 <20190107213218.GD7753@fieldses.org>
 <e14e17167ef98c456e7648ad0536827b7870f0ff.camel@hammerspace.com>
 <20190108150107.GA15921@fieldses.org>
 <4077991d3d3acee4c37c7c8c6dc2b76930c9584e.camel@hammerspace.com>
 <20190109165142.GB32189@fieldses.org>
 <300445038b75d5efafe9391eb4b8e83d9d6e3633.camel@hammerspace.com>
 <20190111211235.GA27206@fieldses.org>
 <BB7240BE-3F20-43AD-B709-7F18CC33CC02@oracle.com>
 <6F5B73B7-E9F8-4FDB-8381-E5C02772C6A5@oracle.com>
 <20190111221030.GA28794@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9133 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=845
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901110177
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 11, 2019, at 5:10 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Fri, Jan 11, 2019 at 04:54:01PM -0500, Chuck Lever wrote:
>>> On Jan 11, 2019, at 4:52 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>> So, I think we need your patch plus something like this.
>>>>=20
>>>> Chuck, maybe you could help me with the "XXX: Chuck:" parts?
>>>=20
>>> I haven't been following. Why do you think those are necessary?
>=20
> I'm worried something like this could happen:
>=20
> 	CPU 1				CPU 2
> 	-----				-----
>=20
> 	set XPT_DATA			dec xpt_nr_rqsts
>=20
> 	svc_xprt_enqueue		svc_xprt_enqueue
>=20
> And both decide nothing should be done if neither sees the change that
> the other made.
>=20
> Maybe I'm still missing some reason that couldn't happen.
>=20
> Even if it can happen, it's an unlikely race that will likely be fixed
> when another event comes along a little later, which would explain why
> we've never seen any reports.
>=20
>>> We've had set_bit and atomic_{inc,dec} in this code for ages,
>>> and I've never noticed a problem.
>>>=20
>>> Rather than adding another CPU pipeline bubble in the RDMA code,
>>> though, could you simply move the set_bit() call site inside the
>>> critical sections?
>>=20
>> er, inside the preceding critical section. Just reverse the order
>> of the spin_unlock and the set_bit.
>=20
> That'd do it, thanks!

I can try that here and see if it results in a performance regression.


> --b.
>=20
>>=20
>>=20
>>>=20
>>>=20
>>>> (This applies on top of your patch plus another that just renames =
the
>>>> stupidly long svc_xprt_has_something_to_do() to svc_xprt_read().)
>>>>=20
>>>> --b.
>>>>=20
>>>> commit d7356c3250d4
>>>> Author: J. Bruce Fields <bfields@redhat.com>
>>>> Date:   Fri Jan 11 15:36:40 2019 -0500
>>>>=20
>>>>  svcrpc: fix unlikely races preventing queueing of sockets
>>>>=20
>>>>  In the rpc server, When something happens that might be reason to =
wake
>>>>  up a thread to do something, what we do is
>>>>=20
>>>>          - modify xpt_flags, sk_sock->flags, xpt_reserved, or
>>>>            xpt_nr_rqsts to indicate the new situation
>>>>          - call svc_xprt_enqueue() to decide whether to wake up a =
thread.
>>>>=20
>>>>  svc_xprt_enqueue may require multiple conditions to be true before
>>>>  queueing up a thread to handle the xprt.  In the SMP case, one of =
the
>>>>  other CPU's may have set another required condition, and in that =
case,
>>>>  although both CPUs run svc_xprt_enqueue(), it's possible that =
neither
>>>>  call sees the writes done by the other CPU in time, and neither =
one
>>>>  recognizes that all the required conditions have been set.  A =
socket
>>>>  could therefore be ignored indefinitely.
>>>>=20
>>>>  Add memory barries to ensure that any svc_xprt_enqueue() call will
>>>>  always see the conditions changed by other CPUs before deciding to
>>>>  ignore a socket.
>>>>=20
>>>>  I've never seen this race reported.  In the unlikely event it =
happens,
>>>>  another event will usually come along and the problem will fix =
itself.
>>>>  So I don't think this is worth backporting to stable.
>>>>=20
>>>>  Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>>>=20
>>>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>>>> index d410ae512b02..2af21b84b3b6 100644
>>>> --- a/net/sunrpc/svc_xprt.c
>>>> +++ b/net/sunrpc/svc_xprt.c
>>>> @@ -357,6 +357,7 @@ static void svc_xprt_release_slot(struct =
svc_rqst *rqstp)
>>>> 	struct svc_xprt	*xprt =3D rqstp->rq_xprt;
>>>> 	if (test_and_clear_bit(RQ_DATA, &rqstp->rq_flags)) {
>>>> 		atomic_dec(&xprt->xpt_nr_rqsts);
>>>> +		smp_wmb(); /* See smp_rmb() in svc_xprt_ready() */
>>>> 		svc_xprt_enqueue(xprt);
>>>> 	}
>>>> }
>>>> @@ -365,6 +366,15 @@ static bool svc_xprt_ready(struct svc_xprt =
*xprt)
>>>> {
>>>> 	unsigned long xpt_flags;
>>>>=20
>>>> +	/*
>>>> +	 * If another cpu has recently updated xpt_flags,
>>>> +	 * sk_sock->flags, xpt_reserved, or xpt_nr_rqsts, we need to
>>>> +	 * know about it; otherwise it's possible that both that cpu and
>>>> +	 * this one could call svc_xprt_enqueue() without either
>>>> +	 * svc_xprt_enqueue() recognizing that the conditions below
>>>> +	 * are satisfied, and we could stall indefinitely:
>>>> +	 */
>>>> +	smp_rmb();
>>>> 	READ_ONCE(xprt->xpt_flags);
>>>>=20
>>>> 	if (xpt_flags & (BIT(XPT_CONN) | BIT(XPT_CLOSE)))
>>>> @@ -479,7 +489,7 @@ void svc_reserve(struct svc_rqst *rqstp, int =
space)
>>>> 	if (xprt && space < rqstp->rq_reserved) {
>>>> 		atomic_sub((rqstp->rq_reserved - space), =
&xprt->xpt_reserved);
>>>> 		rqstp->rq_reserved =3D space;
>>>> -
>>>> +		smp_wmb(); /* See smp_rmb() in svc_xprt_ready() */
>>>> 		svc_xprt_enqueue(xprt);
>>>> 	}
>>>> }
>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c =
b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>>> index 828b149eaaef..377244992ae8 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>>> @@ -316,6 +316,7 @@ static void svc_rdma_wc_receive(struct ib_cq =
*cq, struct ib_wc *wc)
>>>> 	list_add_tail(&ctxt->rc_list, &rdma->sc_rq_dto_q);
>>>> 	spin_unlock(&rdma->sc_rq_dto_lock);
>>>> 	set_bit(XPT_DATA, &rdma->sc_xprt.xpt_flags);
>>>> +	/* XXX: Chuck: do we need an smp_mb__after_atomic() here? */
>>>> 	if (!test_bit(RDMAXPRT_CONN_PENDING, &rdma->sc_flags))
>>>> 		svc_xprt_enqueue(&rdma->sc_xprt);
>>>> 	goto out;
>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c =
b/net/sunrpc/xprtrdma/svc_rdma_rw.c
>>>> index dc1951759a8e..e1a790487d69 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
>>>> @@ -290,6 +290,7 @@ static void svc_rdma_wc_read_done(struct ib_cq =
*cq, struct ib_wc *wc)
>>>> 		spin_unlock(&rdma->sc_rq_dto_lock);
>>>>=20
>>>> 		set_bit(XPT_DATA, &rdma->sc_xprt.xpt_flags);
>>>> +		/* XXX: Chuck: do we need a smp_mb__after_atomic() here? =
*/
>>>> 		svc_xprt_enqueue(&rdma->sc_xprt);
>>>> 	}
>>>>=20
>>>=20
>>> --
>>> Chuck Lever
>>=20
>> --
>> Chuck Lever
>>=20
>>=20

--
Chuck Lever



