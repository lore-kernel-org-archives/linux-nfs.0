Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AE4CC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 09:16:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1591D2084C
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 09:16:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729683AbfDBJQ4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 05:16:56 -0400
Received: from mx1.redhat.com ([209.132.183.28]:50614 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729156AbfDBJQ4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 05:16:56 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0DEA3C04FFEF;
        Tue,  2 Apr 2019 09:16:56 +0000 (UTC)
Received: from localhost (dhcp-12-206.nay.redhat.com [10.66.12.206])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 7017A60BE6;
        Tue,  2 Apr 2019 09:16:55 +0000 (UTC)
From:   Yongcheng Yang <yongcheng.yang@gmail.com>
To:     Steve Dickson <steved@redhat.com>
Cc:     linux-nfs@vger.kernel.org,
        Yongcheng Yang <yongcheng.yang@gmail.com>
Subject: [PATCH] nfs-utils: nfsidmap fail to build if no --with-pluginpath specified
Date:   Tue,  2 Apr 2019 17:16:51 +0800
Message-Id: <20190402091651.17186-1-yongcheng.yang@gmail.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 02 Apr 2019 09:16:56 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The var "pkgplugindir" will be empty if no pluginpath provided.
Makefile "-rpath $(pkgplugindir)" will then get failed.

Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
---
 support/nfsidmap/Makefile.am | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/support/nfsidmap/Makefile.am b/support/nfsidmap/Makefile.am
index cdbeb4c..9c21fa3 100644
--- a/support/nfsidmap/Makefile.am
+++ b/support/nfsidmap/Makefile.am
@@ -1,4 +1,8 @@
+if PATH_PLUGINS
 pkgplugindir=$(PATH_PLUGINS)
+else
+pkgplugindir=$(libdir)/libnfsidmap
+endif
 
 if ENABLE_LDAP
 UMICH_LDAP_LIB = umich_ldap.la
-- 
2.17.2

