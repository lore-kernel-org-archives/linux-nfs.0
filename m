Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 803AFC5ACBA
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 21:31:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 41E0F20C01
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 21:31:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="SNY+64rt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41E0F20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726420AbeKUICu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 21 Nov 2018 03:02:50 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:53020 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726393AbeKUICu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Nov 2018 03:02:50 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAKLTAJq135553;
        Tue, 20 Nov 2018 21:31:36 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=6EmMZBEWhV/NRqxEeErDRDjTTNoucmuH9gKdjrURt7E=;
 b=SNY+64rtffZYVQ+3knHh0vS9SWnk8kiNkW/Yh6Q5jcdFBzUcoi0RVuW6HfRNNcRprSdS
 fzkEO3rSsn6Cb028e7RGegT9mzBiTSEZK4rM2g4FRORtGxD/iI0T0OT0XxLo6zsRiloP
 aUcXzoeAltosN3uv7BTOSakENHBahsntCFvazJzMiUZJ8GwhWb5bNZlK9yNlQQ/NH4nX
 d/w/cNZ9uQfqHWpz6HfO9QviXFv+J9snJo3SDGubxczCjC6Iman5L2ox4qBQyEb1PBOA
 yg50sBKUzimwqEH2aLG5kHKRnHGJv7LbaS/Q/hiAE+udZey0K0w5IljgGNhQy3wL5vTp bA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2130.oracle.com with ESMTP id 2ntadtxajj-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 20 Nov 2018 21:31:36 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wAKLVZ4C010129
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 20 Nov 2018 21:31:35 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wAKLVZmQ013768;
        Tue, 20 Nov 2018 21:31:35 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 20 Nov 2018 13:31:35 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <94ff7ec712e086bfdd9c217a5f97c293a07151b9.camel@gmail.com>
Date:   Tue, 20 Nov 2018 16:31:34 -0500
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <2EE2C659-4E85-4041-9006-FF3C68508847@oracle.com>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154607.10832.92558.stgit@manet.1015granger.net>
 <f1d83adeef9acf690c523df43c2f542b97a0bc33.camel@gmail.com>
 <08D50748-8C07-4EF1-B2BB-3DA30A3598BF@oracle.com>
 <94ff7ec712e086bfdd9c217a5f97c293a07151b9.camel@gmail.com>
