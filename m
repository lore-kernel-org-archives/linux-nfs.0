Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E028AC04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 19:00:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9ADEA20848
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 19:00:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Th2lK/Zm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9ADEA20848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725987AbeLCTAy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 14:00:54 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:51930 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725991AbeLCTAx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 14:00:53 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wB3IwjW5036242;
        Mon, 3 Dec 2018 19:00:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=oxJPQLTyeFMpC5sXVrIK0B9pwOVjHpnZOptxDmZpdLk=;
 b=Th2lK/Zmhw/NtwOu+DjUz6Cu2A+DWz4CiWrnG/82BttjMTTlWzhWAC0Xai/sbczhaAa7
 7U3StWjPOrj56pGXUr0vNC9OkJL9JGnm/dfLSvH5Y2mJiPu6L9RDtj+f/3zSJYrJFnml
 1IXPQ8nIi92VvMhXElfWBRWpP/nHPdVJl9he4rJVjsFpqxheo3QfWyPlh1tm3NPUwPd4
 4CCu5XUVgqK1hFCrTSZao0NQHzheQi0aqiGKxf/z9VA1iPjTFs631HlTAzqEL8U7SnZd
 YpKyDaOyoUYmj4yTwdMfTSaF0qmQAVtbWR1D6++sbUhb2YtC+Bo8xFc/oICkwbk7gSsJ Mg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2120.oracle.com with ESMTP id 2p3j8q88fx-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 03 Dec 2018 19:00:47 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wB3J0gex023530
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 3 Dec 2018 19:00:42 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wB3J0fTu025739;
        Mon, 3 Dec 2018 19:00:41 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 03 Dec 2018 11:00:41 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] SUNRPC: Fix a potential race in xprt_connect()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <3ee22a93e7ac2853605ff6833af76a59bb5516c3.camel@hammerspace.com>
Date:   Mon, 3 Dec 2018 14:00:39 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <063F310D-4ED4-4C27-B332-4D6680406597@oracle.com>
References: <20181202144223.42562-1-trond.myklebust@hammerspace.com>
 <4BAC007E-35BE-423B-BA11-5413D0EEDDBD@oracle.com>
 <fdb18aece66221c91c0f8ce4e0a7849bc60505fc.camel@hammerspace.com>
 <8D79F3BF-74BE-418A-85A8-7E8AF508B0AE@oracle.com>
 <3ee22a93e7ac2853605ff6833af76a59bb5516c3.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9096 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812030175
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 3, 2018, at 12:15 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Mon, 2018-12-03 at 10:56 -0500, Chuck Lever wrote:
>>> On Dec 2, 2018, at 12:26 PM, Trond Myklebust <trondmy@gmail.com>
>>> wrote:
>>>=20
>>> On Sun, 2018-12-02 at 12:07 -0500, Chuck Lever wrote:
>>>> Test report.
>>>>=20
>>>> I applied this on top of the three v4 patches from Friday.
>>>>=20
>>>> With TCP, I no longer see the soft IRQ warnings or bdev leaks.
>>>> However, at some point during my test (sec=3Dkrb5p,vers=3D3) the
>>>> mount stops responding and the client becomes idle. ^C leaves
>>>> the iozone processes in D state.
>>>=20
>>> Does /proc/*/stack show any tasks with any interesting stack
>>> behaviour?
>>>=20
>>>> With RDMA, I can see a few issues:
>>>> - A lot of -74 and server disconnects. I suspect this is due
>>>>  to GSS sequence window overruns
>>>> - xprt_connect puts the calling task to sleep if the credit
>>>>  limit has been reached, and that can result in a deadlock
>>>> - The reconnect logic appears to busy-wait until something
>>>>  else (eg, an RTO) forces a reconnect
>>>> - A connect or disconnect wake-up that occurs while an RPC
>>>>  reply is being handled (ie, is still on xprt->pending)
>>>>  results in that RPC being retried unnecessarily.
>>>>=20
>>>> I'm not sure how to address that last one. Sometimes RDMA has
>>>> to invalidate MRs, and that involves a wait/context swith which
>>>> opens the race window significantly.
>>>=20
>>> In principle the latter issue is supposed to be handled by the
>>> connect
>>> cookies. Are the updates perhaps being ordered incorrectly w.r.t.
>>> the
>>> xprt->pending wakeup? If so, then that could cause races.
>>>=20
>>> I'd expect the cookie would need to be updated before the call to
>>> xprt-
>>> pending both on connect and disconnect.
>>=20
>> I've found one peculiar cookie-related behavior.
>>=20
>> At some point, xprt_request_retransmit_after_disconnect() starts
>> to claim that all requests have to be retransmitted and that the
>> connection is closed. Closer inspection shows that the cookie
>> check here is failing because it seems to be testing a request
>> that hasn't been transmitted yet.
>=20
> Right, but as far as the transport layer is concerned, there should be
> no difference between 'need transmit' and 'need retransmit'. It is up
> to the higher RPC client layer to decide whether or not there is a
> policy difference in behaviour, and AFAICS rpc_task_need_encode()
> should be doing the right thing.

OK, thanks for clearing that up. A couple of observations:

- The sleep followed immediately by a wake-up tells me you don't
expect this to happen frequently. But with sec=3Dkrb5 flavors, I
do see this path taken quite a bit. Sounds like I need to figure
out why that is.

- returning EAGAIN would make a whole lot more sense in these
cases since the connection is frequently still whole.


>>>>> On Dec 2, 2018, at 9:42 AM, Trond Myklebust <trondmy@gmail.com>
>>>>> wrote:
>>>>>=20
>>>>> If an asynchronous connection attempt completes while another
>>>>> task
>>>>> is
>>>>> in xprt_connect(), then the call to rpc_sleep_on() could end up
>>>>> racing with the call to xprt_wake_pending_tasks().
>>>>> So add a second test of the connection state after we've put
>>>>> the
>>>>> task to sleep and set the XPRT_CONNECTING flag, when we know
>>>>> that
>>>>> there
>>>>> can be no asynchronous connection attempts still in progress.
>>>>>=20
>>>>> Fixes: 0b9e79431377d ("SUNRPC: Move the test for
>>>>> XPRT_CONNECTING
>>>>> into...")
>>>>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com
>>>>>>=20
>>>>> ---
>>>>> net/sunrpc/xprt.c | 11 +++++++++--
>>>>> 1 file changed, 9 insertions(+), 2 deletions(-)
>>>>>=20
>>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>>> index 122c91c28e7c..ce927002862a 100644
>>>>> --- a/net/sunrpc/xprt.c
>>>>> +++ b/net/sunrpc/xprt.c
>>>>> @@ -826,8 +826,15 @@ void xprt_connect(struct rpc_task *task)
>>>>> 			return;
>>>>> 		if (xprt_test_and_set_connecting(xprt))
>>>>> 			return;
>>>>> -		xprt->stat.connect_start =3D jiffies;
>>>>> -		xprt->ops->connect(xprt, task);
>>>>> +		/* Race breaker */
>>>>> +		if (!xprt_connected(xprt)) {
>>>>> +			xprt->stat.connect_start =3D jiffies;
>>>>> +			xprt->ops->connect(xprt, task);
>>>>> +		} else {
>>>>> +			xprt_clear_connecting(xprt);
>>>>> +			task->tk_status =3D 0;
>>>>> +			rpc_wake_up_queued_task(&xprt->pending,=20
>>>>> task);
>>>>> +		}
>>>>> 	}
>>>>> 	xprt_release_write(xprt, task);
>>>>> }
>>>>> --=20
>>>>> 2.19.2
>>>>>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

--
Chuck Lever



