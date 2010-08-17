Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19280 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936Ab0HQTio (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 15:38:44 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o7HJchEM023648
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Aug 2010 15:38:43 -0400
Received: from fathat.boston.devel.redhat.com (fathat.boston.devel.redhat.com [10.16.60.125])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o7HJcgrk011196
	for <linux-nfs@vger.kernel.org>; Tue, 17 Aug 2010 15:38:43 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] Teach clients to map numeric strings into valid uids and gids.
Date: Tue, 17 Aug 2010 15:38:44 -0400
Message-Id: <1282073925-18707-2-git-send-email-steved@redhat.com>
In-Reply-To: <1282073925-18707-1-git-send-email-steved@redhat.com>
References: <1282073925-18707-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When a server can not map a uid or gid they can send
an numeric string (one that does not include the @domain)
of the given id. When this occurs the client will can use
that numeric representation iff that id exists on the client.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/idmapd/idmapd.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 9ecab66..d6799c9 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -826,6 +826,21 @@ idtonameres(struct idmap_msg *im)
 		im->im_status = IDMAP_STATUS_SUCCESS;
 }
 
+static int
+alldigits(char *name)
+{
+	char *p = name;
+
+	if (name == NULL)
+		return 0;
+
+	while (*p != '\0') {
+		if (!isdigit(*p++))
+			return 0;
+	}
+	return 1;
+}
+
 static void
 nametoidres(struct idmap_msg *im)
 {
@@ -843,6 +858,18 @@ nametoidres(struct idmap_msg *im)
 		ret = nfs4_name_to_uid(im->im_name, &uid);
 		im->im_id = (u_int32_t) uid;
 		if (ret) {
+			/*
+			 * When a server sends numeric string that's
+			 * lacking the @domain part, and the uid exists
+			 * use the numeric string as the uid. 
+			 */
+			if (alldigits(im->im_name)) {
+				sscanf(im->im_name, "%u", &uid);
+				if (getpwuid(uid) != NULL) {
+					im->im_id = uid;	
+					break;
+				}
+			}
 			im->im_status = IDMAP_STATUS_LOOKUPFAIL;
 			im->im_id = nobodyuid;
 		}
@@ -851,6 +878,17 @@ nametoidres(struct idmap_msg *im)
 		ret = nfs4_name_to_gid(im->im_name, &gid);
 		im->im_id = (u_int32_t) gid;
 		if (ret) {
+			/*
+			 * Do the same type of mapping of a numeric string
+			 * sent as the gid.
+			 */
+			if (alldigits(im->im_name)) {
+				sscanf(im->im_name, "%u", &gid);
+				if (getgrgid(gid) != NULL) {
+					im->im_id = gid;
+					break;
+				}
+			}
 			im->im_status = IDMAP_STATUS_LOOKUPFAIL;
 			im->im_id = nobodygid;
 		}
-- 
1.7.1

