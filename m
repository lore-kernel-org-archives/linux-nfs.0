Return-Path: <SRS0=a6gn=M7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 732F6ECDE3D
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Oct 2018 14:21:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 35A3F205C9
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Oct 2018 14:21:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="isqMiwjZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35A3F205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727686AbeJSW16 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 19 Oct 2018 18:27:58 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:37516 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727413AbeJSW16 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 18:27:58 -0400
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9JEEEJm031076;
        Fri, 19 Oct 2018 14:21:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : content-type :
 content-transfer-encoding : mime-version : subject : message-id : date :
 cc : to; s=corp-2018-07-02;
 bh=6Vc5wgcAaKVRgjeCKjfj4/yg6sqUg9uWTX0FpIjgFWM=;
 b=isqMiwjZRGuTCsa5mYtQJPP8wntRO3pVE25fjA8J7xGxQU9r5X/xe10+au0gwxp5ulk+
 JMaK2uWROsJH8IStK1gkB7b3AieN0YavaCZR3WinKyz0FvXwnCS9KyqWQ7S/iDfOSrnF
 NK/rO8cYh4v3GZouwL+2UdjkB2MbIgXD8k009D4m5n35gkkNq9WirwH2GdNOYRn/9vsk
 Hxf28PJXLpN96nb71560/Soxi53FG9Ar4xswk+Xoxde+ibK3ZpuihnzjnkL9ivhr9D1t
 mEz5qvLXC/fGGiCOWjookOABgxuw4Fx3ifa4GItchsEy0ACo9W9n5pyaUgQNOSVez1u2 MQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2120.oracle.com with ESMTP id 2n38nqm9kv-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 19 Oct 2018 14:21:35 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w9JELYPj003956
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 19 Oct 2018 14:21:34 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w9JELVnV009231;
        Fri, 19 Oct 2018 14:21:34 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 19 Oct 2018 07:21:31 -0700
From:   Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: review of v4.20 linux-next merge commit
Message-Id: <2177F9CF-E9E8-4E10-AD14-E53F0F5F9574@oracle.com>
Date:   Fri, 19 Oct 2018 10:21:30 -0400
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9050 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=596
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1810190128
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
Message-ID: <20181019142130.kBL_53-rImtjWKJzGHzQS3Y3_yykL6LJsfIurLECcIA@z>

h=
ttp://git.linux-nfs.org/?p=3Dtrondmy/linux-nfs.git;a=3Dcommitdiff;h=3D93bd=
cf9fdb89646e9446fab25aec76a754969619

I don't see a problem.

--
Chuck Lever



