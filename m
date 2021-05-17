Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6B0FC433ED
	for <linux-nfs@archiver.kernel.org>; Mon, 17 May 2021 22:43:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A9897611BF
	for <linux-nfs@archiver.kernel.org>; Mon, 17 May 2021 22:43:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1344018AbhEQWpB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 May 2021 18:45:01 -0400
Received: from mx0b-00069f02.pphosted.com ([205.220.177.32]:59444 "EHLO
        mx0b-00069f02.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S236878AbhEQWpA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2021 18:45:00 -0400
Received: from pps.filterd (m0246630.ppops.net [127.0.0.1])
        by mx0b-00069f02.pphosted.com (8.16.0.43/8.16.0.43) with SMTP id 14HMfrEt023092;
        Mon, 17 May 2021 22:43:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2020-01-29; bh=Z261lr6g+w9tGZ1+MpXSBR0T5+E8W3C9XBorlKxfuf4=;
 b=s6zYDhnoFtKcNjTWwXwOvZgSuVeihbTMk+p9wlmlxx2ph/Nq/kRtM8ruLDfUpeaWmzig
 wc/LiLhHiu8BdM38nPziD1zvz2MVgHU3UKyEhdSfpV/iauaLL9ViRCJrEWEf+TpGaKoW
 tBkE/mV0FVNZU7mxfTPbaJekceOMm7CN3TOtRKn2YYcg/J2yd9iLXWwyg2I9hf9l5KWb
 Q7LaeVMBlb9/YQUKqqQ64vw+I7Ugfj4PXicxK8jat4s6MGU94W/JtvEF5rKg9/P/5Qgr
 HU7H8OSqJhosZbQUdeAaLDiPfvp83fhIspE3hty010kb8KilDza09UnhIzrfDD2iSrnK DA== 
Received: from oracle.com (userp3020.oracle.com [156.151.31.79])
        by mx0b-00069f02.pphosted.com with ESMTP id 38kffu0d6q-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 17 May 2021 22:43:39 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
        by pps.podrdrct (8.16.0.36/8.16.0.36) with SMTP id 14HMfAZl145354;
        Mon, 17 May 2021 22:43:38 GMT
Received: from pps.reinject (localhost [127.0.0.1])
        by userp3020.oracle.com with ESMTP id 38kb37baw3-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 17 May 2021 22:43:38 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
        by pps.reinject (8.16.0.36/8.16.0.36) with SMTP id 14HMhbq8153088;
        Mon, 17 May 2021 22:43:37 GMT
Received: from aserp3030.oracle.com (ksplice-shell2.us.oracle.com [10.152.118.36])
        by userp3020.oracle.com with ESMTP id 38kb37bavx-1;
        Mon, 17 May 2021 22:43:37 +0000
From:   Dai Ngo <dai.ngo@oracle.com>
To:     olga.kornievskaia@gmail.com, bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org, trondmy@hammerspace.com,
        chuck.lever@oracle.com
Subject: [PATCH v5 0/2] NFSD: delay unmount source's export after inter-server copy completed.
Date:   Mon, 17 May 2021 18:43:28 -0400
Message-Id: <20210517224330.9201-1-dai.ngo@oracle.com>
X-Mailer: git-send-email 2.20.1.1226.g1595ea5.dirty
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-ORIG-GUID: irlJzAWe-c8XmdWVzaiZCkryKnbC1yio
X-Proofpoint-GUID: irlJzAWe-c8XmdWVzaiZCkryKnbC1yio
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Olga, Bruce,

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
v5: make use of the laundomat thread to service delayed unmount list.
    destroy delayed unmount list when nfsd is shutdown.
    make delayed unmount list per nfsd_net to support container.


