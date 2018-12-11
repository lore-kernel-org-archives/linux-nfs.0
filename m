Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BEA8C5CFFE
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 15:27:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 309F820849
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 15:27:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="H4plvRr7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 309F820849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726241AbeLKP1P (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 10:27:15 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:58898 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726366AbeLKP1P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 10:27:15 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBBFNfLf051626;
        Tue, 11 Dec 2018 15:26:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=Yt9n6b9ZxUbGZm6HfmNTGAo59r7D4qAVPJNOzPHL2Dk=;
 b=H4plvRr7xItWUdWVd+qZJgaRPeH5H6HVGdz3ZICrLez04WbOqnRFPGzsW9MsnzCDkyAV
 tXLKQlKxwXaH311FuU8R8g3Fy7/2Td7Mgs5da9mJeX3pxAjyS06DkVQvTQ0PCOFgUFQW
 uXlf96OPb9XzXp9dlYQ8krGSXJ5ctVpoAcMvNning+CgHgW7Bzh1kGTB8Lf3ZyuDpIlk
 aTdTkuXngaM+mQJG4c4HRPtjOKhJe4aj4JsaNFIy8ERkZIjzqHy85fh9hESJieSHysLp
 F3RM5HICorlZJVz15vhxSa7qdjsyxKOC6K8JsEN0GQI0CQhnkvAWUW6DxESMjrk97fVb hQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2130.oracle.com with ESMTP id 2p83fe4nnw-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 11 Dec 2018 15:26:53 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBBFQml7026130
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 11 Dec 2018 15:26:48 GMT
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBBFQmEX027669;
        Tue, 11 Dec 2018 15:26:48 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 11 Dec 2018 07:26:48 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v3 02/24] IB/rxe: IB_WR_REG_MR does not capture MR's iova
 field
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181211140005.GA30471@infradead.org>
Date:   Tue, 11 Dec 2018 10:26:46 -0500
Cc:     Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <F62442DF-C5D2-454C-8A85-4EF91E29C2EF@oracle.com>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
 <20181210162929.4198.19503.stgit@manet.1015granger.net>
 <20181211140005.GA30471@infradead.org>
To:     Christoph Hellwig <hch@infradead.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9103 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=517
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812110139
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 11, 2018, at 9:00 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> Shouldn't this go in through the rdma tree?

In fact, yes. Jason has already accepted it. I included
it again in this series for anyone who tests my patches
with soft RoCE. I can drop this patch for subsequent posts.

--
Chuck Lever



