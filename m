Return-Path: <SRS0=5e7g=PK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15724C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 18:51:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DFA81218D3
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 18:51:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ObnBpzFV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728414AbfABSvN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 13:51:13 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:40272 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725993AbfABSvL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2019 13:51:11 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x02IiB7g011783;
        Wed, 2 Jan 2019 18:51:07 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=W2xuuSzYTCCgijcXT0vth/ST4ItKLuZN65LPw+xzxgE=;
 b=ObnBpzFVbbJa5Wj7MzjHZWJ/BN26d1j4pIteCPtoTvzXvSTdNTvmpcTOJ99FXdIKQg+J
 FByxkGW0hdpYdO9EbJEyYZVEh4yDGqM8bRxvZ/spBDRH4ejMTMyN6R3fX5Ico60ITaPB
 bi+AxgpTsV3wWAOPAxDdgJFs6tGBpXmLmyPqX/C3JJCKObmAvREsXaG9PoZI+8n1NzsE
 2cyMJFAhZDCx5bAPgoETDsGI99loQCsyM8CafWZOFgzcZhLHzamuwlXGzls9lWBX+C0p
 ZOfU7cGe9LaZkbqvrwBnropdBpb4XcSKZThUi5sEwHrhqTaE1SFw9hs5Oh4FUwI/LXAi Ag== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2130.oracle.com with ESMTP id 2pp0btuja7-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 02 Jan 2019 18:51:07 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x02Ip6CA009079
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 2 Jan 2019 18:51:06 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x02Ip6YI023989;
        Wed, 2 Jan 2019 18:51:06 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 02 Jan 2019 10:51:06 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1fa9f43b6cc2ba5d4ebd24955bf76454bfab0c18.camel@hammerspace.com>
Date:   Wed, 2 Jan 2019 13:51:05 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <5160E7EB-556C-4099-B564-8EFF7D7D9113@oracle.com>
References: <c4bd04d525a1355e3dfff054985d697f0f391816.camel@hammerspace.com>
 <07dcc1731996d6e59d882c5e4e7e7765d013c337.camel@hammerspace.com>
 <E9A190A9-4A55-4D02-9259-2F26BC41F16C@oracle.com>
 <1fa9f43b6cc2ba5d4ebd24955bf76454bfab0c18.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9124 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901020166
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 2, 2019, at 1:45 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Wed, 2019-01-02 at 13:17 -0500, Chuck Lever wrote:
>>> On Dec 31, 2018, at 2:21 PM, Trond Myklebust <
>>> trondmy@hammerspace.com> wrote:
>>>=20
>>> On Mon, 2018-12-31 at 19:18 +0000, Trond Myklebust wrote:
>>>> On Mon, 2018-12-31 at 14:09 -0500, Chuck Lever wrote:
>>>>>> On Dec 31, 2018, at 1:59 PM, Trond Myklebust <
>>>>>> trondmy@hammerspace.com> wrote:
>>>>>>=20
>>>>>>=20
>>>> The test for rpcauth_xmit_need_reencode() happens when we call
>>>> xprt_request_transmit() to actually put the RPC call on the wire.
>>>> The
>>>> enqueue order should not be able to defeat that test.
>>>>=20
>>>> Hmm... Is it perhaps the test for req->rq_bytes_sent that is
>>>> failing
>>>> because this is a retransmission after a disconnect/reconnect
>>>> that
>>>> didn't trigger a re-encode?
>>>=20
>>> Actually, it might be worth a try to move the test for
>>> rpcauth_xmit_need_reencode() outside the enclosing test for req-
>>>> rq_bytes_sent as that is just a minor optimisation.
>>=20
>> Perhaps that's the case for TCP, but RPCs sent via xprtrdma never set
>> req->rq_bytes_sent to a non-zero value. The body of the "if"
>> statement
>> is always executed for those RPCs.
>>=20
>=20
> Then the question is what is defeating the call to
> rpcauth_xmit_need_reencode() in xprt_request_transmit() and causing it
> not to trigger in the misordered cases?

Here's a sample RPC/RDMA case.

My instrumented server reports this:

Jan  2 13:29:00 klimt kernel: gss_check_seq_num: dropped: seq_num=3D141220=
 sd->sd_max=3D141360


ftrace log on the client shows this:

  kworker/u28:12-2191  [004]   194.048534: rpcgss_need_reencode: =
task:1761@5 xid=3D0x88f4f47c rq_seqno=3D141220 seq_xmit=3D141336 =
reencode unneeded
  kworker/u28:12-2191  [004]   194.048534: xprt_transmit:        =
task:1761@5 xid=3D0x88f4f47c seqno=3D141220 status=3D-57
  kworker/u28:12-2191  [004]   194.048534: rpc_task_run_action:  =
task:1779@5 flags=3DASYNC runstate=3DRUNNING|ACTIVE|NEED_XMIT|NEED_RECV =
status=3D-57 action=3Dcall_transmit_status
  kworker/u28:12-2191  [004]   194.048535: rpc_task_run_action:  =
task:1779@5 flags=3DASYNC runstate=3DRUNNING|ACTIVE|NEED_XMIT|NEED_RECV =
status=3D0 action=3Dcall_transmit
  kworker/u28:12-2191  [004]   194.048535: rpc_task_sleep:       =
task:1779@5 flags=3DASYNC runstate=3DRUNNING|ACTIVE|NEED_XMIT|NEED_RECV =
status=3D-11 timeout=3D0 queue=3Dxprt_sending


  kworker/u28:12-2191  [004]   194.048552: rpcgss_need_reencode: =
task:1761@5 xid=3D0x88f4f47c rq_seqno=3D141220 seq_xmit=3D141336 =
reencode unneeded
  kworker/u28:12-2191  [004]   194.048557: xprt_transmit:        =
task:1761@5 xid=3D0x88f4f47c seqno=3D141220 status=3D0


  kworker/u28:12-2191  [004]   194.048559: rpcgss_need_reencode: =
task:1902@5 xid=3D0x14f5f47c rq_seqno=3D141360 seq_xmit=3D141336 =
reencode unneeded
  kworker/u28:12-2191  [004]   194.048563: xprt_transmit:        =
task:1902@5 xid=3D0x14f5f47c seqno=3D141360 status=3D0


Note that first need_reencode: the sequence numbers show that the xmit
queue has been significantly re-ordered. The request being transmitted =
is
already very close to the lower end of the GSS sequence number window.

The server then re-ordereds these two slightly because the first one had
some Read chunks that need to be pulled over, the second was pure inline
and therefore could be processed immediately. That is enough to force =
the
first one outside the GSS sequence number window.

I haven't looked closely at the pathology of the TCP case.


--
Chuck Lever