To:     Anna Schumaker <schumaker.anna@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9083 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811200188
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 20, 2018, at 4:01 PM, Anna Schumaker <schumaker.anna@gmail.com> =
wrote:
>=20
> On Tue, 2018-11-20 at 13:07 -0500, Chuck Lever wrote:
>>> On Nov 20, 2018, at 1:02 PM, Anna Schumaker =
<schumaker.anna@gmail.com>
>>> wrote:
>>>=20
>>> Hi Chuck,
>>>=20
>>> On Mon, 2018-11-19 at 10:46 -0500, Chuck Lever wrote:
>>>> Place the associated RPC transaction's XID in the upper 32 bits of
>>>> each RDMA segment's rdma_offset field. These bits are currently
>>>> always zero.
>>>>=20
>>>> There are two reasons to do this:
>>>>=20
>>>> - The R_key only has 8 bits that are different from registration to
>>>> registration. The XID adds more uniqueness to each RDMA segment to
>>>> reduce the likelihood of a software bug on the server reading from
>>>> or writing into memory it's not supposed to.
>>>>=20
>>>> - On-the-wire RDMA Read and Write operations do not otherwise carry
>>>> any identifier that matches them up to an RPC. The XID in the
>>>> upper 32 bits will act as an eye-catcher in network captures.
>>>>=20
>>>> Suggested-by: Tom Talpey <ttalpey@microsoft.com>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> net/sunrpc/xprtrdma/frwr_ops.c  |    3 ++-
>>>> net/sunrpc/xprtrdma/rpc_rdma.c  |    6 +++---
>>>> net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
>>>> 3 files changed, 6 insertions(+), 5 deletions(-)
>>>>=20
>>>> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c
>>>> b/net/sunrpc/xprtrdma/frwr_ops.c
>>>> index 49b314d..3b260d2 100644
>>>> --- a/net/sunrpc/xprtrdma/frwr_ops.c
>>>> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
>>>> @@ -344,7 +344,7 @@
>>>> */
>>>> static struct rpcrdma_mr_seg *
>>>> frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg =
*seg,
>>>> -	    int nsegs, bool writing, struct rpcrdma_mr **out)
>>>> +	    int nsegs, bool writing, u32 xid, struct rpcrdma_mr **out)
>>>> {
>>>> 	struct rpcrdma_ia *ia =3D &r_xprt->rx_ia;
>>>> 	bool holes_ok =3D ia->ri_mrtype =3D=3D IB_MR_TYPE_SG_GAPS;
>>>> @@ -398,6 +398,7 @@
>>>> 	if (unlikely(n !=3D mr->mr_nents))
>>>> 		goto out_mapmr_err;
>>>>=20
>>>> +	ibmr->iova |=3D ((u64)cpu_to_be32(xid)) << 32;
>>>=20
>>> My mount command hangs once we make this change (I got bored and =
killed it
>>> after
>>> about 5 minutes).  This is with NFS over soft-RoCE in a kvm virtual =
machine,
>>> and
>>> I see the behavior with all NFS versions.
>>>=20
>>> I hope this helps!
>>=20
>> OK. Can you capture ftrace output to show us where the hang occurs?
>> I use this on the NFS client:
>>=20
>> # trace-cmd record -e sunrpc -e rpcrdma
>> ^C
>> # trace-cmd report | less      (or > /tmp/trace.log)
>=20
> The trace is attached!  I started the mount and walked away for a =
while.  When I
> came back, it reported "mount.nfs: Connection timed out".

The first operation is EXCHANGE_ID, and the client expects a
large Reply so it registers a Reply chunk.

       mount.nfs-1325  [001]   450.674910: xprtrdma_reply_chunk: =
task:16530@10 mr=3D0xffff93643876cb00 4380@0xffffd37d38bec100:0x00001a61 =
(last)
       mount.nfs-1325  [001]   450.674912: xprtrdma_marshal:     =
task:16530@10 xid=3D0x09c9d05d: hdr=3D48 xdr=3D232/0/0 inline/reply =
chunk
       mount.nfs-1325  [001]   450.674914: xprtrdma_post_send:   =
req=3D0xffff936438a80000, 2 SGEs, status=3D0
       mount.nfs-1325  [001]   450.674928: xprt_transmit:        =
peer=3D[192.168.100.215]:20049 xid=3D0x09c9d05d status=3D0
       mount.nfs-1325  [001]   450.674929: rpc_task_run_action:  =
task:16530@10 flags=3D5a80 state=3D0015 status=3D0 =
action=3Dcall_transmit_status
       mount.nfs-1325  [001]   450.674930: rpc_task_sleep:       =
task:16530@10 flags=3D5a80 state=3D0015 status=3D0 timeout=3D18000 =
queue=3Dxprt_pending
    kworker/1:1H-177   [001]   450.676094: xprtrdma_wc_receive:  =
cqe=3D0xffff936438d66600 0 bytes: WR_FLUSH_ERR (5/0x0)
    kworker/1:1H-177   [001]   450.676095: xprtrdma_wc_receive:  =
cqe=3D0xffff936438d66400 0 bytes: WR_FLUSH_ERR (5/0x0)

The XID is 09c9d0f3, but I don't see it in the offset, which
is ffffd37d38bec100. Are you sure the patch is applied?


> I hope this helps!
> Anna
>=20
>>=20
>> Thanks!
>>=20
>>=20
>>> Anna
>>>=20
>>>> 	key =3D (u8)(ibmr->rkey & 0x000000FF);
>>>> 	ib_update_fast_reg_key(ibmr, ++key);
>>>>=20
>>>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c
>>>> b/net/sunrpc/xprtrdma/rpc_rdma.c
>>>> index 9f53e02..89a2db2 100644
>>>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>>>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>>>> @@ -357,7 +357,7 @@ static bool rpcrdma_results_inline(struct =
rpcrdma_xprt
>>>> *r_xprt,
>>>>=20
>>>> 	do {
>>>> 		seg =3D r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
>>>> -						   false, &mr);
>>>> +						   false, rqst->rq_xid, =
&mr);
>>>> 		if (IS_ERR(seg))
>>>> 			return PTR_ERR(seg);
>>>> 		rpcrdma_mr_push(mr, &req->rl_registered);
>>>> @@ -415,7 +415,7 @@ static bool rpcrdma_results_inline(struct =
rpcrdma_xprt
>>>> *r_xprt,
>>>> 	nchunks =3D 0;
>>>> 	do {
>>>> 		seg =3D r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
>>>> -						   true, &mr);
>>>> +						   true, rqst->rq_xid, =
&mr);
>>>> 		if (IS_ERR(seg))
>>>> 			return PTR_ERR(seg);
>>>> 		rpcrdma_mr_push(mr, &req->rl_registered);
>>>> @@ -473,7 +473,7 @@ static bool rpcrdma_results_inline(struct =
rpcrdma_xprt
>>>> *r_xprt,
>>>> 	nchunks =3D 0;
>>>> 	do {
>>>> 		seg =3D r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
>>>> -						   true, &mr);
>>>> +						   true, rqst->rq_xid, =
&mr);
>>>> 		if (IS_ERR(seg))
>>>> 			return PTR_ERR(seg);
>>>> 		rpcrdma_mr_push(mr, &req->rl_registered);
>>>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h
>>>> b/net/sunrpc/xprtrdma/xprt_rdma.h
>>>> index a13ccb6..2ae1ee2 100644
>>>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>>>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>>>> @@ -472,7 +472,7 @@ struct rpcrdma_memreg_ops {
>>>> 	struct rpcrdma_mr_seg *
>>>> 			(*ro_map)(struct rpcrdma_xprt *,
>>>> 				  struct rpcrdma_mr_seg *, int, bool,
>>>> -				  struct rpcrdma_mr **);
>>>> +				  u32, struct rpcrdma_mr **);
>>>> 	int		(*ro_send)(struct rpcrdma_ia *ia,
>>>> 				   struct rpcrdma_req *req);
>>>> 	void		(*ro_reminv)(struct rpcrdma_rep *rep,
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20
> <trace.log>

--
Chuck Lever



