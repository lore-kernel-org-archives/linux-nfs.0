Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 375E7C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 16:41:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ED1942073D
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 16:41:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="aI/bn2vk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732330AbfACQlZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 11:41:25 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:52884 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726618AbfACQlZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 11:41:25 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x03Gck2o144960;
        Thu, 3 Jan 2019 16:41:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=At/JKnJQJjzO3/9ncSopXb0twSeVbiaImV2YS+55GRI=;
 b=aI/bn2vknmpRXV+dALRZfkIhD5bhbYNfinsAHEZ7/bESDb/Ivxv3blLKg6zb8w5cly9b
 rO03XhaqdjcEZTrwDjXRvxZ4xMzwssBPm5lH0oA09c+ZYmYSKL9FYBDf07MfQ3ooMjqA
 yzwWaZVwkMmxUhVRikqh43YqYyYWWjyRZF3ep/Efl8FFJMFqpbWSGavtA9VjWf3P3uH3
 oyIuPoK7dQ5rQLkbZo6wr6mqQfbDcnMXTTQVkHiKaGGo7KMO90EhQ8ZQcMXKlqP4pE43
 +Sy1ClxFVQwRnIgHF3e2QDhfmPWKrL2ZAk1mDVWHmXZldhcJJYMtjDkJcgkGx37ty5V3 0w== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2pp1jr80sg-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 03 Jan 2019 16:41:22 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x03GfKB1031218
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 3 Jan 2019 16:41:21 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x03GfKDd005953;
        Thu, 3 Jan 2019 16:41:20 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 03 Jan 2019 08:41:20 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request
 transmission
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <6e18b8ce25652bf17d6d1fa95c3a6127767cb45b.camel@hammerspace.com>
Date:   Thu, 3 Jan 2019 11:41:18 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <0044B1EA-215B-412C-B1C6-0D1767B3CCEE@oracle.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
 <20190102225313.2097-2-trond.myklebust@hammerspace.com>
 <1B5E1F96-246A-43AB-B9CE-FA41C595ADFF@oracle.com>
 <6e18b8ce25652bf17d6d1fa95c3a6127767cb45b.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9124 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901030147
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 3, 2019, at 11:05 AM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Thu, 2019-01-03 at 10:29 -0500, Chuck Lever wrote:
>> Hi Trond-
>>=20
>> I was curious about this one because yesterday I saw evidence (for
>> other reasons) that rq_bytes_sent wasn't always zeroed when it should
>> be.
>>=20
>>=20
>>> On Jan 2, 2019, at 5:53 PM, Trond Myklebust <trondmy@gmail.com>
>>> wrote:
>>>=20
>>> When we resend a request, ensure that the 'rq_bytes_sent' is reset
>>> to zero.
>>>=20
>>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
>>> ---
>>> net/sunrpc/clnt.c | 1 -
>>> net/sunrpc/xprt.c | 1 +
>>> 2 files changed, 1 insertion(+), 1 deletion(-)
>>>=20
>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>> index 24cbddc44c88..2189fbc4c570 100644
>>> --- a/net/sunrpc/clnt.c
>>> +++ b/net/sunrpc/clnt.c
>>> @@ -1738,7 +1738,6 @@ rpc_xdr_encode(struct rpc_task *task)
>>> 	xdr_buf_init(&req->rq_rcv_buf,
>>> 		     req->rq_rbuffer,
>>> 		     req->rq_rcvsize);
>>> -	req->rq_bytes_sent =3D 0;
>>=20
>> I agree this line is not sufficient, and it should be moved.
>> Not every retransmission requires a re-encode. However, the
>> patch description should explain that, and it probably needs
>> a Fixes: tag.
>>=20
>> Can you now also remove the same line from xprt_request_init
>> and xprt_init_bc_request ?
>>=20
>> Also, I notice that UDP does not touch rq_bytes_sent. Since
>> RDMA also does not use rq_bytes_sent, maybe the same line
>> can be removed from xprtrdma/transport.c and
>> xprtrdma/backchannel.c ?
>=20
> Sure.
>=20
> So please note that rq_bytes_sent =3D=3D 0 no longer means "this =
request
> needs to be retransmitted" and we no longer test for it in
> net/sunrpc/clnt.c. We do still have a couple of tests of rq_bytes_sent
> in net/sunrpc/xprt.c and net/sunrpc/xprtsock.c, but those are more
> about checking if a transmission of that request is currently in
> progress, in which case we don't want to queue anything in front of it
> on the transmission queue, and we don't want to abort the transmission
> unless we also close the socket.
>=20
> The intention now is that if we know the request needs retransmission
> (due to a transport connection loss or a timeout), then we just add it
> to the transmission queue.
>=20
>=20
>>> 	p =3D rpc_encode_header(task);
>>> 	if (p =3D=3D NULL) {
>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>> index 73547d17d3c6..9075ae150ae5 100644
>>> --- a/net/sunrpc/xprt.c
>>> +++ b/net/sunrpc/xprt.c
>>> @@ -1151,6 +1151,7 @@ xprt_request_enqueue_transmit(struct rpc_task
>>> *task)
>>> 	struct rpc_xprt *xprt =3D req->rq_xprt;
>>>=20
>>> 	if (xprt_request_need_enqueue_transmit(task, req)) {
>>> +		req->rq_bytes_sent =3D 0;
>>> 		spin_lock(&xprt->queue_lock);
>>> 		/*
>>> 		 * Requests that carry congestion control credits are
>>> added
>>=20
>> So I'm not convinced this covers every case. I need some
>> time to investigate.
>=20
> It should normally cover all cases. As I said, the only remaining =
tests
> are in xprt.c and  xprtsock.c

In the patch I have that removes xprt::tsh_size, I'm using rq_bytes_sent
to figure out when to insert a record marker. Every once in a while, it
sticks in a record marker where it shouldn't.


--
Chuck Lever



