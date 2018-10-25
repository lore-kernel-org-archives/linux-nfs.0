Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 587B9C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:54:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1B21D2064C
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:54:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B21D2064C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=163.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726465AbeJYNZM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 09:25:12 -0400
Received: from mx1.redhat.com ([209.132.183.28]:45828 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726365AbeJYNZM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Oct 2018 09:25:12 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 202591E2CC;
        Thu, 25 Oct 2018 04:54:12 +0000 (UTC)
Received: from dhcp-12-115.nay.redhat.com (dhcp-12-115.nay.redhat.com [10.66.12.115])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B5C9A19744;
        Thu, 25 Oct 2018 04:54:10 +0000 (UTC)
From:   "Jianhong.Yin" <yin-jianhong@163.com>
To:     steved@redhat.com
Cc:     linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH] [nfs-utils] mount: improve error msg when mount fail wirh EBUSY
Date:   Thu, 25 Oct 2018 12:54:00 +0800
Message-Id: <20181025045400.24997-1-yin-jianhong@163.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 25 Oct 2018 04:54:12 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

EBUSY can happen when mounting a filesystem that
is already mounted or when the context= are
different when using the -o sharecache

so update the error message from to:
- %mountpoint% is busy or already mounted
+ %mountpoint% is busy or already mounted or sharecache fail

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 utils/mount/error.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index c9797fc..dfe5c7d 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -223,7 +223,7 @@ void mount_error(const char *spec, const char *mount_point, int error)
 				  progname, mount_point);
 		break;
 	case EBUSY:
-		nfs_error(_("%s: %s is busy or already mounted"),
+		nfs_error(_("%s: %s is busy or already mounted or sharecache fail"),
 			progname, mount_point);
 		break;
 	case ENOENT:
-- 
2.17.2

