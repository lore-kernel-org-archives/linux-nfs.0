Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57596 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754531AbdGUQiK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 12:38:10 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 65316461D2
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:10 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-121-35.rdu2.redhat.com [10.10.121.35])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 1A19260C14
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:10 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/11] bldev_read_serial: removed a couple warnings
Date: Fri, 21 Jul 2017 12:38:01 -0400
Message-Id: <20170721163806.15803-7-steved@redhat.com>
In-Reply-To: <20170721163806.15803-1-steved@redhat.com>
References: <20170721163806.15803-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

device-inq.c:216:7: warning: this statement may fall through [-Wimplicit-fallthrough=]
device-inq.c:223:7: warning: this statement may fall through [-Wimplicit-fallthrough=]

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/blkmapd/device-inq.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
index 0062a8f..c7952c3 100644
--- a/utils/blkmapd/device-inq.c
+++ b/utils/blkmapd/device-inq.c
@@ -216,6 +216,7 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 			if ((dev_id->len != 8) && (dev_id->len != 12) &&
 			    (dev_id->len != 16))
 				break;
+			/* FALLTHRU */
 		case 3:	/* NAA */
 			/* TODO: NAA validity judgement too complicated,
 			 * so just ingore it here.
@@ -224,6 +225,7 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
 				BL_LOG_ERR("Binary code_set expected\n");
 				break;
 			}
+			/* FALLTHRU */
 		case 0:	/* vendor specific */
 		case 1:	/* T10 vendor identification */
 			current_id = dev_id->ids & 0xf;
-- 
2.13.3

