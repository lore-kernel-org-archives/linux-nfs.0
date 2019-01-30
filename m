Return-Path: <SRS0=/R4e=QG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39DFEC282D7
	for <linux-nfs@archiver.kernel.org>; Wed, 30 Jan 2019 20:15:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EEC942184D
	for <linux-nfs@archiver.kernel.org>; Wed, 30 Jan 2019 20:15:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="FGR2D4TB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730902AbfA3UPo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 30 Jan 2019 15:15:44 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:34558 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728446AbfA3UPo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2019 15:15:44 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0UK8vD1193745;
        Wed, 30 Jan 2019 20:15:41 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : content-type :
 content-transfer-encoding : mime-version : subject : message-id : date :
 cc : to; s=corp-2018-07-02;
 bh=YsZhINC0ZKq2F0UZWN2ad3TGQAe5+NcM+JdHdeT+2mk=;
 b=FGR2D4TBk1p1CKFBX2WIrc/PBugDLH6n9xOY2Atecv5J4HF3vhfh8/O/hUZqgqzxklJa
 TLBZL8cyccOUqZLgA02ECuJRsYUvypK6beERyd5a/SHvXrzp1MSAdf59MhzRgEAUSHRS
 cfeURrtCMqilSoMUYMYiqZDilJXwlBzPdVrbPf/AZ7//7LrScS94d6dlBPxekh3n0Hq/
 UvEMpmZb4bIQyeyamPJJvDb7CxlFOsqP9C+WU4orA/PbW6LheiQaZT0G/SL5MRDJYpOL
 ThrhmI0XcZHVLQVbmDw682GhuydkpmeL2FweXRjju8NMJdnY4wxcg2IewYTurmuwxYjl Ug== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2130.oracle.com with ESMTP id 2q8eyumtd0-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 30 Jan 2019 20:15:41 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0UKFegV002487
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 30 Jan 2019 20:15:41 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0UKFd9U014285;
        Wed, 30 Jan 2019 20:15:40 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 30 Jan 2019 12:15:39 -0800
From:   Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Windows server IOPS benchmark result
Message-Id: <8C05243F-E8A9-417A-8677-43F0DB630C25@oracle.com>
Date:   Wed, 30 Jan 2019 15:15:38 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9152 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=754 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901300151
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond, this is what I mentioned to you yesterday.

=
https://blogs.technet.microsoft.com/filecab/2018/10/30/windows-server-2019=
-and-intel-optane-dc-persistent-memory/

I thought others on the list might also be interested.

--
Chuck Lever



