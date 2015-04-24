Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:35159 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965331AbbDXLFw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:52 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 43/45] uapi/nfs: Add NFSv4.1 ACL definitions
Date: Fri, 24 Apr 2015 13:04:40 +0200
Message-Id: <23f967e5728d254d218cc1134769864242988a08.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the ACL related protocol definitions which were added in the NFSv4.1
specifiction.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 include/uapi/linux/nfs4.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
index adc0aff..2119c7c 100644
--- a/include/uapi/linux/nfs4.h
+++ b/include/uapi/linux/nfs4.h
@@ -86,6 +86,10 @@
 #define ACL4_SUPPORT_AUDIT_ACL 0x04
 #define ACL4_SUPPORT_ALARM_ACL 0x08
 
+#define NFS4_ACL_AUTO_INHERIT 0x00000001
+#define NFS4_ACL_PROTECTED    0x00000002
+#define NFS4_ACL_DEFAULTED    0x00000004
+
 #define NFS4_ACE_FILE_INHERIT_ACE             0x00000001
 #define NFS4_ACE_DIRECTORY_INHERIT_ACE        0x00000002
 #define NFS4_ACE_NO_PROPAGATE_INHERIT_ACE     0x00000004
@@ -93,6 +97,7 @@
 #define NFS4_ACE_SUCCESSFUL_ACCESS_ACE_FLAG   0x00000010
 #define NFS4_ACE_FAILED_ACCESS_ACE_FLAG       0x00000020
 #define NFS4_ACE_IDENTIFIER_GROUP             0x00000040
+#define NFS4_ACE_INHERITED_ACE                0x00000080
 
 #define NFS4_ACE_READ_DATA                    0x00000001
 #define NFS4_ACE_LIST_DIRECTORY               0x00000001
@@ -106,6 +111,8 @@
 #define NFS4_ACE_DELETE_CHILD                 0x00000040
 #define NFS4_ACE_READ_ATTRIBUTES              0x00000080
 #define NFS4_ACE_WRITE_ATTRIBUTES             0x00000100
+#define NFS4_ACE_WRITE_RETENTION              0x00000200
+#define NFS4_ACE_WRITE_RETENTION_HOLD         0x00000400
 #define NFS4_ACE_DELETE                       0x00010000
 #define NFS4_ACE_READ_ACL                     0x00020000
 #define NFS4_ACE_WRITE_ACL                    0x00040000
-- 
2.1.0

