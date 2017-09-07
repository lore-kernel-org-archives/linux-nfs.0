Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36119 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753819AbdIGPOp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Sep 2017 11:14:45 -0400
Received: by mail-qk0-f182.google.com with SMTP id z143so27671100qkb.3
        for <linux-nfs@vger.kernel.org>; Thu, 07 Sep 2017 08:14:45 -0700 (PDT)
Received: from hut.sorensonfamily.com ([2603:300a:2104:9500:4eeb:42ff:fec7:ee1c])
        by smtp.gmail.com with ESMTPSA id y31sm1818242qta.83.2017.09.07.08.14.43
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Sep 2017 08:14:43 -0700 (PDT)
To: linux-nfs@vger.kernel.org
From: Frank Sorenson <sorenson@redhat.com>
Subject: [PATCH RFC] nfs-utils: mount: handle EACCES during version
 negotiation
Message-ID: <279c0751-8284-5289-3407-129dc9c9d3e8@redhat.com>
Date: Thu, 7 Sep 2017 10:14:42 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mount() can return EACCES for servers which permit 4.0
but are configured not to allow 4.1  This is currently
only handled by the default case, so these mounts fail
without retrying a lower minor.

Add handling for EACCES to be retried with a lower
minor version.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 utils/mount/stropts.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 1d30d34..4401314 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -862,6 +862,9 @@ check_result:
 	case EINVAL:
 		/* A less clear indication that our client
 		 * does not support NFSv4 minor version. */
+	case EACCES:
+		/* An unclear indication that the server
+		 * may not support NFSv4 minor version. */
 		if (mi->version.v_mode != V_SPECIFIC) {
 			if (mi->version.minor > 0) {
 				mi->version.minor--;
-- 
2.13.5

