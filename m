Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A3C4C433EF
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Jun 2022 20:29:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1378664AbiFPU3I (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Jun 2022 16:29:08 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45236 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1378667AbiFPU3H (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2022 16:29:07 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTP id 1EDAD5C750
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jun 2022 13:29:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1655411345;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=kx/LUPv0bPXL1iyWPVt9+hVuqushkKMELxnCgrepSVQ=;
        b=Zq3ufc1vS15RtRUTuvwV3cmsTuKL1+SMaeh+GLQiOoqXWcnj4rsTXH5UQzeaRClI9xfY7C
        CpW/CkXWXc2tzdN0Jlr1/Sof0chc8G6qZsQ5ia0fPMLb+K3n94ZqMxFTwDR9OCvBQIGCRe
        LZyzgUCKem2BDe0Q8OSECDCgwkVhpt0=
Received: from mimecast-mx02.redhat.com (mx3-rdu2.redhat.com
 [66.187.233.73]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-526-H8Odn6DhPqm84xQB1StjiA-1; Thu, 16 Jun 2022 16:29:04 -0400
X-MC-Unique: H8Odn6DhPqm84xQB1StjiA-1
Received: from smtp.corp.redhat.com (int-mx10.intmail.prod.int.rdu2.redhat.com [10.11.54.10])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id B648F3C0CD50
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jun 2022 20:29:03 +0000 (UTC)
Received: from madhat.home.dicksonnet.net (unknown [10.2.16.194])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 8994C40334E
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jun 2022 20:29:03 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/4] acl_nfs4_get_who: removed an always false evaluate warning
Date:   Thu, 16 Jun 2022 16:29:02 -0400
Message-Id: <20220616202902.53969-4-steved@redhat.com>
In-Reply-To: <20220616202902.53969-1-steved@redhat.com>
References: <20220616202902.53969-1-steved@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.85 on 10.11.54.10
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 libnfs4acl/acl_nfs4_get_who.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libnfs4acl/acl_nfs4_get_who.c b/libnfs4acl/acl_nfs4_get_who.c
index 695db2e..3e2fd7c 100644
--- a/libnfs4acl/acl_nfs4_get_who.c
+++ b/libnfs4acl/acl_nfs4_get_who.c
@@ -49,7 +49,7 @@ int acl_nfs4_get_who(struct nfs4_ace* ace, int* type, char** who)
 	char* iwho = NULL;
 	int wholen;
 
-	if (ace == NULL || ace->who == NULL)
+	if (ace == NULL)
 		goto inval_failed;
 
 	itype = acl_nfs4_get_whotype(ace->who);
-- 
2.36.1

