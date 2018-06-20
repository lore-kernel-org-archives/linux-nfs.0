Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54048 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754230AbeFTQVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Jun 2018 12:21:35 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F15C040201A2
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2018 16:21:34 +0000 (UTC)
From: Kenneth Dsouza <kdsouza@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com, sorenson@redhat.com
Subject: [PATCH] nfs-utils: Fix minor memory leaks before return.
Date: Wed, 20 Jun 2018 21:51:29 +0530
Message-Id: <20180620162129.12692-1-kdsouza@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 support/junction/path.c            | 4 +++-
 support/nfsidmap/nfsidmap_common.c | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/support/junction/path.c b/support/junction/path.c
index 68a1d13..e74e4c4 100644
--- a/support/junction/path.c
+++ b/support/junction/path.c
@@ -326,8 +326,10 @@ nsdb_posix_to_path_array(const char *pathname, char ***path_array)
 			break;
 		next = strchrnul(component, '/');
 		length = (size_t)(next - component);
-		if (length > 255)
+		if (length > 255) {
+			nsdb_free_string_array(result);
 			return FEDFS_ERR_SVRFAULT;
+		}
 
 		result[i] = strndup(component, length);
 		if (result[i] == NULL) {
diff --git a/support/nfsidmap/nfsidmap_common.c b/support/nfsidmap/nfsidmap_common.c
index 5242c7e..f89b82e 100644
--- a/support/nfsidmap/nfsidmap_common.c
+++ b/support/nfsidmap/nfsidmap_common.c
@@ -57,8 +57,10 @@ struct conf_list *get_local_realms(void)
 			return NULL;
 
 		node->field = calloc(1, NFS4_MAX_DOMAIN_LEN);
-		if (node->field == NULL)
+		if (node->field == NULL) {
+			free(node);
 			return NULL;
+		}
 
 		nfs4_get_default_domain(NULL, node->field, NFS4_MAX_DOMAIN_LEN);
 		toupper_str(node->field);
-- 
2.14.3

