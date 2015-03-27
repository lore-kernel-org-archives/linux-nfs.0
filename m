Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:34344 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbbC0Qvl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:51:41 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [RFC 02/39] uapi: Remove kernel internal declaration
Date: Fri, 27 Mar 2015 17:50:00 +0100
Message-Id: <063d443cc0ddc5db271cdaa6649443eb699736d0.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The enum nfs4_acl_whotype is only used in nfs4d's internal nfs4 acl
representation. No longer expose it to user space.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 include/linux/nfs4.h      | 7 +++++++
 include/uapi/linux/nfs4.h | 7 -------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index ed43cb7..32201c2 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -16,6 +16,13 @@
 #include <linux/uidgid.h>
 #include <uapi/linux/nfs4.h>
 
+enum nfs4_acl_whotype {
+	NFS4_ACL_WHO_NAMED = 0,
+	NFS4_ACL_WHO_OWNER,
+	NFS4_ACL_WHO_GROUP,
+	NFS4_ACL_WHO_EVERYONE,
+};
+
 struct nfs4_ace {
 	uint32_t	type;
 	uint32_t	flag;
diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
index 35f5f4c..adc0aff 100644
--- a/include/uapi/linux/nfs4.h
+++ b/include/uapi/linux/nfs4.h
@@ -162,13 +162,6 @@
  */
 #define NFS4_MAX_BACK_CHANNEL_OPS 2
 
-enum nfs4_acl_whotype {
-	NFS4_ACL_WHO_NAMED = 0,
-	NFS4_ACL_WHO_OWNER,
-	NFS4_ACL_WHO_GROUP,
-	NFS4_ACL_WHO_EVERYONE,
-};
-
 #endif /* _UAPI_LINUX_NFS4_H */
 
 /*
-- 
2.1.0

