Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 390EEECAAD5
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Aug 2022 23:01:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1345417AbiHZXBb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Aug 2022 19:01:31 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53862 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231738AbiHZXBb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Aug 2022 19:01:31 -0400
Received: from mx0a-00069f02.pphosted.com (mx0a-00069f02.pphosted.com [205.220.165.32])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5F399E831A
        for <linux-nfs@vger.kernel.org>; Fri, 26 Aug 2022 16:01:30 -0700 (PDT)
Received: from pps.filterd (m0246629.ppops.net [127.0.0.1])
        by mx0b-00069f02.pphosted.com (8.17.1.5/8.17.1.5) with ESMTP id 27QMYCGN026510
        for <linux-nfs@vger.kernel.org>; Fri, 26 Aug 2022 23:01:30 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2022-7-12;
 bh=mGsINb4UfnfLis4OmDcApDiK9Brmtumljgoblmilaq8=;
 b=ZkWx1coVzgQ0NJ0bjKHtsdkjPPJBZoSW6df233jhWecXYitSD85gMw9DHkdSiOa9PieD
 lS2w6lun8ZA9LMg/Iki9fem3zToznUT/v1LXB4O3X2zaMhobmDSB4av4yS34vL8HCSVo
 0i6XWtBQ7u9CFIyF68/3h6PgppHQ+yoyLvfO4kAUx/KjTkP4QaHSZq8chUY+UmZa54O8
 SzIY1s9nd5Q2Xq/BnKqfAx9AQWz/EEgd8a6KjOynciV+0KBxs0qiTEJrkWmbRxM+DtoE
 CABw2nyG1WQVlDH2KBl+kmlwMfeNpdtAUyVx6BJAlsIMmDl+AW5sece3hrOTk1v2jAQ0 ig== 
Received: from iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (iadpaimrmta02.appoci.oracle.com [147.154.18.20])
        by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 3j55p28xxe-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Fri, 26 Aug 2022 23:01:29 +0000
Received: from pps.filterd (iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com [127.0.0.1])
        by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (8.17.1.5/8.17.1.5) with ESMTP id 27QJUPV8033656
        for <linux-nfs@vger.kernel.org>; Fri, 26 Aug 2022 23:01:28 GMT
Received: from pps.reinject (localhost [127.0.0.1])
        by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (PPS) with ESMTPS id 3j5n6rjcbm-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Fri, 26 Aug 2022 23:01:28 +0000
Received: from iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com [127.0.0.1])
        by pps.reinject (8.17.1.5/8.17.1.5) with ESMTP id 27QN1SqA005764
        for <linux-nfs@vger.kernel.org>; Fri, 26 Aug 2022 23:01:28 GMT
Received: from ca-common-hq.us.oracle.com (ca-common-hq.us.oracle.com [10.211.9.209])
        by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (PPS) with ESMTP id 3j5n6rjcb7-1;
        Fri, 26 Aug 2022 23:01:28 +0000
From:   Dai Ngo <dai.ngo@oracle.com>
To:     chuck.lever@oracle.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] NFSD: memory shrinker for NFSv4 clients
Date:   Fri, 26 Aug 2022 16:01:24 -0700
Message-Id: <1661554886-26025-1-git-send-email-dai.ngo@oracle.com>
X-Mailer: git-send-email 1.8.3.1
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.205,Aquarius:18.0.895,Hydra:6.0.517,FMLib:17.11.122.1
 definitions=2022-08-26_12,2022-08-25_01,2022-06-22_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 phishscore=0 spamscore=0
 bulkscore=0 adultscore=0 mlxscore=0 malwarescore=0 mlxlogscore=792
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2207270000
 definitions=main-2208260090
X-Proofpoint-ORIG-GUID: 25a7hvUZr3QnB1nyfGF0yMjYydDSmoSX
X-Proofpoint-GUID: 25a7hvUZr3QnB1nyfGF0yMjYydDSmoSX
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This patch series implements the memory shrinker for NFSv4 clients
to react to system low memory condition.

The memory shrinker's count callback is used to trigger the laundromat.
The actual work of destroying the expired clients is done by the
laundromat itself. We can not destroying the expired clients on the
memory shrinler's scan callback context to avoid possible deadlock.

By destroying the expired clients, all states associated with these
clients are also released.

---

Dai Ngo (2):
      NFSD: keep track of the number of courtesy clients in the system
      NFSD: add shrinker to reap courtesy clients on low memory condition

 fs/nfsd/netns.h     |  5 ++++
 fs/nfsd/nfs4state.c | 69 ++++++++++++++++++++++++++++++++++++++++++------
 fs/nfsd/nfsctl.c    |  6 +++--
 fs/nfsd/nfsd.h      |  9 +++++--
 4 files changed, 77 insertions(+), 12 deletions(-)

