Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E6F7ECDE47
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 15:33:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0184F2084A
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 15:33:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0184F2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727825AbeJZAGT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 20:06:19 -0400
Received: from mx1.redhat.com ([209.132.183.28]:39526 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727450AbeJZAGT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Oct 2018 20:06:19 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C9B2B30820DE
        for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2018 15:33:02 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 855A95D6AA
        for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2018 15:33:02 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: Add braces around EBUSY code
Date:   Thu, 25 Oct 2018 11:33:00 -0400
Message-Id: <20181025153300.42624-1-steved@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 25 Oct 2018 15:33:02 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index eed0356..0a25b1f 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -1080,7 +1080,7 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 			return EX_SUCCESS;
 
 #pragma GCC diagnostic ignored "-Wdiscarded-qualifiers"
-		if (errno == EBUSY && is_mountpoint(mi->node))
+		if (errno == EBUSY && is_mountpoint(mi->node)) {
 #pragma GCC diagnostic warning "-Wdiscarded-qualifiers"
 			/*
 			 * EBUSY can happen when mounting a filesystem that
@@ -1090,6 +1090,7 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 			 * Only error out in the latter case.
 			 */
 			return EX_SUCCESS;
+		}
 
 		if (nfs_is_permanent_error(errno))
 			break;
-- 
2.17.2

