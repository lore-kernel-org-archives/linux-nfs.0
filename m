Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CB0AC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 15:39:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 609AA20880
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 15:39:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="N74YQEC9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725929AbfBTPjh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 10:39:37 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:44768 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725822AbfBTPjh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2019 10:39:37 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1KFdILr036067;
        Wed, 20 Feb 2019 15:39:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=3SPm3YM/DsAubC531ZWs/Xo/18nTSuMHOZjNdWAdg+I=;
 b=N74YQEC9ghiv1vRR9lMbvojhr8BnZRf0Y3bemayyYGadh/5wxlGnfgxeOjfj/NotUXnk
 0qG/8ggN6G5o8y6nKdcE1Va/YIB6dBQlDmy1hejclSUdaHZAKnuXA93gR8MLaqzACetc
 +vYI/odcL7/5DhQleqSBofVfW34fok3qKnyDePqbtH8psh7ZZVIPSgb3h1pvroiIES9G
 sQe7j7GS24eDfJOdIE3sHdMm3KkfaYWDFTj3G7kHT/ELNZ0uJ0oRZ5zhufWvBrRwT6nL
 2e9E3ryRwrJV3nMruYRIMAKx3Zu5lu9/aCVC8oEKAyywwCrIhnU0qpZ9OR3P3N3PCBZM Ag== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2qp9xu2bvy-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 20 Feb 2019 15:39:24 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1KFdI8j029209
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 20 Feb 2019 15:39:18 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1KFdIjD032211;
        Wed, 20 Feb 2019 15:39:18 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 20 Feb 2019 07:39:18 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <2ab06cbdc19d7a642e04f1e66abbeaa507b034bc.camel@hammerspace.com>
Date:   Wed, 20 Feb 2019 10:39:16 -0500
Cc:     "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        "bcodding@redhat.com" <bcodding@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <1FA7F8B3-872E-4AF6-8125-2664443E59D1@oracle.com>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
 <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
 <ufak1isms71.fsf@epithumia.math.uh.edu>
 <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
 <FC712F54-5A7A-436D-B076-936B29C013F4@redhat.com>
 <87imxwab12.fsf@hippogriff.math.uh.edu>
 <662CE7B3-235E-4E2D-9C8C-0F6233F3085F@redhat.com>
 <87d0o3aadg.fsf@hippogriff.math.uh.edu>
 <B730E8AE-AFA3-4CE7-9103-FCCC35C37EDD@redhat.com>
 <ufa4l943i6v.fsf@epithumia.math.uh.edu>
 <e8887651e91b1d0110cab2330a03e3e3ccef742b.camel@hammerspace.com>
 <ufapnrmbhyf.fsf@epithumia.math.uh.edu>
 <2ab06cbdc19d7a642e04f1e66abbeaa507b034bc.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9173 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902200112
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 20, 2019, at 10:37 AM, Trond Myklebust =
<trondmy@hammerspace.com> wrote:
>=20
> On Wed, 2019-02-20 at 09:25 -0600, Jason L Tibbitts III wrote:
>> Sadly, after a bit more testing I find that 4.20.10 with that patch
>> applied still exhibits the problem.  Just found a machine where NFS
>> hung
>> up just six minutes after the user logged in.  As always: nothing is
>> logged to the client or the server.  I turned on the tracing as
>> requested previously and see what I think it just the same sequence
>> as
>> before.  Please let me know if there is any other information I can
>> provide.  Right now I'm going to build 4.20.10 with my previously
>> posted
>> revert patch applied and roll that out to the same 50 hosts and see
>> how
>> it fares.
>>=20
>> - J<
>>=20
>>    kworker/u8:0-12608 [001] .... 47884.661073: rpc_request: task:
>> 20469@1 nfsv4 SEQUENCE (async)
>>    kworker/u8:0-12608 [001] .... 47884.661073: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D0005 status=3D0 action=3Dcall_reserve=

>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661074: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D0005 status=3D0 =
action=3Dcall_reserveresult
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661074: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D0005 status=3D0 action=3Dcall_refresh=

