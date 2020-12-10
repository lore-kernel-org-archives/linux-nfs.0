Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.8 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95FEFC4361B
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Dec 2020 19:12:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6647E23D9A
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Dec 2020 19:12:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392732AbgLJTLn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 10 Dec 2020 14:11:43 -0500
Received: from us-smtp-delivery-124.mimecast.com ([63.128.21.124]:23473 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S2393251AbgLJTLg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Dec 2020 14:11:36 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1607627409;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=J/8agdVhuhFUv2fQWRj7cGTpRpX1gARpf0kD0KYLxL8=;
        b=VRwDfbgxLFUzetiQJRojcO/m5dgYTP0XzDmHPLTbEkka3UeuYT1Q5kzsZ8BaOSnlsoyedy
        q+pxCSVlBTReuEEQYmATjf3K76ihkvkwWbFAHlyFrFVHQBuKcwaLAt0hOM29NZAXQgW6wi
        4h14fgKLTl202/PGAeEwNqPSMgAgjeM=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-50-Z_A1qK0rMnaHkwxrlmraPg-1; Thu, 10 Dec 2020 14:10:07 -0500
X-MC-Unique: Z_A1qK0rMnaHkwxrlmraPg-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id CC02F800D53
        for <linux-nfs@vger.kernel.org>; Thu, 10 Dec 2020 19:10:06 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-113-179.phx2.redhat.com [10.3.113.179])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 86DB810016F7
        for <linux-nfs@vger.kernel.org>; Thu, 10 Dec 2020 19:10:06 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] exports.man: Remove some outdated verbiage
Date:   Thu, 10 Dec 2020 14:10:40 -0500
Message-Id: <20201210191040.21901-1-steved@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Years ago, commit 6a7d90cea765 removed the warning
this verbiage was talking about, but was never
removed from the man page.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/exportfs/exports.man | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 1d17184..54b3f87 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -169,13 +169,6 @@ default.  In all releases after 1.0.0,
 is the default, and
 .I async
 must be explicitly requested if needed.
-To help make system administrators aware of this change,
-.B exportfs
-will issue a warning if neither
-.I sync
-nor
-.I async
-is specified.
 .TP
 .IR no_wdelay
 This option has no effect if
-- 
2.28.0

