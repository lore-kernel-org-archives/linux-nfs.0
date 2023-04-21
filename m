Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 362D8C77B7C
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Apr 2023 17:10:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233609AbjDURKC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Apr 2023 13:10:02 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52096 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233412AbjDURJf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Apr 2023 13:09:35 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 18AD215612
        for <linux-nfs@vger.kernel.org>; Fri, 21 Apr 2023 10:08:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1682096899;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=tnsNxdQEZC7vQus465DcOx9VIXBa//NgGizP6y3E330=;
        b=D5z8AzYTCN7AYZbWGCrJg6qEmm1LEtP+zYoUN2kSZ/f5vRieu/ZesfNMWCij+1HE00oOga
        x9Vk0S4kcjJWqxujkHD2u2iOzUQB8OcyTwMOhU82Atcc6CwzTRIiXov6f621OmJim2uRtp
        u+h6Kcy/K93hBhSER+HSkW/vAj95tL4=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-45-m97Vl3bsPbCZStlDpwfJVQ-1; Fri, 21 Apr 2023 13:08:17 -0400
X-MC-Unique: m97Vl3bsPbCZStlDpwfJVQ-1
Received: from smtp.corp.redhat.com (int-mx09.intmail.prod.int.rdu2.redhat.com [10.11.54.9])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 84CDF886462
        for <linux-nfs@vger.kernel.org>; Fri, 21 Apr 2023 17:08:17 +0000 (UTC)
Received: from bcodding.csb.redhat.com (ovpn-0-3.rdu2.redhat.com [10.22.0.3])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2F14F492C14
        for <linux-nfs@vger.kernel.org>; Fri, 21 Apr 2023 17:08:17 +0000 (UTC)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 6/9] NFS: add a sysfs link to the acl rpc_client
Date:   Fri, 21 Apr 2023 13:08:09 -0400
Message-Id: <09f420c311de63756b53b9a330f3d2cf543cc9d9.1682096307.git.bcodding@redhat.com>
In-Reply-To: <cover.1682096307.git.bcodding@redhat.com>
References: <cover.1682096307.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.9
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs3client.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 669cda757a5c..d6726b830c7c 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -4,6 +4,8 @@
 #include <linux/sunrpc/addr.h>
 #include "internal.h"
 #include "nfs3_fs.h"
+#include "netns.h"
+#include "sysfs.h"
 
 #ifdef CONFIG_NFS_V3_ACL
 static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
@@ -31,6 +33,8 @@ static void nfs_init_server_aclclient(struct nfs_server *server)
 	if (IS_ERR(server->client_acl))
 		goto out_noacl;
 
+	nfs_sysfs_link_rpc_client(server, server->client_acl, NULL);
+
 	/* No errors! Assume that Sun nfsacls are supported */
 	server->caps |= NFS_CAP_ACLS;
 	return;
-- 
2.39.2

