Return-Path: <SRS0=jPLZ=PP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25D1DC43387
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 18:43:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D71672054F
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 18:43:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MIXZD4FO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726899AbfAGSnJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Jan 2019 13:43:09 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:48682 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726718AbfAGSnI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2019 13:43:08 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x07IXvZm084237;
        Mon, 7 Jan 2019 18:43:02 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=g53O3S6dY47c2HAcHzs94kM8RBTrDdB7EDAhERY/v1U=;
 b=MIXZD4FOsKmGQ9+cRl29aaRtISCkruzTxQhbrlQE0mA+mgL8rAGCXuIdfjdSY5O1edTf
 r6PHDuyIdUaLBpkoUDgaNVX1vAe6Ix2Bljcl/qn4hRvojDQuak+wQaKhthcvj05SwD80
 l/STvPCcn5dUb3Bt1Qo0A7fiJ8nMe1r8LYs95uQRjG+dwEshpuhv8ErF8UkzA5WBLahB
 B2LfTimqPhzmw7ijYjF3uSMrDseuzbxwJ0V3vBsDkIUrLaNkviQdkHdFIjg3MvyDGJc3
 Zu8oMcsbTk+Rtm6ClYg8kI4Yzxri5V58XBoi7gd1151fzP6Lw6bSi0KPtzis/hIU5fGF EA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2ptj3dqnkg-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 07 Jan 2019 18:43:01 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x07IguhK030542
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 7 Jan 2019 18:42:56 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x07IgtaY016928;
        Mon, 7 Jan 2019 18:42:55 GMT
Received: from kadam (/10.175.22.59)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 07 Jan 2019 10:42:54 -0800
Date:   Mon, 7 Jan 2019 21:41:48 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Subject: Re: [PATCH 2/2] xprtrdma: Double free in rpcrdma_sendctxs_create()
Message-ID: <20190107184148.GC3253@kadam>
References: <20190105130648.GC3288@kadam>
 <0CEEB35A-2083-4888-9035-8A9ADF22E8E3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0CEEB35A-2083-4888-9035-8A9ADF22E8E3@oracle.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9129 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=695
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901070158
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Jan 05, 2019 at 11:24:45AM -0500, Chuck Lever wrote:
> 
> > On Jan 5, 2019, at 8:06 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> > 
> > The clean up is handled by the caller, rpcrdma_buffer_create(), so this
> > call to rpcrdma_sendctxs_destroy() leads to a double free.
> 
> True. This fix is adequate, but I'm wondering if rpcrdma_sendctxs_destroy
> should be made more careful about being called twice. Hm.
> 

I actually wrote the patch like that originally, but then this way made
for an easier patch description so I re-wrote it.  Let me send the other
patch and you can apply that or both if you want.

regards,
dan carpenter

