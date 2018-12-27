Return-Path: <SRS0=fblw=PE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C107C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Dec 2018 19:22:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 081C7208E4
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Dec 2018 19:22:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="bjq3aDIM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728781AbeL0TWD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 27 Dec 2018 14:22:03 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:51384 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726466AbeL0TWD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Dec 2018 14:22:03 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBRJJ20P113944;
        Thu, 27 Dec 2018 19:22:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=WBms+Hq/nawccrMGuELCcb5GcyN6QO0h1YSDoqTEWKg=;
 b=bjq3aDIMYJI6zPRJVI8M6HW+THoERI+7BBXTp5VOOuFUOC+uhYb2xmt16oBvzqcke+aa
 vfkcWizXT338lQqxXza0tmY/Ndm4uWCtBQkYMfvlHXQMp3oSwCMNZkqFXPlYLCfGro7U
 /F2kX028FTDzbBqpZIKfBltsljpRC4h1UiQYuO8tf04r4cg0aC7vNzqIYatGF1bH78Qn
 c/zg7k3RItDDjnZY0YJxglKNaxGQFsegbTnjabBcHQp5cZlGXHw/bGLGiDoUM9Wb98vu
 XeFQcxpIjdrBHS+4za6wePWonglmvYLKT+isClrj6BckTFYkXujAvAOkrF0RmwJ6Sl64 9A== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2phdwqxbag-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 27 Dec 2018 19:22:00 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBRJLxak002034
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 27 Dec 2018 19:22:00 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBRJLxE6028718;
        Thu, 27 Dec 2018 19:21:59 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 27 Dec 2018 11:21:59 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180917130335.112832-27-trond.myklebust@hammerspace.com>
Date:   Thu, 27 Dec 2018 14:21:58 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <4D3465FB-041C-4BB1-AB75-03511FA5AAF1@oracle.com>
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
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
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
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9119 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=747
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812270170
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Sep 17, 2018, at 9:03 AM, Trond Myklebust <trondmy@gmail.com> =
wrote:
>=20
> One of the intentions with the priority queues was to ensure that no
> single process can hog the transport. The field task->tk_owner =
therefore
> identifies the RPC call's origin, and is intended to allow the RPC =
layer
> to organise queues for fairness.
> This commit therefore modifies the transmit queue to group requests
> by task->tk_owner, and ensures that we round robin among those groups.
>=20
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> include/linux/sunrpc/xprt.h |  1 +
> net/sunrpc/xprt.c           | 27 ++++++++++++++++++++++++---
> 2 files changed, 25 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 8c2bb078f00c..e377620b9744 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -89,6 +89,7 @@ struct rpc_rqst {
> 	};
>=20
> 	struct list_head	rq_xmit;	/* Send queue */
> +	struct list_head	rq_xmit2;	/* Send queue */
>=20
> 	void			*rq_buffer;	/* Call XDR encode =
buffer */
> 	size_t			rq_callsize;
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 35f5df367591..3e68f35f71f6 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1052,12 +1052,21 @@ xprt_request_need_enqueue_transmit(struct =
rpc_task *task, struct rpc_rqst *req)
> void
> xprt_request_enqueue_transmit(struct rpc_task *task)
> {
> -	struct rpc_rqst *req =3D task->tk_rqstp;
> +	struct rpc_rqst *pos, *req =3D task->tk_rqstp;
> 	struct rpc_xprt *xprt =3D req->rq_xprt;
>=20
> 	if (xprt_request_need_enqueue_transmit(task, req)) {
> 		spin_lock(&xprt->queue_lock);
> +		list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
> +			if (pos->rq_task->tk_owner !=3D task->tk_owner)
> +				continue;
> +			list_add_tail(&req->rq_xmit2, &pos->rq_xmit2);
> +			INIT_LIST_HEAD(&req->rq_xmit);
> +			goto out;
> +		}
> 		list_add_tail(&req->rq_xmit, &xprt->xmit_queue);
> +		INIT_LIST_HEAD(&req->rq_xmit2);
> +out:
> 		set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
> 		spin_unlock(&xprt->queue_lock);
> 	}
> @@ -1073,8 +1082,20 @@ xprt_request_enqueue_transmit(struct rpc_task =
*task)
> static void
> xprt_request_dequeue_transmit_locked(struct rpc_task *task)
> {
> -	if (test_and_clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
> -		list_del(&task->tk_rqstp->rq_xmit);
> +	struct rpc_rqst *req =3D task->tk_rqstp;
> +
> +	if (!test_and_clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
> +		return;
> +	if (!list_empty(&req->rq_xmit)) {
> +		list_del(&req->rq_xmit);
> +		if (!list_empty(&req->rq_xmit2)) {
> +			struct rpc_rqst *next =3D =
list_first_entry(&req->rq_xmit2,
> +					struct rpc_rqst, rq_xmit2);
> +			list_del(&req->rq_xmit2);
> +			list_add_tail(&next->rq_xmit, =
&next->rq_xprt->xmit_queue);
> +		}
> +	} else
> +		list_del(&req->rq_xmit2);
> }
>=20
> /**
> --=20
> 2.17.1

Hi Trond-

I've chased down a couple of remaining regressions with the v4.20 NFS =
client,
and they seem to be rooted in this commit.

When using sec=3Dkrb5, krb5i, or krb5p I found that multi-threaded =
workloads
trigger a lot of server-side disconnects. This is with TCP and RDMA =
transports.
An instrumented server shows that the client is under-running the GSS =
sequence
number window. I monitored the order in which GSS sequence numbers =
appear on
the wire, and after this commit, the sequence numbers are wildly =
misordered.
If I revert the hunk in xprt_request_enqueue_transmit, the problem goes =
away.

I also found that reverting that hunk results in a 3-4% improvement in =
fio
IOPS rates, as well as improvement in average and maximum latency as =
reported
by fio.


--
Chuck Lever



