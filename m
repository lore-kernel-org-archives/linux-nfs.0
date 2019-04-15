Return-Path: <SRS0=/Mrm=SR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A490C10F0E
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 16:11:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1FED820818
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 16:11:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="zzCuhywF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727831AbfDOQLT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Apr 2019 12:11:19 -0400
Received: from aserp2130.oracle.com ([141.146.126.79]:37144 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727692AbfDOQLT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Apr 2019 12:11:19 -0400
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3FG8xe3058210;
        Mon, 15 Apr 2019 16:11:15 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=K3KevB1FVm8L9pYeGlmTcsWGHKP9FMy62iorm7kEoUw=;
 b=zzCuhywFzesxBuzNXjO3Uqckikfr2pm+LpyenTcJn2wx2+Ok1QMLINk5NZl3RjSawqW8
 ZkrGYdTxiRodZ/oalnR7otPJozhWXvRsz6jb3Jlwm8UGXto8JAfuTzwWegOPmmjddkFT
 EqWgzaUMMx57MNSsvj/xPvEzVu8v8Oq8mh5NuOonPOuLa9f+4cWLEWi5pMrQrRgbjqPM
 lmmAmPl3ygGlujcYK4G/E/b80JLAk8qGYwP/qSbOvE9uVtw5xo5ATbIcf/czKfEQ5YRX
 laXn1EBlwxuAxgXNyOPVzfjMIJj31VHniAWIOM/zwziYz/i2LC3+iEGoZypwj9M4RBSl vw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
        by aserp2130.oracle.com with ESMTP id 2ru59cysrw-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 15 Apr 2019 16:11:14 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
        by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3FGAvMI146356;
        Mon, 15 Apr 2019 16:11:14 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userp3030.oracle.com with ESMTP id 2ru4vsq2t9-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 15 Apr 2019 16:11:13 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3FGBCq1016778;
        Mon, 15 Apr 2019 16:11:13 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 15 Apr 2019 09:11:12 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: error=Invalid slot
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <76d240e019d0ccc35bce05c1edb1ca104d7c18bf.camel@hammerspace.com>
Date:   Mon, 15 Apr 2019 12:11:11 -0400
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <32DC3CC2-700B-4F44-849C-F229BAA2CB57@oracle.com>
References: <2996CEEE-0A1A-4C15-AA8B-A97E917D7924@oracle.com>
 <76d240e019d0ccc35bce05c1edb1ca104d7c18bf.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9228 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=905
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904150112
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9228 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=932 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904150112
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Apr 15, 2019, at 12:05 PM, Trond Myklebust =
<trondmy@hammerspace.com> wrote:
>=20
> Hi Chuck,
>=20
>=20
> On Mon, 2019-04-15 at 11:04 -0400, Chuck Lever wrote:
>> Just happened again. Any thoughts about where I should start looking?
>>=20
>> Mon Apr 15 11:01:40 EDT 2019
>> 4k100test: (g=3D0): rw=3Drandread, bs=3D(R) 4096B-4096B, (W) =
4096B-4096B,
>> (T) 4096B-4096B, ioengine=3Dlibaio, iodepth=3D1024
>> ...
>> fio-3.1
>> Starting 12 processes
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> 4k100test: Laying out IO file (1 file / 1024MiB)
>> fio: native_fallocate call failed: Operation not supported
>> fio: io_u error on file 4k100test.7.0: Invalid slot: read
>> offset=3D938229760, buflen=3D4096
>=20
> Does the following patch fix the race?
>=20
> 8<--------------------------------------
> =46rom 4c8759eafad9bb7ea2626a53296e30618aeefcc7 Mon Sep 17 00:00:00 =
2001
> From: Trond Myklebust <trond.myklebust@hammerspace.com>
> Date: Mon, 15 Apr 2019 11:54:13 -0400
> Subject: [PATCH] SUNRPC: Ignore queue transmission errors on =
successful
> transmission
>=20
> If a request transmission fails due to write space or slot =
unavailability
> errors, but the queued task then gets transmitted before it has time =
to
> process the error in call_transmit_status() or =
call_bc_transmit_status(),
> we need to suppress the transmission error code to prevent it from =
leaking
> out of the RPC layer.
>=20
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/clnt.c | 7 +++++--
> 1 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index fa900bb44cd5..369a2648dafc 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -2101,8 +2101,8 @@ call_transmit_status(struct rpc_task *task)
> 	 * test first.
> 	 */
> 	if (rpc_task_transmitted(task)) {
> -		if (task->tk_status =3D=3D 0)
> -			xprt_request_wait_receive(task);
> +		task->tk_status =3D 0;
> +		xprt_request_wait_receive(task);
> 		return;
> 	}
>=20
> @@ -2187,6 +2187,9 @@ call_bc_transmit_status(struct rpc_task *task)
> {
> 	struct rpc_rqst *req =3D task->tk_rqstp;
>=20
> +	if (rpc_task_transmitted(task))
> +		task->tk_status =3D 0;
> +
> 	dprint_status(task);
>=20
> 	switch (task->tk_status) {

I was about to try something like this.

I don't have a 100% reproducer. I will apply your patch and
wait for the problem to appear over the next few days.


--
Chuck Lever