>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661075: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D0005 status=3D0 =
action=3Dcall_refreshresult
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661076: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D0005 status=3D0 =
action=3Dcall_allocate
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661076: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D0005 status=3D0 action=3Dcall_encode
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661091: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D001d status=3D0 action=3Dcall_bind =
[sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661091: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D001d status=3D0 action=3Dcall_connect=

>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661092: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D001d status=3D0 =
action=3Dcall_transmit
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661106: xprt_transmit:
>> peer=3D[172.21.86.74]:2049 xid=3D0x0d7ca068 status=3D0
>>    kworker/u8:0-12608 [001] .... 47884.661107: rpc_task_run_action:
>> task:20469@1 flags=3D5a81 state=3D0015 status=3D0
>> action=3Dcall_transmit_status [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661107: rpc_task_sleep: task:
>> 20469@1 flags=3D5a81 state=3D0015 status=3D0 timeout=3D60000
>> queue=3Dxprt_pending
>>    kworker/u9:0-12884 [002] .... 47884.661371: xprt_lookup_rqst:
>> peer=3D[172.21.86.74]:2049 xid=3D0x0d7ca068 status=3D0
>>    kworker/u9:0-12884 [002] .... 47884.661372: xprt_complete_rqst:
>> peer=3D[172.21.86.74]:2049 xid=3D0x0d7ca068 status=3D112
>>    kworker/u9:0-12884 [002] .... 47884.661373: rpc_task_wakeup:
>> task:20469@1 flags=3D5a81 state=3D0006 status=3D0 timeout=3D60000
>> queue=3Dxprt_pending
>>    kworker/u9:0-12884 [002] .... 47884.661375:
>> xs_stream_read_request: peer=3D[172.21.86.74]:2049 xid=3D0x0d7ca068
>> copied=3D112 reclen=3D112 offset=3D112
>>    kworker/u9:0-12884 [002] .... 47884.661376: xs_stream_read_data:
>> peer=3D[172.21.86.74]:2049 err=3D-11 total=3D116
>>    kworker/u8:0-12608 [001] .... 47884.661388: rpc_task_run_action:
>> task:20469@1 flags=3D5a81 state=3D0005 status=3D0 action=3Dxprt_timer
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661389: rpc_task_run_action:
>> task:20469@1 flags=3D5a81 state=3D0005 status=3D0 action=3Dcall_status
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661389: rpc_task_run_action:
>> task:20469@1 flags=3D5a81 state=3D0005 status=3D0 action=3Dcall_decode
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661408: rpc_task_run_action:
>> task:20469@1 flags=3D5a81 state=3D0005 status=3D-10063 =
action=3Drpc_exit_task
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661409: nfs4_sequence_done:
>> error=3D-10063 (SEQ_MISORDERED) session=3D0x4480e725 slot_nr=3D0 =
seq_nr=3D1
>> highest_slotid=3D0 target_highest_slotid=3D0 status_flags=3D0 ()
>>    kworker/u8:0-12608 [001] .... 47884.661410: rpc_stats_latency:
>> task:20469@1 xid=3D0x0d7ca068 nfsv4 SEQUENCE backlog=3D21 rtt=3D278
>> execute=3D339
>>    kworker/u8:0-12608 [001] .... 47884.661412: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D0005 status=3D0 =
action=3Drpc_prepare_task
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661413: nfs4_setup_sequence:
>> session=3D0x4480e725 slot_nr=3D0 seq_nr=3D1 highest_used_slotid=3D0
>>    kworker/u8:0-12608 [001] .... 47884.661413: rpc_task_run_action:
>> task:20469@1 flags=3D5281 state=3D0005 status=3D0 action=3Dcall_start
>> [sunrpc]
>>    kworker/u8:0-12608 [001] .... 47884.661414: rpc_request: task:
>> 20469@1 nfsv4 SEQUENCE (async)
>=20
> This is not an RPC layer issue. It is a SEQ_MISORDERED error on slot =
0.
> If the client can't recover then that will hang your NFSv4.1 session
> against that server.
>=20
> Are you sure this isn't what was happening previously?

This is exactly what was happening earlier. See my e-mail to the list
on Feb 8.


--
Chuck Lever



