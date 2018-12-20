Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ED71C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 15:47:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 380A8217D8
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 15:47:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="xO5UOfdr"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729184AbeLTPrf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 10:47:35 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:50214 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727994AbeLTPrf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2018 10:47:35 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBKFiTuG096877;
        Thu, 20 Dec 2018 15:47:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=amhVyz0LaqN5QMQfqin48ibSMyh2gDmc++DSohUMaQc=;
 b=xO5UOfdrrCIFyzWYK6YDfDAbh6hJvv3LObmG1fWde52gMpsmygm07dtnYBo/HO56n93E
 GK2zVaQgt8Nia1hR+AlfbaYFj7PGh4xr9H9x8ZSs69QiD/ENUw6swXFTOwtyJWkZKmri
 bvdDLKZ1l8UjGzDHejedblObWuLNT7FvgIzPws2SaLGa0+dJoDWvm4vZ6xydAhoKEp43
 Vxkj6lOtfTO0LPmD4XCupPK7/HTxMgWol22GzM3nZeMBIuTzZiExrLpNWRac+Hn1eNL3
 e8hFBmXKdl0mDrxINNY2NRe13mPWpog1oVVqOaF+/xiwRxf/t4bXtmrluQXcTxVzeXD5 lA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2pfh3a7y9s-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 20 Dec 2018 15:47:29 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBKFlSv9006751
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 20 Dec 2018 15:47:28 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBKFlR6a015496;
        Thu, 20 Dec 2018 15:47:27 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 20 Dec 2018 07:47:27 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] sunrpc: convert unnecessary GFP_ATOMIC to GFP_NOFS
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181220154236.GC6063@fieldses.org>
Date:   Thu, 20 Dec 2018 10:47:25 -0500
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <09BE8CC3-B528-45BA-B10E-01D7F9FD264D@oracle.com>
References: <20181220153511.GB6063@fieldses.org>
 <20181220154236.GC6063@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9113 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=935
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812200128
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 20, 2018, at 10:42 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> It's OK to sleep here, we just don't want to recurse into the filesystem
> as this writeout could be waiting on this.

"as a writeout"


> Future work: the documentation for GFP_NOFS says "Please try to avoid
> using this flag directly and instead use memalloc_nofs_{save,restore} to
> mark the whole scope which cannot/shouldn't recurse into the FS layer
> with a short explanation why. All allocation requests will inherit
> GFP_NOFS implicitly."
> 
> But I'm not sure where to do this.  Should the workqueue be arranging
> that for us in the case of workqueues created with WQ_MEM_RECLAIM?

There seem to be plenty of uses of GFP_NOFS in NFS and sunrpc.
That sounds like a big project.


> Reported-by: Trond Myklebust <trondmy@hammer.space>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
> net/sunrpc/rpcb_clnt.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Also, I've still got this one.  (And still haven't looked into whether
> it should be using a memalloc_nofs_{save,restore} elsewhere instead.)
> 
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index 08b5fa4a2852..41a971ac1c63 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -752,7 +752,7 @@ void rpcb_getport_async(struct rpc_task *task)
> 		goto bailout_nofree;
> 	}
> 
> -	map = kzalloc(sizeof(struct rpcbind_args), GFP_ATOMIC);
> +	map = kzalloc(sizeof(struct rpcbind_args), GFP_NOFS);
> 	if (!map) {
> 		status = -ENOMEM;
> 		dprintk("RPC: %5u %s: no memory available\n",
> @@ -770,7 +770,7 @@ void rpcb_getport_async(struct rpc_task *task)
> 	case RPCBVERS_4:
> 	case RPCBVERS_3:
> 		map->r_netid = xprt->address_strings[RPC_DISPLAY_NETID];
> -		map->r_addr = rpc_sockaddr2uaddr(sap, GFP_ATOMIC);
> +		map->r_addr = rpc_sockaddr2uaddr(sap, GFP_NOFS);
> 		if (!map->r_addr) {
> 			status = -ENOMEM;
> 			dprintk("RPC: %5u %s: no memory available\n",
> -- 
> 2.19.2
> 

--
Chuck Lever



