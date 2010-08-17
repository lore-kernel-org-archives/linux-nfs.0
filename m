Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12939 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473Ab0HQTio (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 15:38:44 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o7HJciNj024464
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Aug 2010 15:38:44 -0400
Received: from fathat.boston.devel.redhat.com (fathat.boston.devel.redhat.com [10.16.60.125])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o7HJcgrl011196
	for <linux-nfs@vger.kernel.org>; Tue, 17 Aug 2010 15:38:43 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] Add server support to use of numeric strings for uid and gids.
Date: Tue, 17 Aug 2010 15:38:45 -0400
Message-Id: <1282073925-18707-3-git-send-email-steved@redhat.com>
In-Reply-To: <1282073925-18707-1-git-send-email-steved@redhat.com>
References: <1282073925-18707-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When a uid or gid does not map into the a domain and the
new 'NumericIDs' variable is enabled in idmapd.conf, the server
will send out numeric representations, strings without the
@domain part, of the given id.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/idmapd/idmapd.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index d6799c9..7f1291d 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -794,15 +794,22 @@ nfsopen(struct idmap_client *ic)
 static void
 idtonameres(struct idmap_msg *im)
 {
-	char domain[NFS4_MAX_DOMAIN_LEN];
+	char domain[NFS4_MAX_DOMAIN_LEN], *numids;
 	int ret = 0;
 
 	ret = nfs4_get_default_domain(NULL, domain, sizeof(domain));
+	numids = conf_get_str("Mapping", "NumericIDs");
+
 	switch (im->im_type) {
 	case IDMAP_TYPE_USER:
 		ret = nfs4_uid_to_name(im->im_id, domain, im->im_name,
 				sizeof(im->im_name));
 		if (ret) {
+			if (numids && strcasecmp(numids, "yes") == 0) {
+				sprintf(im->im_name, "%d", im->im_id);
+				ret=0;
+				break;
+			}
 			if (strlen(nobodyuser) < sizeof(im->im_name))
 				strcpy(im->im_name, nobodyuser);
 			else
@@ -813,6 +820,11 @@ idtonameres(struct idmap_msg *im)
 		ret = nfs4_gid_to_name(im->im_id, domain, im->im_name,
 				sizeof(im->im_name));
 		if (ret) {
+			if (numids && strcasecmp(numids, "yes") == 0) {
+				sprintf(im->im_name, "%d", im->im_id);
+				ret=0;
+				break;
+			}
 			if (strlen(nobodygroup) < sizeof(im->im_name))
 				strcpy(im->im_name, nobodygroup);
 			else
-- 
1.7.1

