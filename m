Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F39C1C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 16:39:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BA6652073D
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 16:39:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="sIS7Ts6w"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730590AbfACQj3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 11:39:29 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:57826 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726618AbfACQj2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 11:39:28 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x03GckOq186843;
        Thu, 3 Jan 2019 16:39:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=UYEovjVYFl8lMRsRTeaXIaKeqMsGypmEh+2tx6eVLIE=;
 b=sIS7Ts6w/x4CRN5wW2qEHMlzaya1JCH7KwpOL3OgYneNLlwGr6ExkCLJh1EEGROgOR2r
 sBGEaxAkTxR7lmN46k5Z8sMZlLfLfm/Ywdczpulb0YlrQxdePCA4p3XTRxiB58XnexD6
 PoD5XaG//1w/7rRIOW9oARQnXu6XOQ4IEEZHnHo9sv+4ww5ygAniUca8banN2OLXHHM8
 /+jHN+emHPxxDPaKNfXbuPkGxl63rXzegV1S1v5ewjEzoV7da4KInzGRK5gjXFigQKcc
 s78QJJCcAJoult+F7DuLl5ceXh4kG7pNH9W+AxzgeJWREebDtRijA7vOoNdLvQG0kE9c wQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2pp0bu040y-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 03 Jan 2019 16:39:24 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x03GdINR024886
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 3 Jan 2019 16:39:18 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x03GdIA6027181;
        Thu, 3 Jan 2019 16:39:18 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 03 Jan 2019 08:39:17 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request
 transmission
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <32eef80d-9129-3284-2f9d-15b9ca3930ec@talpey.com>
Date:   Thu, 3 Jan 2019 11:39:16 -0500
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <1E92DA38-0767-4D01-B46C-2EDC4F5B64B1@oracle.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
 <20190102225313.2097-2-trond.myklebust@hammerspace.com>
 <1B5E1F96-246A-43AB-B9CE-FA41C595ADFF@oracle.com>
 <6e18b8ce25652bf17d6d1fa95c3a6127767cb45b.camel@hammerspace.com>
 <32eef80d-9129-3284-2f9d-15b9ca3930ec@talpey.com>
To:     Tom Talpey <tom@talpey.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9124 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=824
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901030147
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 3, 2019, at 11:17 AM, Tom Talpey <tom@talpey.com> wrote:
>=20
> On 1/3/2019 11:05 AM, Trond Myklebust wrote:
>> On Thu, 2019-01-03 at 10:29 -0500, Chuck Lever wrote:
>>> Hi Trond-
>>>=20
>>> I was curious about this one because yesterday I saw evidence (for
>>> other reasons) that rq_bytes_sent wasn't always zeroed when it =
should
>>> be.
>>>=20
>>>=20
>>>> On Jan 2, 2019, at 5:53 PM, Trond Myklebust <trondmy@gmail.com>
>>>> wrote:
>>>>=20
>>>> When we resend a request, ensure that the 'rq_bytes_sent' is reset
>>>> to zero.
>>>>=20
>>>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
>>>> ---
>>>> net/sunrpc/clnt.c | 1 -
>>>> net/sunrpc/xprt.c | 1 +
>>>> 2 files changed, 1 insertion(+), 1 deletion(-)
>>>>=20
>>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>>> index 24cbddc44c88..2189fbc4c570 100644
>>>> --- a/net/sunrpc/clnt.c
>>>> +++ b/net/sunrpc/clnt.c
>>>> @@ -1738,7 +1738,6 @@ rpc_xdr_encode(struct rpc_task *task)
>>>> 	xdr_buf_init(&req->rq_rcv_buf,
>>>> 		     req->rq_rbuffer,
>>>> 		     req->rq_rcvsize);
>>>> -	req->rq_bytes_sent =3D 0;
>>>=20
>>> I agree this line is not sufficient, and it should be moved.
>>> Not every retransmission requires a re-encode. However, the
>>> patch description should explain that, and it probably needs
>>> a Fixes: tag.
>>>=20
>>> Can you now also remove the same line from xprt_request_init
>>> and xprt_init_bc_request ?
>>>=20
>>> Also, I notice that UDP does not touch rq_bytes_sent. Since
>>> RDMA also does not use rq_bytes_sent, maybe the same line
>>> can be removed from xprtrdma/transport.c and
>>> xprtrdma/backchannel.c ?
>> Sure.
>> So please note that rq_bytes_sent =3D=3D 0 no longer means "this =
request
>> needs to be retransmitted" and we no longer test for it in
>> net/sunrpc/clnt.c. We do still have a couple of tests of =
rq_bytes_sent
>> in net/sunrpc/xprt.c and net/sunrpc/xprtsock.c, but those are more
>> about checking if a transmission of that request is currently in
>> progress, in which case we don't want to queue anything in front of =
it
>> on the transmission queue, and we don't want to abort the =
transmission
>> unless we also close the socket.
>=20
> I think rq_bytes_sent is all about managing sends atomically. On =
stream
> transports (which allow buffering partial segments), it would be fatal =
to allow intermingling. On datagram transports, it's a non-issue since
> no sends are ever partial.
>=20
> IOW, couldn't rq_bytes_sent simply be a boolean?

I read somewhere recently that a boolean would take up as much space
as a u32 in rpc_rqst. Not sure it saves much.

I would be interested in removing rq_bytes_sent from generic paths,
as a minor optimization. It seems to be something that stream
transports need, but the others don't.


> Tom.
>=20
>> The intention now is that if we know the request needs retransmission
>> (due to a transport connection loss or a timeout), then we just add =
it
>> to the transmission queue.
>>>> 	p =3D rpc_encode_header(task);
>>>> 	if (p =3D=3D NULL) {
>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>> index 73547d17d3c6..9075ae150ae5 100644
>>>> --- a/net/sunrpc/xprt.c
>>>> +++ b/net/sunrpc/xprt.c
>>>> @@ -1151,6 +1151,7 @@ xprt_request_enqueue_transmit(struct rpc_task
>>>> *task)
>>>> 	struct rpc_xprt *xprt =3D req->rq_xprt;
>>>>=20
>>>> 	if (xprt_request_need_enqueue_transmit(task, req)) {
>>>> +		req->rq_bytes_sent =3D 0;
>>>> 		spin_lock(&xprt->queue_lock);
>>>> 		/*
>>>> 		 * Requests that carry congestion control credits are
>>>> added
>>>=20
>>> So I'm not convinced this covers every case. I need some
>>> time to investigate.
>> It should normally cover all cases. As I said, the only remaining =
tests
>> are in xprt.c and  xprtsock.c

--
Chuck Lever



