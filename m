Return-Path: <SRS0=QvV7=PG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE0B8C43387
	for <linux-nfs@archiver.kernel.org>; Sat, 29 Dec 2018 05:26:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB47121019
	for <linux-nfs@archiver.kernel.org>; Sat, 29 Dec 2018 05:26:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="RbVYSLV2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726310AbeL2FZk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 29 Dec 2018 00:25:40 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:36888 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726134AbeL2FZk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Dec 2018 00:25:40 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBT5P1wM077495;
        Sat, 29 Dec 2018 05:25:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=/jOzbgmOwXsm+ImaDFXsdQvBJxXZOL86F6amz7mxEww=;
 b=RbVYSLV2B1kTaM0yuDQ44gDrE7DUq+zFW/ZJM+cgJl2R2Hye5+1PjIDfriujjY2wzPOO
 MCDuso5/VMbbaa3pCR98aGSqqaAGuDT6hSeA9j8NtcP579C6ILhTiow6sJeU1+T8LKY4
 CLDItmHUMgJzu9mWcwbRkn7Dpj3UIL0cwgGzKAYlfUZzCubVuQTY3UyAGkXQ50ALsA3M
 0jyZth1BJYbQxHH9pC3KDuhUTXPUlR4QNiwEqUzgZ2uvy2xiseGlp+vSXUhob/uUA2Qp
 m5i4sINRz8Z42jF1XWOJWynzwhDO0Kdf0XG+L+rDqiWDslEtYNZcaR9zNwHZpZ08qie8 bw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2130.oracle.com with ESMTP id 2pnxedr9m1-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 29 Dec 2018 05:25:13 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBT5P7r0015570
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 29 Dec 2018 05:25:08 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBT5P5B5003002;
        Sat, 29 Dec 2018 05:25:05 GMT
Received: from localhost (/67.169.218.210)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 28 Dec 2018 21:25:05 -0800
Date:   Fri, 28 Dec 2018 21:25:04 -0800
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     Dan Carpenter <dan.carpenter@oracle.com>
Cc:     Tom Psyborg <pozega.tomislav@gmail.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        kernel-janitors@vger.kernel.org, dmaengine@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Dan Williams <dan.j.williams@intel.com>,
        linux-scsi@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org,
        Stefano Stabellini <sstabellini@kernel.org>,
        xen-devel@lists.xenproject.org, linux-wireless@vger.kernel.org
Subject: Re: [PATCH 00/20] drop useless LIST_HEAD
Message-ID: <20181229052504.GA16315@magnolia>
References: <1545555435-24576-1-git-send-email-Julia.Lawall@lip6.fr>
 <CAKR_QVJefW1vxYb7-qiU8=0YdbFghYo15SK2eGjOC-dntRfyYA@mail.gmail.com>
 <alpine.DEB.2.21.1812232304130.2940@hadrien>
 <CAKR_QVLeZBL43W4x1mzcfcakSZyyh9L81vgUMxfnSccKawEfdg@mail.gmail.com>
 <20181227134055.GA2272@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181227134055.GA2272@kadam>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9120 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=623
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812290048
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Dec 27, 2018 at 04:40:55PM +0300, Dan Carpenter wrote:
> On Tue, Dec 25, 2018 at 11:12:20PM +0100, Tom Psyborg wrote:
> > there was discussion about this just some days ago. CC 4-5 lists is
> > more than enough
> > 
> 
> I don't know who you were discussing this with...
> 
> You should CC the 0th patch to all the mailinglists.  That much is a
> clear rule.
> 
> For the rest, Julia's position is the more conservative one.  I was in
> a conversation in RL and they were like, "CC everyone for all the
> patches".  It depends on the context, of course.  If the patches are
> dependent on each other then you *have* to CC everyone for everything.

Agreed.  Ms. Lawall, sending "Cover letter + all relevant XFS patches"
(as you did) was exactly the right thing for us xfs types. :)

For that matter, we prefer to receive through linux-xfs more patches
than necessary (one can send the entire series if one is unsure) than to
go wanting for more context.

--D

> If we really have other clear rules, then it should be encoded into
> get_maintainer.pl so that it's automatic.
> 
> My other question is why do the linux-arm-kernel@lists.infradead.org
> people feel like they need to be CC'd about every driver???  I always
> remove them from the CC list unless it's an arch/arm issue.
> 
> regards,
> dan carpenter
> 
> PS:  Please, no more top posting.
> 
