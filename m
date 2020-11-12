Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E301BC2D0E4
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Nov 2020 20:17:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7C90F20A8B
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Nov 2020 20:17:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="H6adjQ+O"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727025AbgKLURi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 12 Nov 2020 15:17:38 -0500
Received: from us-smtp-delivery-124.mimecast.com ([216.205.24.124]:38164 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727000AbgKLURi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Nov 2020 15:17:38 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1605212257;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=XZYq8cp4t+RfHutn8gXRsF49P6t4k2nOwingyR/mgRc=;
        b=H6adjQ+O/nAsQIi7Sp2pmOUOwARQNuTt0wRDKoOCUZdzS3LviUW775SREfN6xTKUUm/DV5
        hMe6qiWgHK4RxcnkDaEwRpzSAmEWRDqRMRLOORXIJ6y8y+l0GUv0R+G1sU+Fki+Eyhkx5v
        md1qvpgxemjAMtP0dfIchXub2BEle1o=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-475-lgGfxALAMBmM6cZEUcxaXA-1; Thu, 12 Nov 2020 15:17:35 -0500
X-MC-Unique: lgGfxALAMBmM6cZEUcxaXA-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 2795A1006C89;
        Thu, 12 Nov 2020 20:17:34 +0000 (UTC)
Received: from aion.usersys.redhat.com (ovpn-113-97.rdu2.redhat.com [10.10.113.97])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 0735D6EF6E;
        Thu, 12 Nov 2020 20:17:33 +0000 (UTC)
Received: by aion.usersys.redhat.com (Postfix, from userid 1000)
        id D4CA81A0018; Thu, 12 Nov 2020 15:17:32 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     chuck.lever@oracle.com, bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix oops in the rpc_xdr_buf event class
Date:   Thu, 12 Nov 2020 15:17:32 -0500
Message-Id: <20201112201732.1689680-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Backchannel rpc tasks don't have task->tk_client set, so it's necessary
to check it for NULL before dereferencing.

Fixes: c509f15a5801 ("SUNRPC: Split the xdr_buf event class")

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 include/trace/events/sunrpc.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 2477014e3fa6..2a03263b5f9d 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -68,7 +68,8 @@ DECLARE_EVENT_CLASS(rpc_xdr_buf_class,
 
 	TP_fast_assign(
 		__entry->task_id = task->tk_pid;
-		__entry->client_id = task->tk_client->cl_clid;
+		__entry->client_id = task->tk_client ?
+				     task->tk_client->cl_clid : -1;
 		__entry->head_base = xdr->head[0].iov_base;
 		__entry->head_len = xdr->head[0].iov_len;
 		__entry->tail_base = xdr->tail[0].iov_base;
-- 
2.25.4

