Return-Path: <SRS0=7zHz=PX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54B57C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 21:41:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 22BFE20657
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 21:41:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="V4FTcBL3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390597AbfAOVla (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Jan 2019 16:41:30 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:37160 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730500AbfAOVla (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2019 16:41:30 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0FLd0Yl032173;
        Tue, 15 Jan 2019 21:41:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=jK2W8S9WU7TF5iiex6ICIWOuc+skfj+Ue3nQaZ2i57U=;
 b=V4FTcBL3wlLy/PKBI53gbxFA8IoMzNLXO3fQ5vvJQh2Pn3vywczSxXjSVAxDgKYz9jjU
 93En/0XbxBygjE6xZPzTcrdOBqA8CxP6HqUiwiQkr3XXLyRuDjULoDvsY3nXuCpZftcM
 scuU7SPa08F0lBFvQXb9DKaVwDhK7n1OoG2JNUwPSUN1SIbm8Uy2hb50xhRKd7Y1ecoz
 mEww3zszMlbnbsd/8HIJ6K+MZRGnDm50ysVfzIT5Avu3CsYU0PiQOkGFL6FnsWTc1EiN
 nxcWI2oMpXFlx2+0n1fQTrt9LcRxQxVRnKwphrcIfpIzEaibrxWEQUL6q7jE31a/OewX 7g== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2130.oracle.com with ESMTP id 2pybjnpehb-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 15 Jan 2019 21:41:24 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0FLfNOI021451
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 15 Jan 2019 21:41:23 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0FLfN0w023395;
        Tue, 15 Jan 2019 21:41:23 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 15 Jan 2019 13:41:23 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: linux-next: Fixes tag needs some work in the nfs-anna tree
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190116083831.256824cf@canb.auug.org.au>
Date:   Tue, 15 Jan 2019 16:41:21 -0500
Cc:     Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Paul Gortmaker <paul.gortmaker@windriver.com>
Content-Transfer-Encoding: 7bit
Message-Id: <A4B834E5-2DFD-428E-8E24-9F6F6A822B09@oracle.com>
References: <20190116083831.256824cf@canb.auug.org.au>
To:     Stephen Rothwell <sfr@canb.auug.org.au>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9137 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=939
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901150172
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Stephen-

On Jan 15, 2019, at 4:38 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> [I am experimenting with checking the Fixes tags in commits in linux-next.
> Please let me know if you think I am being too strict.]
> 
> Hi all,
> 
> Commit
> 
>  deaa5c96c2f7 ("SUNRPC: Address Kerberos performance/behavior regression")
> 
> has problem with this Fixes tag:
> 
>  Fixes: 918f3c1fe83c ("SUNRPC: Improve latency for interactive ... ")
> 
> The subject should match the subject of the fixed commit.
> 
> -- 
> Cheers,
> Stephen Rothwell

I shortened the commit title so that the Fixes: line is shorter than 68
characters. I can leave these titles alone if that's preferred.


--
Chuck Lever



