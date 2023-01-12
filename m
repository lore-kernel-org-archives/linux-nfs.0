Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21600C54EBD
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Jan 2023 12:38:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230112AbjALMiv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 12 Jan 2023 07:38:51 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59844 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230046AbjALMiq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2023 07:38:46 -0500
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C3C064A945
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2023 04:38:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1673527081;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=3LEkF52kiLlcjnezdHsU+Xukogr/THMGUZeCGE39d4o=;
        b=c9nZtpnIJRfRZNYTKEG0ZzDsC90EWF0suosydRtr3/r/3GEwhnKGbaz1FbjiE/Fy4qJGK1
        XdKYjKzrAPo5eG+0lg6RuOzeq6gqlf0LZaYuEObYb/sQnuAiVGqFRf9jPHyRcNYRUAGvBg
        U4jqCrn02p3aLJhkuXAomSVqgOFGlj4=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-648-UhRvhWrpPY2udljUC0yJ0Q-1; Thu, 12 Jan 2023 07:37:58 -0500
X-MC-Unique: UhRvhWrpPY2udljUC0yJ0Q-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 002FC811E9C;
        Thu, 12 Jan 2023 12:37:58 +0000 (UTC)
Received: from localhost (yoyang-vm.hosts.qa.psi.pek2.redhat.com [10.73.149.36])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 51AE239D92;
        Thu, 12 Jan 2023 12:37:57 +0000 (UTC)
From:   Yongcheng Yang <yongcheng.yang@gmail.com>
To:     Steve Dickson <steved@redhat.com>
Cc:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Yongcheng Yang <yongcheng.yang@gmail.com>,
        Tom O <tom.oloughlin@gmail.com>
Subject: [PATCH nfs-utils] nfsmount.conf: Fix typo of the attribute name
Date:   Thu, 12 Jan 2023 20:37:52 +0800
Message-Id: <20230112123752.739704-1-yongcheng.yang@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.5
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Tom O <tom.oloughlin@gmail.com>
Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
---
 utils/mount/nfsmount.conf | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mount/nfsmount.conf b/utils/mount/nfsmount.conf
index 342063f7..cbdf8160 100644
--- a/utils/mount/nfsmount.conf
+++ b/utils/mount/nfsmount.conf
@@ -59,13 +59,13 @@
 # acregmin=30
 #
 # The Maximum time (in seconds) file attributes are cached
-# acregmin=60
+# acregmax=60
 #
 # The minimum time (in seconds) directory attributes are cached
-# acregmin=30
+# acdirmin=30
 #
 # The Maximum time (in seconds) directory attributes are cached
-# acregmin=60
+# acdirmin=60
 #
 # Enable Access  Control  Lists
 # Acl=False
-- 
2.31.1

