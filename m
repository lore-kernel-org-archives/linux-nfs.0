Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37110 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751760AbdGUQiJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 12:38:09 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0D68BC06C9E3
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:09 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-121-35.rdu2.redhat.com [10.10.121.35])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B51C760C14
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:08 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 03/11] atomicio: removed a warning
Date: Fri, 21 Jul 2017 12:37:58 -0400
Message-Id: <20170721163806.15803-4-steved@redhat.com>
In-Reply-To: <20170721163806.15803-1-steved@redhat.com>
References: <20170721163806.15803-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

atomicio.c:43:7: warning: this statement may fall through [-Wimplicit-fallthrough=]

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/atomicio.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/support/nfs/atomicio.c b/support/nfs/atomicio.c
index 5e760e6..9bf65b9 100644
--- a/support/nfs/atomicio.c
+++ b/support/nfs/atomicio.c
@@ -42,6 +42,8 @@ ssize_t atomicio(ssize_t(*f) (int, void *, size_t), int fd, void *_s, size_t n)
 		case -1:
 			if (errno == EINTR || errno == EAGAIN)
 				continue;
+			break;
+			/* FALLTHRU */
 		case 0:
 			if (pos != 0)
 				return pos;
-- 
2.13.3

