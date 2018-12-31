Return-Path: <SRS0=v8AN=PI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34D33C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Dec 2018 19:09:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E09AC20B1F
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Dec 2018 19:09:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Mw1wYyhF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727392AbeLaTJP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 31 Dec 2018 14:09:15 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:34656 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727390AbeLaTJO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Dec 2018 14:09:14 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBVJ8lxS114735;
        Mon, 31 Dec 2018 19:09:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=YWz6cWA6qK+6l8jssUyuS36JLUiUAgLWe5LWIKWNKC4=;
 b=Mw1wYyhF95izf17FJuOA901JpSwWTKDsm9EyGBwMZHgvmZNExZJfDoweoyEbpczOjB1p
 BBgu//k+SqZiQ5NCtH4UAAnMeP6FEsBeX/94GZr7inCAyt1kCyaqwcNp3N3CwOULG94j
 TvsUQ6giXJpkhykld4OhEE3c3rMwYAGGr0uJ6qsnv1YkT2W8q654hfABIXPbGAQMjZf0
 FCkgV4RDTjC1MLiWQHD7LDggrEwPG0dWpxJBmfQ7FHVtDhXG4kX009eN5K+MW6jOHdf8
 EWuyiPJsd9gND8/zdJ16Ot4S2r9P1XSO+9a8iEtZbVh6To8yNWi2lUnWVVl4YY8ofovJ rA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2130.oracle.com with ESMTP id 2pnxedwr16-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 31 Dec 2018 19:09:11 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBVJ9A1e031857
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 31 Dec 2018 19:09:11 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBVJ9AX4017566;
        Mon, 31 Dec 2018 19:09:10 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 31 Dec 2018 11:09:09 -0800
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <44f05a726ddc1c53ea505e033aad7aa8f4a5f204.camel@hammerspace.com>
Date:   Mon, 31 Dec 2018 14:09:08 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <FEAFD5B3-7E93-4545-A364-DE453852B76C@oracle.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@! hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <4D3465FB-041C-4BB1-AB75-03511FA5AAF1@oracle.com>
 <BC34B04D-4AD5-46FB-8DC6-310BF3FBEBD3@hammerspace.com>
 <4FB643C8-4790-42B9-AF38-622E10F6A1B2@oracle.com>
 <4e46f31cc59315533e477cb667f903731598f7f1.camel@hammerspace.com>
 <3BD5C006-55D6-4D1B-9F3D-48FA65CDE09D@oracle.com>
 <44f05a726ddc1c53ea505e033aad7aa8f4a5f204.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9123 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=963
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812310167
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 31, 2018, at 1:59 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Mon, 2018-12-31 at 13:44 -0500, Chuck Lever wrote:
>>> On Dec 31, 2018, at 1:09 PM, Trond Myklebust <
>>> trondmy@hammerspace.com> wrote:
>>>=20
>>> On Thu, 2018-12-27 at 17:34 -0500, Chuck Lever wrote:
>>>>> On Dec 27, 2018, at 5:14 PM, Trond Myklebust <
>>>>> trondmy@hammerspace.com> wrote:
>>>>>=20
>>>>>=20
>>>>>=20
>>>>>> On Dec 27, 2018, at 20:21, Chuck Lever <
>>>>>> chuck.lever@oracle.com>
>>>>>> wrote:
>>>>>>=20
>>>>>> Hi Trond-
>>>>>>=20
>>>>>> I've chased down a couple of remaining regressions with the
>>>>>> v4.20
>>>>>> NFS client,
>>>>>> and they seem to be rooted in this commit.
>>>>>>=20
>>>>>> When using sec=3Dkrb5, krb5i, or krb5p I found that multi-
>>>>>> threaded
>>>>>> workloads
>>>>>> trigger a lot of server-side disconnects. This is with TCP
>>>>>> and
>>>>>> RDMA transports.
>>>>>> An instrumented server shows that the client is under-running=20
>>>>>> the
>>>>>> GSS sequence
>>>>>> number window. I monitored the order in which GSS sequence
>>>>>> numbers appear on
>>>>>> the wire, and after this commit, the sequence numbers are
>>>>>> wildly
>>>>>> misordered.
>>>>>> If I revert the hunk in xprt_request_enqueue_transmit, the
>>>>>> problem goes away.
>>>>>>=20
>>>>>> I also found that reverting that hunk results in a 3-4%
>>>>>> improvement in fio
>>>>>> IOPS rates, as well as improvement in average and maximum
>>>>>> latency
>>>>>> as reported
>>>>>> by fio.
>>>>>>=20
>>>>>=20
>>>>> Hmm=E2=80=A6 Provided the sequence numbers still lie within the =
window,
>>>>> then why would the order matter?
>>>>=20
>>>> The misordering is so bad that one request is delayed long enough
>>>> to
>>>> fall outside the window. The new =E2=80=9Cneed re-encode=E2=80=9D =
logic does not
>>>> trigger.
>>>>=20
>>>=20
>>> That's weird. I can't see anything wrong with need re-encode at
>>> this
>>> point.
>>=20
>> I don't think there is anything wrong with it, it looks like it's
>> not called in this case.
>=20
> So you are saying that the call to rpcauth_xmit_need_reencode() is
> triggering the EBADMSG, but that this fails to cause a re-encode of =
the
> message?

No, I think what's going on is that the need_reencode happens when the
RPC is enqueued, and is successful.

But xprt_request_enqueue_transmit places the RPC somewhere in the middle
of xmit_queue. xmit_queue is long enough that more than 128 requests are
before the enqueued request.


>>> Do the window sizes agree on the client and the server?
>>=20
>> Yes, both are 128. I also tried with 64 on the client side and 128
>> on the server side. That reduces the frequency of disconnects, but
>> does not eliminate them.
>>=20
>> I'm not clear what problem the logic in xprt_request_enqueue_transmit
>> is trying to address. It seems to me that the initial, simple
>> implementation of this function is entirely adequate..?
>=20
> I agree that the fair queueing code could result in a reordering that
> could screw up the RPCSEC_GSS sequencing. However, we do expect the
> need reencode stuff to catch that.

--
Chuck Lever



