Return-Path: <SRS0=5e7g=PK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22F7CC43387
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 18:18:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E368C218DE
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 18:18:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Rmd+N153"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726609AbfABSSO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 13:18:14 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:38352 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727196AbfABSSN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2019 13:18:13 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x02I4BgW177668;
        Wed, 2 Jan 2019 18:18:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=oMysqpLdCNDo5W7BO9XqsjH7aHfGk34EwOcOko3fUjk=;
 b=Rmd+N153v8vw8zDdgSN2lSCzfxyhY0OsRRpvMd6OGO8JPU3rs/R7+p3a0HK68LAy0WSb
 huUGu2Nw0NIh0tL9yrJL9OZhhzsBc16Uah59YEDG6ahXBxruOSC31OAM9PBAWC8/tifl
 mzv7qDs3lPw2GVr92emu9wAepK0svrLcdUUWXtpTXq0A4kf1fHqp3KoLfRVCP0Cp/w+N
 89I2SmVyXuBJKITjXDVHRTOJ7Btbi19VTrBLV/eTzHc3AbHcpWfGNAolh3P88Nm3dQ0/
 CvO/x2W2n00l8tuGE+zoueGxyMgX5Bggp6Vzh+YSaan1+eo0f0uOO2AWrroBXn62a3c3 2A== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2130.oracle.com with ESMTP id 2pp0btudtx-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 02 Jan 2019 18:18:10 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x02II9E8014756
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 2 Jan 2019 18:18:09 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x02II5rv009229;
        Wed, 2 Jan 2019 18:18:08 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 02 Jan 2019 10:18:05 -0800
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <07dcc1731996d6e59d882c5e4e7e7765d013c337.camel@hammerspace.com>
Date:   Wed, 2 Jan 2019 13:17:59 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <E9A190A9-4A55-4D02-9259-2F26BC41F16C@oracle.com>
References: <c4bd04d525a1355e3dfff054985d697f0f391816.camel@hammerspace.com>
 <07dcc1731996d6e59d882c5e4e7e7765d013c337.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9124 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=800
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901020162
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 31, 2018, at 2:21 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Mon, 2018-12-31 at 19:18 +0000, Trond Myklebust wrote:
>> On Mon, 2018-12-31 at 14:09 -0500, Chuck Lever wrote:
>>>> On Dec 31, 2018, at 1:59 PM, Trond Myklebust <
>>>> trondmy@hammerspace.com> wrote:
>>>>=20
>>>> On Mon, 2018-12-31 at 13:44 -0500, Chuck Lever wrote:
>>>>>> On Dec 31, 2018, at 1:09 PM, Trond Myklebust <
>>>>>> trondmy@hammerspace.com> wrote:
>>>>>>=20
>>>>>> On Thu, 2018-12-27 at 17:34 -0500, Chuck Lever wrote:
>>>>>>>> On Dec 27, 2018, at 5:14 PM, Trond Myklebust <
>>>>>>>> trondmy@hammerspace.com> wrote:
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>> On Dec 27, 2018, at 20:21, Chuck Lever <
>>>>>>>>> chuck.lever@oracle.com>
>>>>>>>>> wrote:
>>>>>>>>>=20
>>>>>>>>> Hi Trond-
>>>>>>>>>=20
>>>>>>>>> I've chased down a couple of remaining regressions with
>>>>>>>>> the
>>>>>>>>> v4.20
>>>>>>>>> NFS client,
>>>>>>>>> and they seem to be rooted in this commit.
>>>>>>>>>=20
>>>>>>>>> When using sec=3Dkrb5, krb5i, or krb5p I found that
>>>>>>>>> multi-
>>>>>>>>> threaded
>>>>>>>>> workloads
>>>>>>>>> trigger a lot of server-side disconnects. This is with
>>>>>>>>> TCP
>>>>>>>>> and
>>>>>>>>> RDMA transports.
>>>>>>>>> An instrumented server shows that the client is under-
>>>>>>>>> running=20
>>>>>>>>> the
>>>>>>>>> GSS sequence
>>>>>>>>> number window. I monitored the order in which GSS
>>>>>>>>> sequence
>>>>>>>>> numbers appear on
>>>>>>>>> the wire, and after this commit, the sequence numbers
>>>>>>>>> are
>>>>>>>>> wildly
>>>>>>>>> misordered.
>>>>>>>>> If I revert the hunk in xprt_request_enqueue_transmit,
>>>>>>>>> the
>>>>>>>>> problem goes away.
>>>>>>>>>=20
>>>>>>>>> I also found that reverting that hunk results in a 3-4%
>>>>>>>>> improvement in fio
>>>>>>>>> IOPS rates, as well as improvement in average and
>>>>>>>>> maximum
>>>>>>>>> latency
>>>>>>>>> as reported
>>>>>>>>> by fio.
>>>>>>>>>=20
>>>>>>>>=20
>>>>>>>> Hmm=E2=80=A6 Provided the sequence numbers still lie within the
>>>>>>>> window,
>>>>>>>> then why would the order matter?
>>>>>>>=20
>>>>>>> The misordering is so bad that one request is delayed long
>>>>>>> enough
>>>>>>> to
>>>>>>> fall outside the window. The new =E2=80=9Cneed re-encode=E2=80=9D =
logic
>>>>>>> does
>>>>>>> not
>>>>>>> trigger.
>>>>>>>=20
>>>>>>=20
>>>>>> That's weird. I can't see anything wrong with need re-encode
>>>>>> at
>>>>>> this
>>>>>> point.
>>>>>=20
>>>>> I don't think there is anything wrong with it, it looks like
>>>>> it's
>>>>> not called in this case.
>>>>=20
>>>> So you are saying that the call to rpcauth_xmit_need_reencode()
>>>> is
>>>> triggering the EBADMSG, but that this fails to cause a re-encode
>>>> of
>>>> the
>>>> message?
>>>=20
>>> No, I think what's going on is that the need_reencode happens when
>>> the
>>> RPC is enqueued, and is successful.
>>>=20
>>> But xprt_request_enqueue_transmit places the RPC somewhere in the
>>> middle
>>> of xmit_queue. xmit_queue is long enough that more than 128
>>> requests
>>> are
>>> before the enqueued request.
>>=20
>> The test for rpcauth_xmit_need_reencode() happens when we call
>> xprt_request_transmit() to actually put the RPC call on the wire. The
>> enqueue order should not be able to defeat that test.
>>=20
>> Hmm... Is it perhaps the test for req->rq_bytes_sent that is failing
>> because this is a retransmission after a disconnect/reconnect that
>> didn't trigger a re-encode?
>=20
> Actually, it might be worth a try to move the test for
> rpcauth_xmit_need_reencode() outside the enclosing test for req-
>> rq_bytes_sent as that is just a minor optimisation.

Perhaps that's the case for TCP, but RPCs sent via xprtrdma never set
req->rq_bytes_sent to a non-zero value. The body of the "if" statement
is always executed for those RPCs.


--
Chuck Lever



