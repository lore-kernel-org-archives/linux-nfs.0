Return-Path: <SRS0=eudZ=TI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37737C04A6B
	for <linux-nfs@archiver.kernel.org>; Wed,  8 May 2019 13:35:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 13C61204FD
	for <linux-nfs@archiver.kernel.org>; Wed,  8 May 2019 13:35:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727106AbfEHNfp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 8 May 2019 09:35:45 -0400
Received: from mx1.redhat.com ([209.132.183.28]:50580 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726656AbfEHNfo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 May 2019 09:35:44 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A21E5811D8
        for <linux-nfs@vger.kernel.org>; Wed,  8 May 2019 13:35:44 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-116-59.phx2.redhat.com [10.3.116.59])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 5D2555C269
        for <linux-nfs@vger.kernel.org>; Wed,  8 May 2019 13:35:44 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 10/19] Removed a resource leak from nsm/file.c
Date:   Wed,  8 May 2019 09:35:27 -0400
Message-Id: <20190508133536.6077-11-steved@redhat.com>
In-Reply-To: <20190508133536.6077-1-steved@redhat.com>
References: <20190508133536.6077-1-steved@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 08 May 2019 13:35:44 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

nsm/file.c:536: leaked_handle: Handle variable "fd" going
	out of scope leaks the handle

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nsm/file.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/support/nsm/file.c b/support/nsm/file.c
index 52f5401..0b66f12 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -533,6 +533,7 @@ nsm_update_kernel_state(const int state)
 	len = snprintf(buf, sizeof(buf), "%d", state);
 	if (error_check(len, sizeof(buf))) {
 		xlog_warn("Failed to form NSM state number string");
+		close(fd);
 		return;
 	}
 
-- 
2.20.1

