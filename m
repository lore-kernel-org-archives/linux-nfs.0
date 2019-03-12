Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85AEFC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 14:33:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4CCBB2147C
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 14:33:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="4Z8FiN5o"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726284AbfCLOd0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 10:33:26 -0400
Received: from userp2120.oracle.com ([156.151.31.85]:33090 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726255AbfCLOd0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Mar 2019 10:33:26 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2CEONJw154441;
        Tue, 12 Mar 2019 14:33:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=FVQlmtWykCM7daVqdAEKHAbgm4mJ1g3DZ90dsX4iKsw=;
 b=4Z8FiN5om+9RqHiertNqGmtqnAipPqWMtHjcvnUxi6JQ8aaH8JizS9r3n8xymYjaW+Af
 1xFUhUXLBOifFNy6W896sovn0c5urKBsAafcL2Ec+fwRntDqFTD+36wUfZrI4+AY7Vv/
 O5PfQ0WIu2H6ve0pm82Z7YpWsJlb4wNNjNttzBw7H1++F1zDvSX7LZa4qL+RR1IQ0Wf/
 HJLk1Lni2vgv0PAyTN3n4f68pILbRMQGrQ5YPYy8dyUwaLJAT8x4SvJYWOsCcD/B1ZXC
 3QzdiGU64Lwggxaq0sRujFiKMIwk35cdioC/kBgXkKbsjGv9GXrToZJuaiZxrHp54WRu rw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2r464rcya5-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 12 Mar 2019 14:33:16 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2CEXFsb011932
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 12 Mar 2019 14:33:16 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2CEXFgC015804;
        Tue, 12 Mar 2019 14:33:15 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 12 Mar 2019 14:33:15 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: oops on a sunrpc tracepoint
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyFt0j9g4iTzoT-HqzKLDvMqq+x1=PxWPBHzAd3seyaqcQ@mail.gmail.com>
Date:   Tue, 12 Mar 2019 10:33:14 -0400
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <69C7D007-BA4A-4711-8024-57B26F5BAE5E@oracle.com>
References: <CAN-5tyFt0j9g4iTzoT-HqzKLDvMqq+x1=PxWPBHzAd3seyaqcQ@mail.gmail.com>
To:     Olga Kornievskaia <aglo@umich.edu>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9192 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=886 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903120102
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Mar 12, 2019, at 10:29 AM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>=20
> Hi Chuck,
>=20
> Is this a known issue?

Nope.


> [ 5087.845704] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000004
> [ 5087.848463] #PF error: [normal kernel read fault]
> [ 5087.849852] PGD 0 P4D 0
> [ 5087.850618] Oops: 0000 [#1] SMP PTI
> [ 5087.851577] CPU: 0 PID: 5964 Comm: NFSv4 callback Not tainted =
5.0.0-rc7+ #1
> [ 5087.853388] Hardware name: VMware, Inc. VMware Virtual
> Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> [ 5087.860280] RIP: 0010:trace_event_raw_event_xprt_enq_xmit+0x6f/0xf0 =
[sunrpc]
> [ 5087.862149] Code: 00 00 00 48 89 ee 48 89 e7 e8 7d 69 65 ef 48 85
> c0 74 4a 41 0f b7 94 24 e0 00 00 00 48 89 e7 89 50 08 49 8b 94 24 a8
> 00 00 00 <8b> 52 04 89 50 0c 49 8b 94 24 c0 00 00 00 8b 92 a8 00 00 00
> 0f ca
> [ 5087.866380] RSP: 0018:ffffc03c43297cf8 EFLAGS: 00010286
> [ 5087.867797] RAX: ffff9ef936d134a0 RBX: 0000000000000003 RCX: =
0000000000000000
> [ 5087.869456] RDX: 0000000000000000 RSI: 0000000000000000 RDI: =
ffffc03c43297cf8
> [ 5087.871092] RBP: ffff9ef92f5b28f0 R08: 0000000000000246 R09: =
0000000000000000
> [ 5087.872767] R10: fffff11380b706c0 R11: 0000000000000000 R12: =
ffff9ef9338bda00
> [ 5087.874659] R13: 0000000000000004 R14: ffff9ef932e813f0 R15: =
ffff9ef932e81000
> [ 5087.876538] FS:  0000000000000000(0000) GS:ffff9ef93bc00000(0000)
> knlGS:0000000000000000
> [ 5087.879404] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 5087.881202] CR2: 0000000000000004 CR3: 000000000f0f2002 CR4: =
00000000001606f0
> [ 5087.883331] Call Trace:
> [ 5087.885770]  xprt_request_enqueue_transmit+0x2b6/0x4a0 [sunrpc]
> [ 5087.887341]  ? rpc_task_need_encode+0x40/0x40 [sunrpc]
> [ 5087.888710]  call_bc_transmit+0xd5/0x170 [sunrpc]
> [ 5087.889880]  __rpc_execute+0x7e/0x3f0 [sunrpc]
> [ 5087.891022]  rpc_run_bc_task+0x78/0xd0 [sunrpc]
> [ 5087.892097]  bc_svc_process+0x281/0x340 [sunrpc]
> [ 5087.895456]  nfs41_callback_svc+0x130/0x1c0 [nfsv4]
> [ 5087.897018]  ? remove_wait_queue+0x60/0x60
> [ 5087.898038]  kthread+0xf5/0x130
> [ 5087.899531]  ? nfs_callback_authenticate+0x50/0x50 [nfsv4]
> [ 5087.900912]  ? kthread_bind+0x10/0x10
> [ 5087.902438]  ret_from_fork+0x1f/0x30

--
Chuck Lever



