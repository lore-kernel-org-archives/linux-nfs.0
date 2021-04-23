Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E29C0C433ED
	for <linux-nfs@archiver.kernel.org>; Fri, 23 Apr 2021 20:59:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B8F396144E
	for <linux-nfs@archiver.kernel.org>; Fri, 23 Apr 2021 20:59:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232466AbhDWVAc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 23 Apr 2021 17:00:32 -0400
Received: from mx0b-00069f02.pphosted.com ([205.220.177.32]:51494 "EHLO
        mx0b-00069f02.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S232636AbhDWVAb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Apr 2021 17:00:31 -0400
Received: from pps.filterd (m0246630.ppops.net [127.0.0.1])
        by mx0b-00069f02.pphosted.com (8.16.0.43/8.16.0.43) with SMTP id 13NKvKNM022552;
        Fri, 23 Apr 2021 20:59:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2020-01-29; bh=FixrKvFR6bdavmP+XOuUjeRNQflMt2wfhigSJB3/Wdk=;
 b=WG7qReQWRtelD7G1Sk8XO1nig/ZM40KLTJLt6YPQsWa9YFaUViPt5Kez7GPE36rKtVDi
 q/62mphY1GdjPtttOC1g2vQLbjYFwCDd33ZcvLoxa5Vd5UAtjFcVXXVa7g6RWvU7K4Oa
 c6tXf6bUs91vw3syZvbJe9FYEs4PPfaW0YgkQX5qIoeIiKRVembqAjzkEemQQ7h0whnz
 VxXAFudkZVu9tU10YxwkbpE+v+Qz0geRyy0PT4eiws5l3S2gswmXR8jNY+XZ3O6DrZ+6
 Mg69SK/xZOTxz+lzja1rpepCm+qoxw3VSI0Ysd3DYKhBzLc5BDyNMW8zSK28+A0EB1vs Fg== 
Received: from oracle.com (aserp3020.oracle.com [141.146.126.70])
        by mx0b-00069f02.pphosted.com with ESMTP id 382yqs8sxh-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 23 Apr 2021 20:59:50 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
        by pps.podrdrct (8.16.0.36/8.16.0.36) with SMTP id 13NKxnSn158663;
        Fri, 23 Apr 2021 20:59:49 GMT
Received: from pps.reinject (localhost [127.0.0.1])
        by aserp3020.oracle.com with ESMTP id 383cbfyqms-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 23 Apr 2021 20:59:49 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
        by pps.reinject (8.16.0.36/8.16.0.36) with SMTP id 13NKxnqI158636;
        Fri, 23 Apr 2021 20:59:49 GMT
Received: from userp3020.oracle.com (ksplice-shell2.us.oracle.com [10.152.118.36])
        by aserp3020.oracle.com with ESMTP id 383cbfyqm0-1;
        Fri, 23 Apr 2021 20:59:49 +0000
From:   Dai Ngo <dai.ngo@oracle.com>
To:     olga.kornievskaia@gmail.com
Cc:     trondmy@hammerspace.com, bfields@fieldses.org,
        chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/2] NFSD: delay unmount source's export after inter-server copy completed.
Date:   Fri, 23 Apr 2021 16:59:44 -0400
Message-Id: <20210423205946.24407-1-dai.ngo@oracle.com>
X-Mailer: git-send-email 2.20.1.1226.g1595ea5.dirty
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-ORIG-GUID: 0gjWhyZ9lVHz9XTekaQTQqdQPamnhSEA
X-Proofpoint-GUID: 0gjWhyZ9lVHz9XTekaQTQqdQPamnhSEA
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Olga,

Currently the source's export is mounted and unmounted on every
inter-server copy operation. This causes unnecessary overhead
for each copy.

This patch series is an enhancement to allow the export to remain
mounted for a configurable period (default to 15 minutes). If the 
export is not being used for the configured time it will be unmounted
by a delayed task. If it's used again then its expiration time is
extended for another period.

Since mount and unmount are no longer done on every copy request,
the restriction of copy size (14*rsize), in __nfs4_copy_file_range,
is removed.

-Dai

v2: fix compiler warning of missing prototype.
v3: remove the used of semaphore.
    eliminated all RPC calls for subsequence mount by allowing
       all exports from one server to share one vfsmount.
    make inter-server threshold a module configuration parameter.
v4: convert nsui_refcnt to use refcount_t.
    add note about 20secs wait in nfsd4_interssc_connect.
    removed (14*rsize) restriction from __nfs4_copy_file_range.



