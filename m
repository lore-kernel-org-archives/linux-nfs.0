Return-Path: <SRS0=xBSR=SD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04ACBC10F05
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Apr 2019 16:22:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C457921473
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Apr 2019 16:22:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="drGr3G7c"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726854AbfDAQWD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 1 Apr 2019 12:22:03 -0400
Received: from aserp2130.oracle.com ([141.146.126.79]:45966 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727032AbfDAQWD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Apr 2019 12:22:03 -0400
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x31GIYUt089880
        for <linux-nfs@vger.kernel.org>; Mon, 1 Apr 2019 16:22:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=to : from : subject :
 message-id : date : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=rRA8KFhCJ4e2PhHqpq73WVPHvMmHN+3ZebfKmrIn2ic=;
 b=drGr3G7cz1U54qZhYYtJdwQmTKxwa5ObTEkuO7mgx+IC8e0V+2LEiKJFOuWSb3qZlIKT
 ZiMBblzm7f1HshljeHyrGYsCeUvgBC9ORM6IrYgLOQyqUXLMdfRg9zKdF5zuyCg8xi/r
 /ebK0QxYuI6JnIYxXURcEkxt6xj9KAmO7/8UoXLPfpOoxbZ5nYrTA++tFQw3gM522gMl
 plRa62YYoFW2QEg59/aynGE1WeAFfcNaS5j1wqA6AncVsULJpah3jHYK7a2LzTv+WtFt
 27vVgaJzyuj4Y3HTsN0a7t8CCgM1QWTRVYsCL8piJc/VzB7hpTeOUk+02X7jK1X0vpYY GA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2130.oracle.com with ESMTP id 2rhwyd08px-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Mon, 01 Apr 2019 16:22:01 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x31GLoXp020251
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Mon, 1 Apr 2019 16:21:50 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x31GLo2S015990
        for <linux-nfs@vger.kernel.org>; Mon, 1 Apr 2019 16:21:50 GMT
Received: from bradley.us.oracle.com (/10.152.12.111)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 01 Apr 2019 09:21:50 -0700
To:     linux-nfs@vger.kernel.org
From:   "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>
Subject: directory delegations
Message-ID: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
Date:   Mon, 1 Apr 2019 12:21:49 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9214 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=719 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904010108
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi, I'm the architect for Oracle's File Storage Service.   FSS is 
basically a big scalable NFS server that runs in Oracle's cloud.

Our metadata operations have higher latency than a vanilla NFS server 
(e.g., a Linux NFS server serving a XFS stored on a block device), and 
we suspect that directory delegations would make a big performance 
improvement.

I understand, however, that essentially no one implements directory 
delegations.

Can anyone fill me in on the current thinking of the future of support 
for directory delegations in the Linux NFS client?

-Bradley


